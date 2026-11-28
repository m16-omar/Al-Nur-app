import 'package:alnur_store_server/src/generated/protocol.dart';
import 'package:alnur_store_server/src/security/admin_auth.dart';
import 'package:serverpod_auth_idp_server/core.dart' show AuthUser;
import 'package:serverpod_auth_idp_server/providers/email.dart' show EmailAccount;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Security: access control', (sessionBuilder, endpoints) {
    late TestSessionBuilder alice;
    late TestSessionBuilder bob;
    late TestSessionBuilder admin;
    late TestSessionBuilder anonymous;

    setUp(() async {
      final session = sessionBuilder.build();
      Future<String> makeCustomer(String email) async {
        final user = await AuthUser.db.insertRow(session, AuthUser(scopeNames: {}, blocked: false));
        await EmailAccount.db.insertRow(
          session,
          EmailAccount(authUserId: user.id!, email: email, passwordHash: 'x'),
        );
        return user.id!.uuid;
      }

      alice = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
            await makeCustomer('alice@example.com'), {}),
      );
      bob = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
            await makeCustomer('bob@example.com'), {}),
      );
      admin = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
            'alnur-admin:admin@alnur.store', {AlnurAdminAuth.scope}),
      );
      anonymous = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.unauthenticated(),
      );
    });

    final product = StoreProduct(
      name: 'Test Ring',
      slug: 'test-ring',
      categoryId: 'rings',
      price: 1000,
      rating: 5,
      reviewCount: 0,
      imageUrl: '',
      description: 'd',
      isAvailable: true,
    );

    test('createProduct: anonymous -> unauthenticated, customer -> forbidden, admin -> ok', () async {
      await expectLater(endpoints.product.createProduct(anonymous, product),
          throwsA(isA<ServerpodUnauthenticatedException>()));
      await expectLater(endpoints.product.createProduct(alice, product),
          throwsA(isA<ServerpodInsufficientAccessException>()));
      final created = await endpoints.product.createProduct(admin, product);
      expect(created.id, isNotNull);
    });

    test('order management and customer list are admin-only', () async {
      await expectLater(endpoints.order.deleteOrder(alice, orderRef: 'x'),
          throwsA(isA<ServerpodInsufficientAccessException>()));
      await expectLater(endpoints.order.updatePaymentStatus(alice, orderRef: 'x', paymentStatus: 'paid'),
          throwsA(isA<ServerpodInsufficientAccessException>()));
      await expectLater(endpoints.user.getAdminCustomers(anonymous),
          throwsA(isA<ServerpodUnauthenticatedException>()));
      expect(await endpoints.user.getAdminCustomers(admin), startsWith('['));
    });

    test('customers can only read their own profile and addresses', () async {
      final mine = await endpoints.user.getProfile(alice, email: 'alice@example.com');
      expect(mine.userEmail, 'alice@example.com');
      await expectLater(endpoints.user.getProfile(alice, email: 'bob@example.com'),
          throwsA(isA<ServerpodInsufficientAccessException>()));
      await expectLater(endpoints.user.getAddresses(anonymous, email: 'alice@example.com'),
          throwsA(isA<ServerpodUnauthenticatedException>()));
    });

    test('a customer cannot overwrite another customer\'s address by id', () async {
      final bobs = await endpoints.user.saveAddress(
        bob,
        address: UserAddress(
          userEmail: 'bob@example.com',
          title: 'Home',
          recipientName: 'Bob',
          phoneNumber: '080',
          streetAddress: '1 Street',
          city: 'Lagos',
          state: 'Lagos',
          isDefault: true,
        ),
      );
      await expectLater(
        endpoints.user.saveAddress(
          alice,
          address: bobs.copyWith(userEmail: 'alice@example.com', streetAddress: 'hijacked'),
        ),
        throwsA(isA<ServerpodInsufficientAccessException>()),
      );
      final still = await UserAddress.db.findById(sessionBuilder.build(), bobs.id!);
      expect(still!.streetAddress, '1 Street');
    });

    test('orders: clients cannot mark paid, only owners see orders', () async {
      final order = await endpoints.order.createOrder(
        alice,
        idempotencyKey: 'sec-order-1',
        customerEmail: 'alice@example.com',
        customerName: 'Alice <script>x</script>',
        customerPhone: '+234 800',
        shippingAddress: 'Lagos',
        totalAmount: 5000,
        itemsJson: '[{"name":"<img src=x onerror=alert(1)>","price":5000}]',
        paymentReference: 'claimed-paid',
      );
      expect(order.paymentStatus, 'pending');
      expect(order.customerName, isNot(contains('<')));
      expect(order.itemsJson, isNot(contains('<')));

      await expectLater(
        endpoints.order.createOrder(
          alice,
          idempotencyKey: 'sec-order-2',
          customerEmail: 'bob@example.com',
          customerName: 'x',
          customerPhone: '1',
          shippingAddress: 'x',
          totalAmount: 1,
          itemsJson: '[]',
        ),
        throwsA(isA<ServerpodInsufficientAccessException>()),
      );

      expect(await endpoints.order.getOrders(alice, customerEmail: 'alice@example.com'), hasLength(1));
      expect(await endpoints.order.getOrders(bob, customerEmail: 'alice@example.com'), isEmpty);
      expect(await endpoints.order.getOrders(anonymous, customerEmail: 'alice@example.com'), isEmpty);
      expect(await endpoints.order.getOrders(anonymous, adminKey: 'AlNur2026!'), isEmpty);
      expect(await endpoints.order.getOrders(admin), isNotEmpty);
    });

    test('storage writes are admin-only', () async {
      await expectLater(
        endpoints.storage.deleteFile(alice, path: 'products/a.png'),
        throwsA(isA<ServerpodInsufficientAccessException>()),
      );
    });
  });
}

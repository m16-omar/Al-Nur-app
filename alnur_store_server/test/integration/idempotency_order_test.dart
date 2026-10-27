import 'package:alnur_store_server/src/generated/protocol.dart';
import 'package:alnur_store_server/src/idempotency/idempotency_manager.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Idempotency and Order endpoint', (sessionBuilder, endpoints) {
    test(
      'when calling createOrder with the same idempotency key twice, it returns cached order and does not create duplicate in DB',
      () async {
        const testKey = 'test-idemp-key-12345';
        final session = sessionBuilder.build();

        // 1. Initial Order Submission
        final order1 = await endpoints.order.createOrder(
          sessionBuilder,
          idempotencyKey: testKey,
          customerEmail: 'amina@alnur.store',
          customerName: 'Amina Al-Mansoor',
          customerPhone: '+234 803 987 6543',
          shippingAddress: 'Lekki Phase 1, Lagos',
          totalAmount: 28500.0,
          itemsJson: '[{"name": "Dubai Gold Noir Abaya", "qty": 1, "price": 28500}]',
          paymentReference: 'pay_ref_001',
        );

        expect(order1.id, isNotNull);
        expect(order1.orderRef, startsWith('ALN-'));
        expect(order1.totalAmount, 28500.0);

        // 2. Duplicate Submission with Same Idempotency Key (e.g. Network Retry / Double Tap)
        final order2 = await endpoints.order.createOrder(
          sessionBuilder,
          idempotencyKey: testKey,
          customerEmail: 'amina@alnur.store',
          customerName: 'Amina Al-Mansoor',
          customerPhone: '+234 803 987 6543',
          shippingAddress: 'Lekki Phase 1, Lagos',
          totalAmount: 28500.0,
          itemsJson: '[{"name": "Dubai Gold Noir Abaya", "qty": 1, "price": 28500}]',
          paymentReference: 'pay_ref_001',
        );

        // Expect exact same order returned idempotently
        expect(order2.id, equals(order1.id));
        expect(order2.orderRef, equals(order1.orderRef));
        expect(order2.totalAmount, equals(order1.totalAmount));

        // Verify only 1 order exists with this idempotency key in DB
        final allOrders = await StoreOrder.db.find(
          session,
          where: (t) => t.idempotencyKey.equals(testKey),
        );
        expect(allOrders.length, equals(1));
      },
    );

    test(
      'when calling createOrder with same idempotency key but different payload, it throws IdempotencyConflictException',
      () async {
        const testKey = 'test-idemp-conflict-key';

        // 1. Initial request
        await endpoints.order.createOrder(
          sessionBuilder,
          idempotencyKey: testKey,
          customerEmail: 'fatima@alnur.store',
          customerName: 'Fatima Zahra',
          customerPhone: '+234 812 345 6789',
          shippingAddress: 'Maitama, Abuja',
          totalAmount: 24500.0,
          itemsJson: '[{"name": "Classic Black Korean Abaya", "qty": 1}]',
        );

        // 2. Reused key with different totalAmount
        expect(
          () => endpoints.order.createOrder(
            sessionBuilder,
            idempotencyKey: testKey,
            customerEmail: 'fatima@alnur.store',
            customerName: 'Fatima Zahra',
            customerPhone: '+234 812 345 6789',
            shippingAddress: 'Maitama, Abuja',
            totalAmount: 99999.0, // Modified payload
            itemsJson: '[{"name": "Classic Black Korean Abaya", "qty": 1}]',
          ),
          throwsA(isA<IdempotencyConflictException>()),
        );
      },
    );
  });
}

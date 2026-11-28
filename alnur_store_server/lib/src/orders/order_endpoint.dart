import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../idempotency/idempotency_manager.dart';
import '../security/admin_auth.dart';
import '../security/customer_auth.dart';
import '../security/input_sanitizer.dart';
import '../security/rate_limiter.dart';
import '../util/email_service.dart';

/// Endpoint for handling orders, checkout, and payment fulfillment with
/// enterprise idempotency guarantees.
class OrderEndpoint extends Endpoint {
  /// Places a customer order with strict enterprise idempotency protection.
  ///
  /// If the same [idempotencyKey] is sent multiple times (e.g. user double-taps
  /// checkout button or network retry occurs), the existing order is safely returned
  /// without double-charging or creating duplicate orders in the database.
  Future<StoreOrder> createOrder(
    Session session, {
    required String? idempotencyKey,
    required String customerEmail,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required double totalAmount,
    required String itemsJson,
    String? paymentReference,
  }) async {
    RateLimiter.enforce(session, 'order.createOrder',
        max: 20, window: const Duration(hours: 1));

    // ---- Validate & clean input ----
    final cleanEmail = InputSanitizer.email(customerEmail);
    if (cleanEmail.isEmpty) {
      throw ArgumentError('A valid customer email is required.');
    }
    if (!totalAmount.isFinite || totalAmount <= 0 || totalAmount > 100000000) {
      throw ArgumentError('Invalid order total.');
    }
    if (itemsJson.length > 100000) {
      throw ArgumentError('Order has too many items.');
    }
    try {
      final decoded = jsonDecode(itemsJson);
      if (decoded is! List) throw const FormatException();
    } catch (_) {
      throw ArgumentError('Invalid order items.');
    }
    // A signed-in customer can only place orders for their own account.
    final signedIn = await CustomerAuth.signedInEmail(session);
    if (signedIn != null && signedIn != cleanEmail) {
      throw NotAuthorizedException(
        reason: AuthenticationFailureReason.insufficientAccess,
        message: 'You can only place orders for your own account.',
      );
    }
    customerEmail = cleanEmail;
    customerName = InputSanitizer.text(customerName, maxLength: 120);
    customerPhone = InputSanitizer.phone(customerPhone);
    shippingAddress = InputSanitizer.text(shippingAddress, maxLength: 400);
    itemsJson = _sanitizeItems(itemsJson);
    paymentReference = InputSanitizer.optionalText(paymentReference, maxLength: 120);

    return await IdempotencyManager.run<StoreOrder>(
      session: session,
      idempotencyKey: idempotencyKey,
      endpoint: 'order.createOrder',
      requestData: {
        'customerEmail': customerEmail.toLowerCase().trim(),
        'customerName': customerName.trim(),
        'customerPhone': customerPhone.trim(),
        'shippingAddress': shippingAddress.trim(),
        'totalAmount': totalAmount,
        'itemsJson': itemsJson,
        'paymentReference': paymentReference,
      },
      action: () async {
        final now = DateTime.now();
        final orderRef =
            'ALN-${now.millisecondsSinceEpoch.toString().substring(7)}';

        final newOrder = StoreOrder(
          orderRef: orderRef,
          customerEmail: customerEmail.toLowerCase().trim(),
          customerName: customerName.trim(),
          customerPhone: customerPhone.trim(),
          shippingAddress: shippingAddress.trim(),
          totalAmount: totalAmount,
          // Payment is never trusted from the client: it stays 'pending' until
          // an admin confirms it (or a verified gateway callback marks it).
          paymentStatus: 'pending',
          fulfillmentStatus: 'placed',
          idempotencyKey: idempotencyKey,
          paymentReference: paymentReference,
          itemsJson: itemsJson,
          createdAt: now,
          updatedAt: now,
        );

        final insertedOrder =
            await StoreOrder.db.insertRow(session, newOrder);

        // Dispatch branded confirmation email (Stage 1: Order Placed & Confirmed) to customer asynchronously
        unawaited(
          EmailService.sendOrderStatusEmail(
            session,
            orderRef: orderRef,
            customerEmail: customerEmail.toLowerCase().trim(),
            customerName: customerName.trim(),
            shippingAddress: shippingAddress.trim(),
            totalAmount: totalAmount,
            canonicalStatus: 'placed',
          ).timeout(const Duration(seconds: 8)).catchError((e) {
            session.log('Failed to dispatch order status email: $e',
                level: LogLevel.warning);
            return false;
          }),
        );

        return insertedOrder;
      },
      toJson: (order) => jsonEncode(order.toJson()),
      fromJson: (jsonStr) =>
          StoreOrder.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  }

  /// Normalizes status strings into the canonical 5-level lifecycle flow:
  /// 1. placed (Order Placed & Confirmed)
  /// 2. processing (Processing & Handcrafted Tailoring)
  /// 3. shipped (Shipped & Handed to Courier)
  /// 4. out_for_delivery (Out for Delivery)
  /// 5. delivered (Delivered)
  /// or cancelled.
  static String normalizeFulfillmentStatus(String raw) {
    final lower = raw.toLowerCase().trim().replaceAll(' ', '_');
    if (lower.contains('cancel')) return 'cancelled';
    if (lower.contains('deliver') || lower.contains('complete')) return 'delivered';
    if (lower.contains('out_for_delivery') || lower.contains('transit')) return 'out_for_delivery';
    if (lower.contains('ship') || lower.contains('dispatch') || lower.contains('courier')) return 'shipped';
    if (lower.contains('tailor') || lower.contains('process') || lower.contains('craft')) return 'processing';
    if (lower.contains('place') || lower.contains('confirm')) return 'placed';
    return 'processing';
  }

  /// Retrieves orders from PostgreSQL with strict customer data isolation.
  ///
  /// Regular users can ONLY retrieve orders matching their own [customerEmail].
  /// If [customerEmail] is null or empty, an empty list is returned to strictly
  /// prevent any privacy data leak across customer accounts.
  /// Full order history is only returned when authorized with [adminKey].
  Future<List<StoreOrder>> getOrders(
    Session session, {
    String? customerEmail,
    String? adminKey,
  }) async {
    // Admins (signed in to the admin panel) see every order. The legacy
    // [adminKey] parameter is ignored: it was a shared secret in public code.
    if (AlnurAdminAuth.isAdmin(session)) {
      return await StoreOrder.db.find(
        session,
        orderBy: (t) => t.createdAt,
        orderDescending: true,
      );
    }

    // STRICT ISOLATION: only the signed-in owner of [customerEmail].
    final cleanEmail = customerEmail?.trim().toLowerCase();
    if (cleanEmail == null || cleanEmail.isEmpty) return [];
    if (!await CustomerAuth.canAccess(session, cleanEmail)) return [];

    return await StoreOrder.db.find(
      session,
      where: (t) => t.customerEmail.equals(cleanEmail),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Dedicated admin endpoint to retrieve all customer orders.
  Future<List<StoreOrder>> getAdminOrders(
    Session session, {
    required String adminKey,
  }) async {
    AlnurAdminAuth.requireAdmin(session);
    return await StoreOrder.db.find(
      session,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Monnify credentials come from Serverpod passwords (never from code):
  /// `monnifyApiKey`, `monnifySecretKey`, `monnifyContractCode` and optional
  /// `monnifyBaseUrl` (defaults to the sandbox).
  static String? _secret(Session session, String name) {
    final v = session.passwords[name]?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  /// Payment statuses an admin may set.
  static const _paymentStatuses = {
    'paid', 'pending', 'refunded', 'failed', 'verified', 'cancelled',
  };

  /// Cleans the free-text fields inside the order items JSON.
  static String _sanitizeItems(String itemsJson) {
    final list = jsonDecode(itemsJson) as List;
    final cleaned = list.take(200).map((item) {
      if (item is! Map) return <String, dynamic>{};
      return item.map((k, v) => MapEntry(
            InputSanitizer.text('$k', maxLength: 40),
            v is String
                ? (k == 'imageUrl'
                    ? (InputSanitizer.imageUrl(v) ?? '')
                    : InputSanitizer.text(v, maxLength: 300))
                : (v is num || v is bool || v == null ? v : InputSanitizer.text('$v', maxLength: 300)),
          ));
    }).toList();
    return jsonEncode(cleaned);
  }

  /// Initializes a Monnify payment transaction with exact dynamic Naira amount,
  /// returning the Monnify hosted checkout URL (supporting Cards, Dynamic Bank Transfer, and USSD).
  Future<String?> initializeMonnifyPayment(
    Session session, {
    required double amount,
    required String customerName,
    required String customerEmail,
    required String orderRef,
    String? customerPhone,
    String? redirectUrl,
  }) async {
    RateLimiter.enforce(session, 'order.initializeMonnifyPayment',
        max: 20, window: const Duration(minutes: 10));
    if (!amount.isFinite || amount <= 0 || amount > 100000000) {
      throw ArgumentError('Invalid amount.');
    }
    final monnifyApiKey = _secret(session, 'monnifyApiKey');
    final monnifySecretKey = _secret(session, 'monnifySecretKey');
    final monnifyContractCode = _secret(session, 'monnifyContractCode');
    final monnifyBaseUrl =
        _secret(session, 'monnifyBaseUrl') ?? 'https://sandbox.monnify.com';
    if (monnifyApiKey == null || monnifySecretKey == null || monnifyContractCode == null) {
      session.log('Monnify is not configured (monnifyApiKey / monnifySecretKey / monnifyContractCode).',
          level: LogLevel.error);
      return null;
    }
    customerName = InputSanitizer.text(customerName, maxLength: 120);
    customerEmail = InputSanitizer.email(customerEmail);
    orderRef = InputSanitizer.text(orderRef, maxLength: 80);
    redirectUrl = InputSanitizer.url(redirectUrl);
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);

      // 1. Authenticate with Monnify API to retrieve bearer access token
      final authStr = '$monnifyApiKey:$monnifySecretKey';
      final authB64 = base64Encode(utf8.encode(authStr));

      final loginUri = Uri.parse('$monnifyBaseUrl/api/v1/auth/login');
      final loginReq = await client.postUrl(loginUri);
      loginReq.headers.set('Authorization', 'Basic $authB64');
      loginReq.headers.set('User-Agent', 'AlNurStore-Serverpod/1.0 (Darwin)');
      loginReq.headers.contentType = ContentType.json;

      final loginResp = await loginReq.close().timeout(const Duration(seconds: 10));
      if (loginResp.statusCode != 200) {
        final errBody = await loginResp.transform(utf8.decoder).join();
        session.log('Monnify auth failed: ${loginResp.statusCode} -> $errBody', level: LogLevel.error);
        return null;
      }

      final loginBody = await loginResp.transform(utf8.decoder).join();
      final loginData = jsonDecode(loginBody) as Map<String, dynamic>;
      final accessToken = loginData['responseBody']?['accessToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        session.log('Monnify auth token missing', level: LogLevel.error);
        return null;
      }

      // 2. Initialize transaction
      final initUri = Uri.parse('$monnifyBaseUrl/api/v1/merchant/transactions/init-transaction');
      final initReq = await client.postUrl(initUri);
      initReq.headers.set('Authorization', 'Bearer $accessToken');
      initReq.headers.set('User-Agent', 'AlNurStore-Serverpod/1.0 (Darwin)');
      initReq.headers.contentType = ContentType.json;

      final paymentRef = '$orderRef-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final effectiveRedirect = (redirectUrl != null && redirectUrl.trim().isNotEmpty)
          ? redirectUrl.trim()
          : 'https://al-nur-tau.vercel.app/orders?success=1&ref=$orderRef';
      final payload = jsonEncode({
        'amount': amount,
        'customerName': customerName.trim().isNotEmpty ? customerName.trim() : 'Al-Nur Customer',
        'customerEmail': customerEmail.trim().isNotEmpty ? customerEmail.trim() : 'customer@alnurstore.com',
        'paymentReference': paymentRef,
        'paymentDescription': 'Al-Nur Store Order $orderRef (₦${amount.toStringAsFixed(0)})',
        'currencyCode': 'NGN',
        'contractCode': monnifyContractCode,
        'redirectUrl': effectiveRedirect,
        'paymentMethods': ['CARD', 'ACCOUNT_TRANSFER'],
      });

      initReq.write(payload);
      final initResp = await initReq.close().timeout(const Duration(seconds: 15));
      final initBody = await initResp.transform(utf8.decoder).join();

      if (initResp.statusCode == 200) {
        final initData = jsonDecode(initBody) as Map<String, dynamic>;
        final checkoutUrl = initData['responseBody']?['checkoutUrl'] as String?;
        session.log('Monnify payment initialized successfully: $checkoutUrl', level: LogLevel.info);
        return checkoutUrl;
      } else {
        session.log('Monnify init-transaction failed: ${initResp.statusCode} -> $initBody', level: LogLevel.error);
        return null;
      }
    } catch (e) {
      session.log('Monnify initialization error: $e', level: LogLevel.error);
      return null;
    }
  }

  /// Processes payment gateway webhooks (Selar, Paystack, Flutterwave) idempotently.
  /// Prevents double-crediting or duplicate status notifications.
  Future<StoreOrder?> processPaymentWebhook(
    Session session, {
    required String paymentReference,
    required String orderRef,
    required String status,
    String? idempotencyKey,
  }) async {
    AlnurAdminAuth.requireAdmin(session);
    final effectiveKey = idempotencyKey ?? 'webhook-$paymentReference';

    return await IdempotencyManager.run<StoreOrder?>(
      session: session,
      idempotencyKey: effectiveKey,
      endpoint: 'order.processPaymentWebhook',
      requestData: {
        'paymentReference': paymentReference,
        'orderRef': orderRef,
        'status': status,
      },
      action: () async {
        final order = await StoreOrder.db.findFirstRow(
          session,
          where: (t) => t.orderRef.equals(orderRef),
        );

        if (order == null) return null;

        order.paymentReference = paymentReference;
        final st = status.toLowerCase().trim();
        order.paymentStatus = st == 'success'
            ? 'paid'
            : (_paymentStatuses.contains(st) ? st : 'pending');
        order.updatedAt = DateTime.now();

        return await StoreOrder.db.updateRow(session, order);
      },
      toJson: (order) => order == null ? '' : jsonEncode(order.toJson()),
      fromJson: (jsonStr) => jsonStr.isEmpty
          ? null
          : StoreOrder.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  }

  /// Updates an order's fulfillment status following the unified lifecycle:
  /// processing -> shipped -> out_for_delivery -> delivered (or cancelled).
  Future<StoreOrder?> updateOrderStatus(
    Session session, {
    required String orderRef,
    required String fulfillmentStatus,
  }) async {
    AlnurAdminAuth.requireAdmin(session);
    final order = await StoreOrder.db.findFirstRow(
      session,
      where: (t) => t.orderRef.equals(orderRef),
    );
    if (order == null) return null;

    final canonicalStatus = normalizeFulfillmentStatus(fulfillmentStatus);
    order.fulfillmentStatus = canonicalStatus;
    order.updatedAt = DateTime.now();

    final updated = await StoreOrder.db.updateRow(session, order);

    // Dispatch branded status lifecycle email to customer for all stages:
    // 1. Order Placed & Confirmed
    // 2. Processing & Handcrafted Tailoring
    // 3. Shipped & Handed to Courier
    // 4. Out for Delivery
    // 5. Delivered
    if (order.customerEmail.isNotEmpty) {
      unawaited(
        EmailService.sendOrderStatusEmail(
          session,
          orderRef: order.orderRef,
          customerEmail: order.customerEmail.trim(),
          customerName: order.customerName.trim(),
          shippingAddress: order.shippingAddress,
          totalAmount: order.totalAmount,
          canonicalStatus: canonicalStatus,
        ).timeout(const Duration(seconds: 8)).catchError((e) {
          session.log('Failed to dispatch status email: $e',
              level: LogLevel.warning);
          return false;
        }),
      );
    }

    return updated;
  }

  /// Updates an order's payment status (e.g. 'paid', 'pending', 'refunded', 'failed').
  Future<StoreOrder?> updatePaymentStatus(
    Session session, {
    required String orderRef,
    required String paymentStatus,
    String? paymentReference,
  }) async {
    AlnurAdminAuth.requireAdmin(session);
    final order = await StoreOrder.db.findFirstRow(
      session,
      where: (t) => t.orderRef.equals(orderRef),
    );
    if (order == null) return null;

    final cleanStatus = paymentStatus.toLowerCase().trim();
    if (!_paymentStatuses.contains(cleanStatus)) {
      throw ArgumentError('Unknown payment status.');
    }
    order.paymentStatus = cleanStatus;
    if (paymentReference != null && paymentReference.isNotEmpty) {
      order.paymentReference = InputSanitizer.text(paymentReference, maxLength: 120);
    }
    order.updatedAt = DateTime.now();

    return await StoreOrder.db.updateRow(session, order);
  }

  /// Deletes or permanently cancels an order.
  Future<bool> deleteOrder(
    Session session, {
    required String orderRef,
  }) async {
    AlnurAdminAuth.requireAdmin(session);
    final order = await StoreOrder.db.findFirstRow(
      session,
      where: (t) => t.orderRef.equals(orderRef),
    );
    if (order == null) return false;

    await StoreOrder.db.deleteRow(session, order);
    return true;
  }
}

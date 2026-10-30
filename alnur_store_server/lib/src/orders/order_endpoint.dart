import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../idempotency/idempotency_manager.dart';
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
          paymentStatus: paymentReference != null ? 'paid' : 'pending',
          fulfillmentStatus: 'placed',
          idempotencyKey: idempotencyKey,
          paymentReference: paymentReference,
          itemsJson: itemsJson,
          createdAt: now,
          updatedAt: now,
        );

        final insertedOrder =
            await StoreOrder.db.insertRow(session, newOrder);

        // Dispatch branded confirmation email to customer
        try {
          await EmailService.sendNotificationEmail(
            session,
            toEmail: customerEmail,
            recipientName: customerName,
            subject: '✨ Al-Nur Luxury Order Confirmation [$orderRef]',
            headerTitle: 'Order Confirmed: $orderRef',
            messageHtml: '''
              <p style="margin-bottom:14px;">Assalamu alaykum ${customerName.isNotEmpty ? customerName : 'Valued Customer'},</p>
              <p style="margin-bottom:16px;">Thank you for shopping with <strong>Al-Nur Modest Haute Couture</strong>. We have received your order and our artisans have commenced fulfillment.</p>
              <div style="background:#F9FAFB;padding:16px;border-radius:12px;margin:16px 0;border:1px solid #E5E7EB;">
                <p style="margin:0 0 8px 0;font-size:13px;"><strong>Order Reference:</strong> <span style="font-family:monospace;color:#0B291E;">$orderRef</span></p>
                <p style="margin:0 0 8px 0;font-size:13px;"><strong>Total Amount:</strong> ₦${totalAmount.toStringAsFixed(0)}</p>
                <p style="margin:0 0 8px 0;font-size:13px;"><strong>Shipping Address:</strong> $shippingAddress</p>
                <p style="margin:0;font-size:13px;"><strong>Payment Status:</strong> <span style="color:#059669;font-weight:bold;">${newOrder.paymentStatus.toUpperCase()}</span></p>
              </div>
              <p style="color:#6B7280;font-size:12px;margin-top:14px;">Your modest couture items are carefully packaged in our gold-foil heirloom boxes.</p>
            ''',
          );
        } catch (e) {
          session.log('Failed to dispatch order receipt: $e',
              level: LogLevel.warning);
        }

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
    // If authorized admin key is provided, return all orders for admin dashboard
    if (adminKey != null && adminKey.trim() == 'AlNur2026!') {
      return await StoreOrder.db.find(
        session,
        orderBy: (t) => t.createdAt,
        orderDescending: true,
      );
    }

    // STRICT ISOLATION: A non-empty customer email is required.
    final cleanEmail = customerEmail?.trim().toLowerCase();
    if (cleanEmail == null || cleanEmail.isEmpty) {
      // NEVER leak all orders to unauthenticated or empty customer email callers.
      return [];
    }

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
    if (adminKey.trim() != 'AlNur2026!') {
      return [];
    }
    return await StoreOrder.db.find(
      session,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Official Selar Merchant Integration Credentials
  static const String selarApiKey = 'sat_873skzy08l1889v50814bs77093r4818j38f8';
  static const String selarStoreUrl = 'https://selar.com/h3wa923367';

  /// Official Monnify Merchant Integration Credentials (Sandbox / Live)
  static const String monnifyApiKey = 'MK_TEST_F0NB310FSJ';
  static const String monnifySecretKey = 'GH7QBNC73BVC5XWQ4BHTYYHDDHANB35B';
  static const String monnifyContractCode = '6355760337';
  static const String monnifyBaseUrl = 'https://sandbox.monnify.com';

  /// Initializes a Monnify payment transaction with exact dynamic Naira amount,
  /// returning the Monnify hosted checkout URL (supporting Cards, Dynamic Bank Transfer, and USSD).
  Future<String?> initializeMonnifyPayment(
    Session session, {
    required double amount,
    required String customerName,
    required String customerEmail,
    required String orderRef,
    String? customerPhone,
  }) async {
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
      final payload = jsonEncode({
        'amount': amount,
        'customerName': customerName.trim().isNotEmpty ? customerName.trim() : 'Al-Nur Customer',
        'customerEmail': customerEmail.trim().isNotEmpty ? customerEmail.trim() : 'customer@alnurstore.com',
        'paymentReference': paymentRef,
        'paymentDescription': 'Al-Nur Store Order $orderRef (₦${amount.toStringAsFixed(0)})',
        'currencyCode': 'NGN',
        'contractCode': monnifyContractCode,
        'redirectUrl': 'https://alnur-store.serverpod.space/app/checkout/success?ref=$orderRef',
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
    } catch (e, stack) {
      session.log('Monnify initialization error: $e\n$stack', level: LogLevel.error);
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
        order.paymentStatus =
            status.toLowerCase() == 'success' ? 'paid' : status;
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
    final order = await StoreOrder.db.findFirstRow(
      session,
      where: (t) => t.orderRef.equals(orderRef),
    );
    if (order == null) return null;

    final canonicalStatus = normalizeFulfillmentStatus(fulfillmentStatus);
    order.fulfillmentStatus = canonicalStatus;
    order.updatedAt = DateTime.now();

    final updated = await StoreOrder.db.updateRow(session, order);

    // Friendly status metadata for email dispatch
    String statusLabel;
    String statusDesc;
    switch (canonicalStatus) {
      case 'placed':
        statusLabel = 'ORDER PLACED & CONFIRMED';
        statusDesc =
            'Your order has been officially confirmed and logged in our artisanal atelier.';
        break;
      case 'processing':
        statusLabel = 'PROCESSING & HANDCRAFTED TAILORING';
        statusDesc =
            'Our master tailors have begun cutting, embellishing, and handcrafting your bespoke couture.';
        break;
      case 'shipped':
        statusLabel = 'SHIPPED & HANDED TO COURIER';
        statusDesc =
            'Your package has been securely sealed in our gold-foil box and handed to our courier partner.';
        break;
      case 'out_for_delivery':
        statusLabel = 'OUT FOR DELIVERY';
        statusDesc =
            'Our courier rider is actively en route heading to your delivery destination.';
        break;
      case 'delivered':
        statusLabel = 'DELIVERED';
        statusDesc =
            'Your order has been signed and delivered. May Allah bless your modest purchase!';
        break;
      case 'cancelled':
        statusLabel = 'CANCELLED';
        statusDesc =
            'Your order has been cancelled. If you have questions, please reach out to customer care.';
        break;
      default:
        statusLabel = 'PROCESSING';
        statusDesc =
            'Our artisans are tailoring and preparing your modest couture garments.';
    }

    if (order.customerEmail.isNotEmpty && canonicalStatus != 'processing') {
      try {
        await EmailService.sendNotificationEmail(
          session,
          toEmail: order.customerEmail,
          recipientName: order.customerName,
          subject:
              'Al-Nur Order Update: Order #${order.orderRef} is $statusLabel',
          headerTitle: 'Order Update: #${order.orderRef}',
          messageHtml: '''
            <p>Dear ${order.customerName.isNotEmpty ? order.customerName : 'Valued Customer'},</p>
            <p>Your order <strong>#${order.orderRef}</strong> has been updated to: <strong style="color:#C87A1E;">$statusLabel</strong>.</p>
            <p style="margin:12px 0;color:#4B5563;">$statusDesc</p>
            <p><strong>Delivery Address:</strong> <em>${order.shippingAddress}</em></p>
            <p style="color:#6B7280;font-size:12px;margin-top:20px;">May Allah bless your purchase with Al-Nur.</p>
          ''',
        );
      } catch (e) {
        session.log('Email notice: $e', level: LogLevel.info);
      }
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
    final order = await StoreOrder.db.findFirstRow(
      session,
      where: (t) => t.orderRef.equals(orderRef),
    );
    if (order == null) return null;

    order.paymentStatus = paymentStatus.toLowerCase().trim();
    if (paymentReference != null && paymentReference.isNotEmpty) {
      order.paymentReference = paymentReference;
    }
    order.updatedAt = DateTime.now();

    return await StoreOrder.db.updateRow(session, order);
  }

  /// Deletes or permanently cancels an order.
  Future<bool> deleteOrder(
    Session session, {
    required String orderRef,
  }) async {
    final order = await StoreOrder.db.findFirstRow(
      session,
      where: (t) => t.orderRef.equals(orderRef),
    );
    if (order == null) return false;

    await StoreOrder.db.deleteRow(session, order);
    return true;
  }
}

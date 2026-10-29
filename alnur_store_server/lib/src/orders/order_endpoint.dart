import 'dart:convert';
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
          fulfillmentStatus: 'processing',
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

  /// Retrieves orders from PostgreSQL, optionally filtered by customer email.
  Future<List<StoreOrder>> getOrders(
    Session session, {
    String? customerEmail,
  }) async {
    if (customerEmail != null && customerEmail.isNotEmpty) {
      return await StoreOrder.db.find(
        session,
        where: (t) => t.customerEmail.equals(customerEmail.toLowerCase().trim()),
        orderBy: (t) => t.createdAt,
        orderDescending: true,
      );
    }
    return await StoreOrder.db.find(
      session,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Official Selar Merchant Integration Credentials
  static const String selarApiKey = 'sat_873skzy08l1889v50814bs77093r4818j38f8';
  static const String selarStoreUrl = 'https://selar.com/m/alnurstore';

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
}

import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class SelarPaymentService {
  static const String _prefKeySelarStoreUrl = 'alnur_selar_store_url';
  static const String defaultStoreUrl = 'https://selar.com/m/fatima-muhammad3397104';

  /// Retrieves the merchant Selar checkout/store URL, falling back to default
  static Future<String> getStoreUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeySelarStoreUrl) ?? defaultStoreUrl;
  }

  /// Allows setting or updating the Selar store link
  static Future<void> setStoreUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeySelarStoreUrl, url.trim());
  }

  /// Builds a Selar checkout URL with pre-filled customer details and order metadata
  static Future<String> buildCheckoutUrl({
    required double grandTotal,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    required List<CartItemModel> items,
    required String orderId,
  }) async {
    final base = await getStoreUrl();
    final uri = Uri.parse(base);

    final summary = items
        .map((i) => '${i.quantity}x ${i.name} (Size: ${i.size})')
        .join(', ');

    final queryParams = Map<String, String>.from(uri.queryParameters);
    queryParams['name'] = customerName;
    queryParams['email'] = customerEmail;
    if (customerPhone != null && customerPhone.isNotEmpty) {
      queryParams['phone'] = customerPhone;
    }
    queryParams['amount'] = grandTotal.toStringAsFixed(0);
    queryParams['ref'] = orderId;
    queryParams['order_summary'] = summary;
    queryParams['redirect_url'] = 'https://alnurstore.com/checkout/success';

    return uri.replace(queryParameters: queryParams).toString();
  }

  /// Checks if a navigated URL indicates that payment succeeded
  static bool isPaymentSuccessUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('success') ||
        lower.contains('/receipt/') ||
        lower.contains('thank-you') ||
        lower.contains('order-complete') ||
        lower.contains('alnurstore.com/checkout/success') ||
        lower.contains('status=success') ||
        lower.contains('status=successful');
  }
}

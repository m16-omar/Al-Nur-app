import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class SelarPaymentService {
  static const String _prefKeySelarStoreUrl = 'alnur_selar_store_url';
  static const String _prefKeySelarApiKey = 'alnur_selar_api_key';

  static const String defaultStoreUrl = 'https://selar.com/m/alnurstore';
  static const String defaultApiKey = 'sat_873skzy08l1889v50814bs77093r4818j38f8';

  /// Retrieves the merchant Selar checkout/store URL, falling back to default
  static Future<String> getStoreUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKeySelarStoreUrl);
    if (stored == null ||
        stored.isEmpty ||
        stored.contains('fatima-muhammad') ||
        stored.contains('fatimamuhammad') ||
        stored.endsWith('/alnur') ||
        stored.endsWith('/alnur/')) {
      await prefs.setString(_prefKeySelarStoreUrl, defaultStoreUrl);
      return defaultStoreUrl;
    }
    return stored;
  }

  /// Allows setting or updating the Selar store link
  static Future<void> setStoreUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeySelarStoreUrl, url.trim());
  }

  /// Retrieves the merchant Selar 3rd-party integration API key
  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKeySelarApiKey);
    if (stored == null || stored.isEmpty) {
      await prefs.setString(_prefKeySelarApiKey, defaultApiKey);
      return defaultApiKey;
    }
    return stored;
  }

  /// Allows setting or updating the Selar 3rd-party integration API key
  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeySelarApiKey, key.trim());
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

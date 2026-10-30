import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';

class MonnifyPaymentService {
  static const String _prefKeyContractCode = 'alnur_monnify_contract_code';
  static const String _prefKeyApiKey = 'alnur_monnify_api_key';

  static const String defaultContractCode = '6355760337';
  static const String defaultApiKey = 'MK_TEST_F0NB310FSJ';

  /// Retrieves the active Monnify contract code
  static Future<String> getContractCode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKeyContractCode);
    if (stored == null || stored.isEmpty) {
      await prefs.setString(_prefKeyContractCode, defaultContractCode);
      return defaultContractCode;
    }
    return stored;
  }

  /// Saves or updates the Monnify contract code
  static Future<void> setContractCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyContractCode, code.trim());
  }

  /// Retrieves the active Monnify API key
  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKeyApiKey);
    if (stored == null || stored.isEmpty) {
      await prefs.setString(_prefKeyApiKey, defaultApiKey);
      return defaultApiKey;
    }
    return stored;
  }

  /// Initializes a Monnify transaction with exact dynamic Naira amount via Serverpod
  static Future<String?> initializePayment({
    required double amount,
    required String customerName,
    required String customerEmail,
    required String orderRef,
    String? customerPhone,
  }) async {
    try {
      final checkoutUrl = await client.order.initializeMonnifyPayment(
        amount: amount,
        customerName: customerName,
        customerEmail: customerEmail,
        orderRef: orderRef,
        customerPhone: customerPhone,
      );
      return checkoutUrl;
    } catch (e) {
      return null;
    }
  }

  /// Verifies if a redirect URL confirms successful payment
  static bool isPaymentSuccessUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('checkout/success') ||
        lower.contains('status=success') ||
        lower.contains('status=successful') ||
        lower.contains('paymentstatus=paid') ||
        lower.contains('paymentstatus=successful') ||
        lower.contains('paid');
  }
}

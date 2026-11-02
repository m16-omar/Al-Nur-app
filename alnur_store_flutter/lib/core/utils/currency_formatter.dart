import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static final NumberFormat _nairaFormat = NumberFormat.currency(
    locale: 'en_NG',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _nairaFormat.format(amount);
  }
}

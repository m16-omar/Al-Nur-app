import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _nairaFormat = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _nairaFormat.format(amount);
  }
}

import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(dynamic value) {
    if (value == null) return 'Rp 0';
    
    num number = 0;
    if (value is num) {
      number = value;
    } else if (value is String) {
      number = num.tryParse(value) ?? 0;
    }
    
    return _rupiahFormat.format(number);
  }
}
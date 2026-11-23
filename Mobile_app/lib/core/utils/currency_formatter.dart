import 'package:intl/intl.dart';

/// Utility class for formatting currency and financial figures.
class CurrencyFormatter {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _plainInrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );

  /// Formats amount as `₹1,550.00`
  static String format(num amount) {
    return _inrFormat.format(amount).trim();
  }

  /// Formats amount as `1,550.00` (without currency symbol)
  static String formatPlain(num amount) {
    return _plainInrFormat.format(amount).trim();
  }

  /// Formats RP points as `295.55 RP`
  static String formatRp(num amount) {
    return '${amount.toStringAsFixed(2)} RP';
  }

  /// Compact format for large numbers: `1.5K`, `2.4M`
  static String formatCompact(num amount) {
    return NumberFormat.compact(locale: 'en_IN').format(amount);
  }
}


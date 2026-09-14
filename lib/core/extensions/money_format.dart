import 'package:intl/intl.dart';

/// Bangladeshi Taka formatting: `৳` symbol and 2-2-3 (lakh / crore) digit
/// grouping — e.g. `1234567.5` → `৳ 12,34,567.50`. Codes and money render in
/// `AppTypography.mono(...)`; this just produces the string.
extension MoneyFormat on num {
  static final NumberFormat _bdt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '৳ ',
    decimalDigits: 2,
  );

  static final NumberFormat _bdtWhole = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '৳ ',
    decimalDigits: 0,
  );

  /// `৳ 12,34,567.50`. Pass `decimals: false` for `৳ 12,34,568` (no paisa).
  String toBdt({bool decimals = true}) =>
      (decimals ? _bdt : _bdtWhole).format(this);
}

import 'package:bizops360_mobile/core/extensions/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MoneyFormat.toBdt', () {
    test('groups digits 2-2-3 with the taka symbol', () {
      expect(1234567.5.toBdt(), '৳ 12,34,567.50');
      expect(90000.toBdt(), '৳ 90,000.00');
    });

    test('decimals: false drops the paisa', () {
      expect(1234567.toBdt(decimals: false), '৳ 12,34,567');
    });
  });
}

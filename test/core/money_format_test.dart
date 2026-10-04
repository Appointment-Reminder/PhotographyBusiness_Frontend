import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/core/utils/money_format.dart';

void main() {
  test('whole amounts print without decimals', () {
    expect(formatAmount(80), '80');
    expect(formatAmount(80.0), '80');
  });

  test('fractional amounts print with two decimals', () {
    expect(formatAmount(12.5), '12.50');
    expect(formatAmount(0.256), '0.26');
  });
}

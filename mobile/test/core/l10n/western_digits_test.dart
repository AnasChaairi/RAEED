import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:raeed/core/l10n/western_digits.dart';

void main() {
  test('Arabic dates format with Western digits after startup', () async {
    await initializeDateFormatting('ar');
    useWesternDigitsForArabic();

    final formatted = DateFormat(
      'd MMMM y',
      'ar_MA',
    ).format(DateTime(2026, 9, 21));

    expect(formatted, contains('21'));
    expect(formatted, contains('2026'));
    expect(formatted, isNot(contains('٢')));
  });
}

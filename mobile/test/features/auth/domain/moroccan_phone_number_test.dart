import 'package:flutter_test/flutter_test.dart';
import 'package:raeed/features/auth/domain/moroccan_phone_number.dart';

/// Sign-in is phone + OTP with no password, so this type is the front door.
/// A number it wrongly rejects is a family locked out of their child's
/// attendance; a number it wrongly accepts is an OTP sent nowhere.
void main() {
  group('accepts the forms a Moroccan user actually types', () {
    const expected = '+212612345678';

    for (final input in <String>[
      '0612345678', // locally dialled, with the trunk 0
      '612345678', // national significant number
      '+212612345678', // E.164
      '00212612345678', // international prefix
      '+212 612 345 678', // spaced
      '0612-345-678', // dashed
      '(+212) 612.345.678', // punctuated
      ' 0612345678 ', // padded
    ]) {
      test('"$input"', () {
        expect(MoroccanPhoneNumber.tryParse(input)?.e164, expected);
      });
    }

    test('Arabic-Indic digits, which the default keyboard produces', () {
      // Rejecting ٠٦… would look like the app refusing the user's own number.
      expect(MoroccanPhoneNumber.tryParse('٠٦١٢٣٤٥٦٧٨')?.e164, expected);
    });

    test('extended Arabic-Indic digits', () {
      expect(MoroccanPhoneNumber.tryParse('۰۶۱۲۳۴۵۶۷۸')?.e164, expected);
    });

    test('a 07 mobile number', () {
      expect(MoroccanPhoneNumber.tryParse('0712345678')?.e164, '+212712345678');
    });
  });

  group('rejects', () {
    for (final input in <String>[
      '', // empty
      '   ', // whitespace
      '06123456', // too short
      '06123456789', // too long
      '0512345678', // landline: an OTP by SMS/WhatsApp never arrives (ACC-03)
      '0812345678', // not a mobile range
      'not a number',
      '+33612345678', // French number
    ]) {
      test('"$input"', () {
        expect(MoroccanPhoneNumber.tryParse(input), isNull);
        expect(MoroccanPhoneNumber.isValid(input), isFalse);
      });
    }
  });

  group('masking', () {
    late MoroccanPhoneNumber phone;

    setUp(() => phone = MoroccanPhoneNumber.tryParse('0612345678')!);

    test('shows enough to recognise, not enough to dial', () {
      expect(phone.masked, '+212 6•• ••• •78');
    });

    test('hides the middle digits entirely', () {
      expect(phone.masked, isNot(contains('12345')));
      expect(phone.masked, isNot(contains('3456')));
    });

    test('toString masks too, so an accidental log is harmless', () {
      // specs/10-security-and-privacy.md: raw phone numbers must never reach
      // application logs or Sentry. toString is what ends up in a breadcrumb
      // or an assertion message by accident.
      expect(phone.toString(), isNot(contains('612345678')));
      expect(phone.toString(), contains('•'));
    });
  });

  group('value semantics', () {
    test('the same number in different formats is the same value', () {
      expect(
        MoroccanPhoneNumber.tryParse('0612345678'),
        MoroccanPhoneNumber.tryParse('+212 612 345 678'),
      );
      expect(
        MoroccanPhoneNumber.tryParse('0612345678').hashCode,
        MoroccanPhoneNumber.tryParse('00212612345678').hashCode,
      );
    });

    test('different numbers are different values', () {
      expect(
        MoroccanPhoneNumber.tryParse('0612345678'),
        isNot(MoroccanPhoneNumber.tryParse('0612345679')),
      );
    });
  });
}

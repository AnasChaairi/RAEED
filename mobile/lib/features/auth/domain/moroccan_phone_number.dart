/// The one place a phone number is parsed, normalised, and masked.
///
/// RAEED signs people in with a phone number and nothing else
/// (`specs/10-security-and-privacy.md` — there is no password), so the number
/// is both the credential and the most identifying piece of data the login
/// flow touches. Two rules follow, and both are enforced by this type rather
/// than by each caller remembering them:
///
/// * The wire format is always E.164 (`+2126XXXXXXXX`), matching
///   `app_user.phone` in `specs/03-domain-model/schema.sql`. Whatever the user
///   typed — spaces, dashes, `00212`, a leading `0`, Arabic-Indic digits — is
///   normalised once, here.
/// * A number is **never** rendered back to the user in full. `masked` is the
///   only display form, so a screenshot, a screen recording, or someone
///   reading over a shoulder in a waiting room does not carry a full number.
library;

import 'package:meta/meta.dart';

/// A validated Moroccan mobile number.
///
/// Construct with [tryParse]; the private constructor makes an unvalidated
/// instance unrepresentable, so anything holding one of these is holding a
/// number the API will accept.
@immutable
final class MoroccanPhoneNumber {
  const MoroccanPhoneNumber._(this._nationalDigits);

  /// The nine significant digits, without the country code — `612345678`.
  final String _nationalDigits;

  /// Morocco's country calling code.
  static const String countryCode = '212';

  /// The number of significant digits after the country code.
  ///
  /// Moroccan mobile numbers are nine digits beginning with 6 or 7 (the ANRT
  /// mobile ranges). Landlines (5) are deliberately rejected: an OTP arrives
  /// by SMS or WhatsApp (`ACC-03`), neither of which reaches a landline, so
  /// accepting one would produce a login that silently never completes.
  static const int nationalDigitCount = 9;

  /// Parses [input] in any of the forms a Moroccan user actually types,
  /// returning null when it is not a valid mobile number.
  ///
  /// Accepted: `0612345678`, `612345678`, `+212612345678`, `00212612345678`,
  /// each with any mix of spaces, dashes, dots, or parentheses, and with
  /// Arabic-Indic digits (`٠١٢٣٤٥٦٧٨٩`) in place of Latin ones — the Arabic
  /// keyboard is the default on many of these devices, and rejecting `٠٦…`
  /// would look like the app was refusing the user's own number.
  static MoroccanPhoneNumber? tryParse(String input) {
    final digits = _toLatinDigits(input);
    if (digits.isEmpty) return null;

    var national = digits;
    if (national.startsWith('00$countryCode')) {
      national = national.substring(2 + countryCode.length);
    } else if (national.startsWith(countryCode) &&
        national.length > nationalDigitCount) {
      national = national.substring(countryCode.length);
    }
    // A locally-dialled number carries a trunk `0` the E.164 form drops.
    if (national.length == nationalDigitCount + 1 && national.startsWith('0')) {
      national = national.substring(1);
    }

    if (national.length != nationalDigitCount) return null;
    if (!_isMobilePrefix(national)) return null;
    return MoroccanPhoneNumber._(national);
  }

  /// Whether [input] would parse. Used by form validators, which want the
  /// answer without the object.
  static bool isValid(String input) => tryParse(input) != null;

  /// The E.164 form sent to the API — `+212612345678`.
  ///
  /// This is the only form that leaves the device, and it goes nowhere but the
  /// request body: `specs/10-security-and-privacy.md` forbids raw phone numbers
  /// in application logs and Sentry.
  String get e164 => '+$countryCode$_nationalDigits';

  /// The only form that may be shown to a user — `+212 6•• ••• •78`.
  ///
  /// Keeps the leading mobile digit and the final two, which is enough for
  /// someone to recognise their own number, and not enough for a bystander to
  /// dial it.
  String get masked {
    final first = _nationalDigits.substring(0, 1);
    final last = _nationalDigits.substring(nationalDigitCount - 2);
    return '+$countryCode $first•• ••• •$last';
  }

  static bool _isMobilePrefix(String national) =>
      national.startsWith('6') || national.startsWith('7');

  /// Keeps only digits, folding Arabic-Indic and Eastern Arabic-Indic digits
  /// onto their Latin equivalents.
  static String _toLatinDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.writeCharCode(rune);
      } else if (rune >= 0x0660 && rune <= 0x0669) {
        // Arabic-Indic ٠–٩
        buffer.writeCharCode(rune - 0x0660 + 0x30);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        // Extended Arabic-Indic ۰–۹
        buffer.writeCharCode(rune - 0x06F0 + 0x30);
      }
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoroccanPhoneNumber && other._nationalDigits == _nationalDigits;

  @override
  int get hashCode => _nationalDigits.hashCode;

  /// Prints the masked form, never the full number.
  ///
  /// `toString` is what ends up in a debug log, a Sentry breadcrumb, or an
  /// assertion message by accident. Masking here means the accident is
  /// harmless.
  @override
  String toString() => 'MoroccanPhoneNumber($masked)';
}

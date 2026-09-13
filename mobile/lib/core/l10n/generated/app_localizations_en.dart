// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'RAEED';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonBack => 'Back';

  @override
  String get errorNetworkTitle => 'Can\'t connect';

  @override
  String get errorNetworkBody =>
      'Check your internet connection and try again.';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorGenericBody =>
      'We couldn\'t complete that. Try again in a moment.';

  @override
  String get errorForbiddenTitle => 'Not available to you';

  @override
  String get errorForbiddenBody =>
      'You don\'t have permission to view this. Contact the academy\'s administration if you think this is a mistake.';

  @override
  String get errorSessionExpiredTitle => 'Session expired';

  @override
  String get errorSessionExpiredBody => 'Please sign in again.';

  @override
  String get errorContractTitle => 'Update required';

  @override
  String get errorContractBody =>
      'This version of the app is no longer compatible with the server. Please update it.';

  @override
  String get offlineBannerMessage =>
      'You\'re offline. Showing the last saved data.';

  @override
  String get offlineRefreshFailed => 'Couldn\'t refresh';

  @override
  String get loginTitle => 'Welcome to RAEED';

  @override
  String get loginSubtitle =>
      'Enter your phone number to receive a sign-in code.';

  @override
  String get loginPhoneLabel => 'Phone number';

  @override
  String get loginPhoneHint => '+212 6XX XXX XXX';

  @override
  String get loginPhoneInvalid => 'Enter a valid phone number.';

  @override
  String get loginRequestCode => 'Send sign-in code';

  @override
  String get loginNoAccountNotice =>
      'Accounts are created by the academy\'s administration only. If you don\'t have one, get in touch with them.';

  @override
  String get otpTitle => 'Sign-in code';

  @override
  String otpSentTo(String phone) {
    return 'We sent a six-digit code to $phone.';
  }

  @override
  String get otpCodeLabel => 'Code';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpInvalid => 'That code is wrong or has expired.';

  @override
  String get otpRateLimited =>
      'You\'ve requested too many codes. Try again in an hour.';

  @override
  String get otpResend => 'Resend code';

  @override
  String otpResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Resend in $seconds seconds',
      one: 'Resend in $seconds second',
    );
    return '$_temp0';
  }

  @override
  String get consentTitle => 'Privacy and image rights';

  @override
  String get consentIntro =>
      'Before you continue, we need your agreement to the privacy policy and an image-rights level for each child.';

  @override
  String get consentPrivacyPolicyAccept => 'I agree to the privacy policy';

  @override
  String get consentPrivacyPolicyRead => 'Read the privacy policy';

  @override
  String get consentImageRightsTitle => 'Image rights';

  @override
  String consentImageRightsForChild(String childName) {
    return 'Image rights for $childName';
  }

  @override
  String get consentImageRightsAllowed => 'Allowed';

  @override
  String get consentImageRightsAllowedHelp =>
      'The child\'s photos may be published in the app and on the academy\'s official channels.';

  @override
  String get consentImageRightsAppOnly => 'In the app only';

  @override
  String get consentImageRightsAppOnlyHelp =>
      'The child\'s photos are visible inside the app only, and published nowhere else.';

  @override
  String get consentImageRightsNotAllowed => 'Not allowed';

  @override
  String get consentImageRightsNotAllowedHelp =>
      'No photo of the child will be published anywhere.';

  @override
  String get consentChangeLater =>
      'You can change this at any time in the child\'s settings.';

  @override
  String get consentSubmit => 'Save consents';

  @override
  String get navHome => 'Home';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navMessages => 'Messages';

  @override
  String get navMemories => 'Memories';

  @override
  String get navMore => 'More';

  @override
  String get navGroups => 'Groups';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get roleParent => 'Parent';

  @override
  String get roleEducator => 'Educator';

  @override
  String get roleExecutive => 'Executive';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleSwitchTitle => 'Switch role';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'The link you opened is no longer valid.';

  @override
  String get notFoundGoHome => 'Back to home';
}

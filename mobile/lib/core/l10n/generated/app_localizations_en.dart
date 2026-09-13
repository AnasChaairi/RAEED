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

  @override
  String get homeTitleParent => 'My children';

  @override
  String get homeTitleEducator => 'My groups';

  @override
  String get homeTitleExecutive => 'Children';

  @override
  String get homeEmptyTitle => 'No child is linked to your account';

  @override
  String get homeEmptyBody =>
      'Please contact the academy\'s administration to link your child to your account.';

  @override
  String childAgeYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years',
      one: '$years year',
    );
    return '$_temp0';
  }

  @override
  String get childNoSessionToday => 'No session today';

  @override
  String childNextSession(String when) {
    return 'Next session: $when';
  }

  @override
  String get statusAwaitingAnswer => 'Presence confirmation needed';

  @override
  String get statusPresenceConfirmed => 'Presence confirmed';

  @override
  String get statusPresenceDeclined => 'Absence declared';

  @override
  String get statusPresenceLate => 'Will be late';

  @override
  String get statusPresent => 'Present';

  @override
  String get statusLate => 'Late';

  @override
  String get statusAbsent => 'Absent';

  @override
  String get statusExcused => 'Excused absence';

  @override
  String get statusUnknown => '—';

  @override
  String get absenceAlertTitle => 'Absent without notice';

  @override
  String get healthAlertBadgeLabel => 'Health alert — tap to view';

  @override
  String get announcementsStripTitle => 'Announcements';

  @override
  String get announcementUrgent => 'Urgent';

  @override
  String get announcementsEmpty => 'No announcements right now';

  @override
  String get childProfileTitle => 'Child profile';

  @override
  String get childProfileGroupLabel => 'Group';

  @override
  String get childProfileHealthTitle => 'Health information';

  @override
  String get childProfileNoHealthInfo => 'No health information recorded.';

  @override
  String get childProfileComingSoon => 'This section is coming soon.';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get childTabSchedule => 'Schedule';

  @override
  String get childTabAttendance => 'Attendance';

  @override
  String get childTabHomework => 'Homework';

  @override
  String get childTabMaterials => 'Materials';
}

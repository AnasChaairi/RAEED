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
  String get errorLastGuardian =>
      'This guardian can\'t be unlinked: a child would be left without one. Add another guardian first.';

  @override
  String get errorPhoneTaken =>
      'Another account already uses this phone number.';

  @override
  String get errorGuardianAlreadyLinked =>
      'This account is already a guardian of these children.';

  @override
  String get errorNoActiveSeason =>
      'No active season. Open one in Structure, then create the group.';

  @override
  String get errorNoBranch =>
      'No branch yet. Add one in Structure, then create the group.';

  @override
  String get openStructure => 'Structure';

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
  String get loginPhoneLabel => 'Phone number';

  @override
  String get loginPhoneHint => '6XX XXX XXX';

  @override
  String get loginPhoneInvalid => 'Enter a valid phone number.';

  @override
  String get loginNoAccountNotice =>
      'Accounts are created by the academy\'s administration only. If you don\'t have one, get in touch with them.';

  @override
  String get loginSubtitle => 'Enter your phone number and password.';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordRule => '6 letters or digits';

  @override
  String get loginPasswordInvalid =>
      'The password is exactly 6 letters or digits.';

  @override
  String get loginPasswordShow => 'Show password';

  @override
  String get loginPasswordHide => 'Hide password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginInvalidCredentials =>
      'Phone number or password is not correct.';

  @override
  String get loginRateLimited =>
      'Too many failed attempts. Try again in 15 minutes.';

  @override
  String get morePassword => 'Change password';

  @override
  String get pwdTitle => 'Change password';

  @override
  String get pwdIntro =>
      'A password is 6 letters or digits. Enter the current one, then the new one twice.';

  @override
  String get pwdCurrent => 'Current password';

  @override
  String get pwdNew => 'New password';

  @override
  String get pwdConfirm => 'Confirm new password';

  @override
  String get pwdMismatch => 'The two passwords do not match.';

  @override
  String get pwdWrongCurrent => 'The current password is not correct.';

  @override
  String get pwdSave => 'Save';

  @override
  String get pwdSavedToast => 'Password changed';

  @override
  String get handoverTitle => 'Temporary passwords';

  @override
  String get handoverIntro =>
      'Hand them to the guardian in person. They are shown once and never sent.';

  @override
  String get handoverExisting =>
      'Already had an account — their password is unchanged.';

  @override
  String get handoverDone => 'Handed over';

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
  String get statusScheduled => 'Session today';

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
  String get childHealthAllergies => 'Allergies';

  @override
  String get childHealthConditions => 'Conditions';

  @override
  String get childHealthMedications => 'Medication';

  @override
  String get childHealthDiet => 'Dietary notes';

  @override
  String get childHealthOther => 'Other';

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

  @override
  String get attendanceTitle => 'Attendance';

  @override
  String get attendancePresent => 'Present';

  @override
  String get attendanceLate => 'Late';

  @override
  String get attendanceAbsent => 'Absent';

  @override
  String get attendanceExcused => 'Excused';

  @override
  String get attendanceNotMarked => 'Not marked';

  @override
  String attendanceSummaryConfirmed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count confirmed',
      one: '$count confirmed',
    );
    return '$_temp0';
  }

  @override
  String attendanceSummaryAbsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count absent',
      one: '$count absent',
    );
    return '$_temp0';
  }

  @override
  String attendanceSummaryNoAnswer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count no answer',
      one: '$count no answer',
    );
    return '$_temp0';
  }

  @override
  String attendanceMarkedOf(int marked, int total) {
    return '$marked of $total marked';
  }

  @override
  String get attendanceMarkRemainingPresent => 'Mark remaining present';

  @override
  String get attendanceSubmit => 'Submit';

  @override
  String get attendanceSubmitted => 'Attendance submitted';

  @override
  String get attendanceEmptyGroup => 'No children in this group yet';

  @override
  String get attendanceOfflineSaved => 'Saved on this device, will sync';

  @override
  String attendancePendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marks waiting to send',
      one: '$count mark waiting to send',
    );
    return '$_temp0';
  }

  @override
  String get attendanceConflictTitle => 'Marking conflict';

  @override
  String attendanceConflictBody(String attempted, String server) {
    return 'You marked $attempted, but $server was recorded first from another device.';
  }

  @override
  String get attendanceConflictKeepMine => 'Keep mine';

  @override
  String get attendanceConflictKeepServer => 'Keep recorded';

  @override
  String get attendanceUnknownChild =>
      'This child is no longer in this group, so the mark was not recorded.';

  @override
  String get presenceTitle => 'Presence confirmation';

  @override
  String presenceQuestion(String childName, String when) {
    return 'Will $childName attend the $when session?';
  }

  @override
  String get presenceYes => 'Yes';

  @override
  String get presenceNo => 'No';

  @override
  String get presenceLate => 'Will be late';

  @override
  String get presenceReasonPrompt => 'Reason (optional)';

  @override
  String get presenceReasonIllness => 'Illness';

  @override
  String get presenceReasonTravel => 'Travel';

  @override
  String get presenceReasonExam => 'Exam';

  @override
  String get presenceReasonOther => 'Other reason';

  @override
  String get presenceOtherNoteLabel => 'Tell us the reason';

  @override
  String get presenceAnswered => 'Thanks, your answer is recorded';

  @override
  String get presenceNoneOutstanding => 'No confirmations outstanding';

  @override
  String get brandTagline => 'Upright in himself, a force for good in others';

  @override
  String consentStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get consentChoose => 'Choose';

  @override
  String get homeGreeting => 'Assalamu alaykum';

  @override
  String get homeTodaySessions => 'Today\'s sessions';

  @override
  String get homeNotifications => 'Notifications';

  @override
  String homeNotificationsWithUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications, $count unread',
      one: 'Notifications, $count unread',
    );
    return '$_temp0';
  }

  @override
  String get homeNeedsYourReply => 'Needs your reply';

  @override
  String get execTabDashboard => 'Dashboard';

  @override
  String get execTabAnnouncements => 'Announcements';

  @override
  String get execTabMessages => 'Messages';

  @override
  String get execTabMemories => 'Memories';

  @override
  String get execTabGroups => 'Groups';

  @override
  String get execNavLabel => 'Navigation';

  @override
  String get execMore => 'More';

  @override
  String get execScopeAllBranches => 'All branches';

  @override
  String get execScopeRestricted => 'Your branch only (restricted)';

  @override
  String execStaleOffline(String time) {
    return 'Offline — showing the version from $time.';
  }

  @override
  String execStaleRefreshFailed(String time) {
    return 'Couldn\'t refresh — showing the version from $time.';
  }

  @override
  String get recordedActionMarker =>
      'This action is recorded under your name, with the time and device.';

  @override
  String get recordedShort => 'recorded';

  @override
  String dashSessionsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions today',
      one: '1 session today',
      zero: 'No sessions today',
    );
    return '$_temp0';
  }

  @override
  String dashSessionsBreakdown(int live, int upcoming) {
    return '$live live · $upcoming upcoming';
  }

  @override
  String get dashNeedsAttention => 'Needs your attention';

  @override
  String get dashNoAlertsTitle => 'Nothing needs your attention today';

  @override
  String get dashNoAlertsBody => 'No alerts and no pending requests right now.';

  @override
  String get severityDanger => 'Danger';

  @override
  String get severityWarning => 'Warning';

  @override
  String get severityInfo => 'Info';

  @override
  String get statChildren => 'Children';

  @override
  String get statFamilies => 'Families';

  @override
  String get statGroups => 'Groups';

  @override
  String get statEducators => 'Educators';

  @override
  String get dashWeeklyAttendance => 'This week\'s attendance';

  @override
  String get dashTooLittleData => 'Not enough data yet';

  @override
  String get dashTodaySessions => 'Today\'s sessions';

  @override
  String get dashNoSessionsToday => 'No sessions today';

  @override
  String get sessionAttendanceRecorded => 'Recorded';

  @override
  String get sessionAttendanceNotRecorded => 'Not recorded';

  @override
  String get sessionAttendanceLive => 'Live';

  @override
  String get sessionAttendanceUpcoming => 'Upcoming';

  @override
  String get annNew => 'New announcement';

  @override
  String get annStatePublished => 'Published';

  @override
  String get annStateScheduled => 'Scheduled';

  @override
  String get annStateDraft => 'Draft';

  @override
  String get annStateExpired => 'Expired';

  @override
  String annReadBy(int percent) {
    return 'Read by $percent%';
  }

  @override
  String get annPinned => 'Pinned';

  @override
  String get annEmptyTitle => 'No announcements yet';

  @override
  String get annEmptyBody =>
      'Create the first announcement for guardians or educators.';

  @override
  String annMetaPublished(String when) {
    return 'Published $when';
  }

  @override
  String annMetaScheduled(String when) {
    return 'Scheduled $when';
  }

  @override
  String annMetaExpires(String when) {
    return 'Expires $when';
  }

  @override
  String get annFieldTitle => 'Title';

  @override
  String get annFieldBody => 'Text';

  @override
  String get annTitleHint => 'Announcement title';

  @override
  String get annBodyHint => 'Announcement text';

  @override
  String get annFieldAudience => 'Audience';

  @override
  String get annChange => 'Change';

  @override
  String get annPublishTiming => 'Publish';

  @override
  String get annPublishNow => 'Now';

  @override
  String get annExpires => 'Expires';

  @override
  String get annNoExpiry => 'No expiry';

  @override
  String get annUrgentTitle => 'Urgent priority';

  @override
  String get annUrgentBody =>
      'Instant notification + SMS to anyone who doesn\'t open the app. Emergencies only.';

  @override
  String get annSend => 'Publish announcement';

  @override
  String annSendUrgent(int reach) {
    return 'Send urgent · $reach';
  }

  @override
  String get annAudienceSheetTitle => 'Who receives this?';

  @override
  String get audAll => 'Everyone';

  @override
  String get audParents => 'Guardians only';

  @override
  String get audEducators => 'Educators only';

  @override
  String get audCategories => 'Chosen categories';

  @override
  String get audCategoriesHeading => 'Categories';

  @override
  String audPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
      zero: 'nobody',
    );
    return '$_temp0';
  }

  @override
  String get audDone => 'Done';

  @override
  String get audSummaryAll => 'Every guardian and educator in your scope.';

  @override
  String get audSummaryParents => 'Every guardian of an enrolled child.';

  @override
  String get audSummaryEducators => 'Educators, without guardians.';

  @override
  String audSummaryCategories(String names) {
    return 'Guardians of children in: $names.';
  }

  @override
  String get audSummaryNone => 'No category chosen — nobody will receive it.';

  @override
  String get annUrgentConfirmKind => 'High reach — critical channel';

  @override
  String annUrgentConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Send urgent to $count people?',
      one: 'Send urgent to 1 person?',
      zero: 'Send urgent to nobody?',
    );
    return '$_temp0';
  }

  @override
  String get annUrgentConfirmBody =>
      'Instant notification to everyone, then an SMS to anyone who doesn\'t open the app within 10 minutes, at the association\'s cost. Emergencies only.';

  @override
  String get annUrgentConfirmLog =>
      'The urgent send is recorded under your name, with the audience and cost.';

  @override
  String get annUrgentConfirmCta => 'Yes, send urgent';

  @override
  String annPublished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Announcement published to $count people',
      one: 'Announcement published to 1 person',
      zero: 'Announcement published',
    );
    return '$_temp0';
  }

  @override
  String annPublishedUrgent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Urgent announcement sent to $count people',
      one: 'Urgent announcement sent to 1 person',
      zero: 'Urgent announcement sent',
    );
    return '$_temp0';
  }

  @override
  String get annUrgentTag => 'Urgent';

  @override
  String get msgOversightSubtitle =>
      'Oversight — reading conversations you are not a member of is recorded.';

  @override
  String get msgSectionChildren => 'Child conversations';

  @override
  String get msgSectionStaff => 'Educator channels';

  @override
  String get msgSectionExecutives => 'Executives';

  @override
  String get msgEmptyTitle => 'No conversations yet';

  @override
  String get msgEmptyBody =>
      'A conversation is created for each child at enrolment.';

  @override
  String get msgOversightNotice =>
      'You are not a member here — your reading is recorded oversight, known to the members.';

  @override
  String msgReportedBy(String name, String reason) {
    return 'Reported by $name: $reason';
  }

  @override
  String get msgHide => 'Hide';

  @override
  String get msgDismissReport => 'Dismiss report';

  @override
  String msgHiddenStub(String name, String time) {
    return 'Hidden · by $name $time · visible to executives only';
  }

  @override
  String get msgComposerHint => 'Write as an executive…';

  @override
  String get msgSend => 'Send';

  @override
  String get msgVoiceNote => 'Voice note';

  @override
  String get msgHideConfirmKind => 'Hide — reversible';

  @override
  String msgHideConfirmTitle(String name) {
    return 'Hide $name\'s message?';
  }

  @override
  String get msgHideConfirmBody =>
      'It disappears for members and stays visible to executives, marked \"hidden\". Nothing is deleted. The sender is told why.';

  @override
  String get msgHideConfirmLog =>
      'The hide is recorded under your name and closes the report.';

  @override
  String get msgHideConfirmCta => 'Hide message';

  @override
  String get msgHiddenToast => 'Message hidden';

  @override
  String get msgReportDismissedToast => 'Report dismissed';

  @override
  String get msgThreadEmpty => 'No messages yet';

  @override
  String get memTitle => 'Memories review';

  @override
  String memQueueLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts waiting for you',
      one: '1 post waiting for you',
      zero: 'Nothing waiting for you',
    );
    return '$_temp0';
  }

  @override
  String get memModeApproveFirst => 'Approve before publishing';

  @override
  String get memModePublishThenReview => 'Publish then review';

  @override
  String get memModeUnset => 'Review mode not set yet';

  @override
  String get memBlockedBadge =>
      'Blocked — image rights changed after publishing';

  @override
  String memBlockedBody(String name) {
    return '$name is now \"not allowed\". Remove the photo or keep the post hidden.';
  }

  @override
  String memCounter(int index, int count) {
    return '$index / $count';
  }

  @override
  String get imageRightsAllowed => 'Allowed';

  @override
  String get imageRightsAppOnly => 'In-app only';

  @override
  String get imageRightsNotAllowed => 'Not allowed';

  @override
  String imageRightsLabel(String level) {
    return 'Image rights: $level';
  }

  @override
  String get memHide => 'Hide';

  @override
  String get memEdit => 'Edit';

  @override
  String get memApprove => 'Approve';

  @override
  String get memKeep => 'Keep';

  @override
  String get memReapprove => 'Re-approve';

  @override
  String get memHideHint =>
      'Hiding is not deleting — the post stays visible to executives.';

  @override
  String get memAllReviewedTitle => 'You\'ve reviewed everything';

  @override
  String get memAllReviewedBody => 'No posts waiting for you.';

  @override
  String get memWall => 'The wall';

  @override
  String memAlbumPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
      zero: 'no posts',
    );
    return '$_temp0';
  }

  @override
  String get memNoAlbums => 'No albums this season';

  @override
  String get memApprovedToast => 'Post approved';

  @override
  String get memHiddenToast => 'Post hidden (not deleted)';

  @override
  String grpCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
      zero: 'no groups',
    );
    return '$_temp0';
  }

  @override
  String get grpEmptyTitle => 'No groups this season';

  @override
  String get grpEmptyBody => 'Groups are created from the web dashboard.';

  @override
  String get grpOverCapacity => 'Over capacity';

  @override
  String get grpTabSessions => 'Sessions';

  @override
  String get grpTabRoster => 'Roster';

  @override
  String get grpSessionsEmpty => 'No sessions yet';

  @override
  String get grpRosterEmpty => 'No children in this group';

  @override
  String get sessionEnded => 'Ended';

  @override
  String get sessionCancelled => 'Cancelled';

  @override
  String get sessionToday => 'Today';

  @override
  String reviewTitle(String group) {
    return 'Attendance — $group';
  }

  @override
  String reviewRecordedBy(String name, String time) {
    return 'Recorded by $name $time';
  }

  @override
  String get reviewCorrect => 'Correct';

  @override
  String get reviewGuardianNoAnswer => 'No answer';

  @override
  String get reviewGuardianConfirmed => 'Guardian confirmed';

  @override
  String get reviewGuardianDeclared => 'Guardian declared absent';

  @override
  String get reviewGuardianLate => 'Guardian said late';

  @override
  String reviewTrailOriginal(String status, String name, String time) {
    return 'Recorded $status — $name · $time';
  }

  @override
  String reviewTrailCorrected(String status, String name, String time) {
    return 'Corrected to $status — $name · $time';
  }

  @override
  String reviewTrailRefers(String id) {
    return 'Refers to #$id';
  }

  @override
  String get reviewTrailNotified => 'Guardians notified';

  @override
  String corrTitle(String name) {
    return 'Correct $name\'s attendance';
  }

  @override
  String get corrBody =>
      'A new record points at the original — nothing is erased. Visible to guardians and the educator.';

  @override
  String get corrNoteHint => 'Note (optional)';

  @override
  String get corrSave => 'Save correction';

  @override
  String get corrSavedToast => 'Correction record added';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifMarkAllRead => 'Mark all as read';

  @override
  String get notifFilterAll => 'All';

  @override
  String get notifFilterCritical => 'Critical';

  @override
  String get notifFilterRequests => 'Requests';

  @override
  String get notifFilterMemories => 'Memories';

  @override
  String get notifEmptyTitle => 'Nothing new';

  @override
  String get notifEmptyBody => 'You\'re up to date.';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
      zero: 'just now',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
      zero: 'just now',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'yesterday',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String get moreCurrentRole => 'Current role';

  @override
  String moreRolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'you have $count roles',
      one: 'you have 1 role',
      zero: 'no roles',
    );
    return '$_temp0';
  }

  @override
  String get roleHintExecutive => 'The dashboard and oversight of every group';

  @override
  String get roleHintAdmin =>
      'Everything an executive has, plus structure and user management';

  @override
  String get roleHintEducator => 'Attendance and homework for your groups';

  @override
  String get roleHintParent => 'Following your children';

  @override
  String get moreDarkMode => 'Dark mode';

  @override
  String get moreLanguage => 'Language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get moreCriticalChannel => 'Critical channel notifications';

  @override
  String get moreCriticalChannelLocked =>
      'Locked: absence alerts, urgent announcements and session changes within 24 hours always arrive.';

  @override
  String moreVersion(String version) {
    return 'Version $version';
  }

  @override
  String get moreTagline => 'صالح في نفسه، مصلح لغيره';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get moreChildren => 'Children';

  @override
  String get moreChildrenHint => 'Profiles and consents';

  @override
  String get moreManage => 'Families and groups';

  @override
  String get moreManageHint => 'New group · new family · assignment';

  @override
  String get moreReports => 'Reports and export';

  @override
  String get moreReportsHint => 'Attendance · educators · engagement';

  @override
  String get moreStructure => 'Structure';

  @override
  String get moreStructureHint => 'Seasons · categories · branches';

  @override
  String get moreLogs => 'Logs';

  @override
  String get moreLogsHint => 'Audit · health access';

  @override
  String get adminTag => 'Admin';

  @override
  String get moreAdminHint =>
      'Only an admin opens “Structure” and “Logs”. Any other attempt is refused and recorded.';

  @override
  String get moreSignOut => 'Sign out';

  @override
  String childrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count children',
      one: '1 child',
      zero: 'no children',
    );
    return '$_temp0';
  }

  @override
  String get childrenSearchHint => 'Search for a child';

  @override
  String get filterAll => 'All';

  @override
  String get childrenEmptyTitle => 'No children match';

  @override
  String get childrenEmptyBody => 'Try another search or category.';

  @override
  String attendanceShort(String ratio) {
    return 'attendance $ratio';
  }

  @override
  String get imageRightsLegend => 'Image rights:';

  @override
  String get childSeasonAttendance => 'Season attendance';

  @override
  String get childImageRightsTile => 'Image rights';

  @override
  String get healthSectionTitle => 'Health information';

  @override
  String get healthEveryViewLogged => 'Every view is recorded';

  @override
  String get healthCollapsedBody =>
      'There is a health alert. The content is folded on purpose: it shows on your request and the view is written to the health-access log.';

  @override
  String get healthNoneBody => 'No health alert recorded for this child.';

  @override
  String get healthShowButton => 'Show health information';

  @override
  String get healthConfirmTitle => 'This view will be recorded';

  @override
  String healthConfirmBody(String actor, String child) {
    return 'It will be recorded that $actor viewed $child\'s health data now. Do not open it without a reason.';
  }

  @override
  String get healthContinue => 'Continue';

  @override
  String get healthBack => 'Back';

  @override
  String get healthAlertTitle => 'Health alert';

  @override
  String healthRecordedAt(String time) {
    return 'recorded at $time';
  }

  @override
  String get healthFieldsPending =>
      'The detailed fields are settled after the CNDP filing.';

  @override
  String get healthCollapse => 'Collapse';

  @override
  String get healthAllergies => 'Allergies';

  @override
  String get healthConditions => 'Conditions';

  @override
  String get healthMedications => 'Medications';

  @override
  String get healthDietary => 'Dietary notes';

  @override
  String get healthSpecialNeeds => 'Special needs';

  @override
  String get guardiansTitle => 'Guardians';

  @override
  String get relMother => 'mother';

  @override
  String get relFather => 'father';

  @override
  String get relGuardian => 'guardian';

  @override
  String get guardianAccountActive => 'Active';

  @override
  String get guardianAccountPending => 'Not signed in yet';

  @override
  String guardianLastSeen(String when) {
    return 'last seen $when';
  }

  @override
  String get guardianReveal => 'Reveal';

  @override
  String get guardianRevealLogged =>
      'Every reveal is recorded under your name, with the time.';

  @override
  String get guardianRevealToast => 'Number reveal recorded under your name';

  @override
  String get consentsTitle => 'Consents';

  @override
  String get consentPrivacyLabel => 'Privacy policy';

  @override
  String consentVersionAt(int version, String when) {
    return 'v$version · $when';
  }

  @override
  String get consentImageRightsChangeable =>
      'The guardian can change it at any time';

  @override
  String get consentApproved => 'Approved';

  @override
  String get consentMissing => 'Not yet approved';

  @override
  String get childGroupsTitle => 'Groups';

  @override
  String get groupMainTag => 'main';

  @override
  String openChildThread(String name) {
    return 'Open $name\'s thread (oversight · recorded)';
  }

  @override
  String get manageTitle => 'Families and groups';

  @override
  String familiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count families',
      one: '1 family',
      zero: 'no families',
    );
    return '$_temp0';
  }

  @override
  String get manageTabUnassigned => 'Unassigned';

  @override
  String get manageTabFamilies => 'Families';

  @override
  String get manageTabGroups => 'Groups';

  @override
  String get unassignedHint =>
      'Enrolled with no main group. Tick children, then tap assign.';

  @override
  String get unassignedEmpty => 'Every child is in a group.';

  @override
  String assignCta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Assign $count children to a group…',
      one: 'Assign 1 child to a group…',
    );
    return '$_temp0';
  }

  @override
  String assignSheetTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Assign $count children to a group',
      one: 'Assign 1 child to a group',
    );
    return '$_temp0';
  }

  @override
  String assignWarn(int after, int capacity, String group) {
    return '$group would be $after of $capacity — shown as over capacity.';
  }

  @override
  String get assignLogged =>
      'The assignment is recorded under your name and guardians are told.';

  @override
  String assignTo(String group) {
    return 'Assign to $group';
  }

  @override
  String get assignPick => 'Choose a group';

  @override
  String get assignOverKind => 'Over capacity';

  @override
  String assignOverTitle(String group) {
    return 'Assign to $group over capacity?';
  }

  @override
  String get assignOverLog =>
      'The assignment and the overage are recorded under your name.';

  @override
  String get assignOverCta => 'Yes, assign';

  @override
  String assignedToast(int count, String group) {
    return '$count assigned to $group';
  }

  @override
  String get familyStatusActive => 'Active';

  @override
  String get familyStatusPartial => 'Some guardians';

  @override
  String get familyStatusPending => 'Invitation pending';

  @override
  String get familyResend => 'Resend invitation';

  @override
  String get familyResentToast => 'Invitation resent';

  @override
  String get familyAddChild => '+ child';

  @override
  String get familyNoGroup => 'no group';

  @override
  String get familiesEmpty => 'No families yet';

  @override
  String get newFamilyCta => '+ New family';

  @override
  String familyDetailSubtitle(int guardians, int children) {
    String _temp0 = intl.Intl.pluralLogic(
      guardians,
      locale: localeName,
      other: '$guardians guardians',
      one: '1 guardian',
    );
    String _temp1 = intl.Intl.pluralLogic(
      children,
      locale: localeName,
      other: '$children children',
      one: '1 child',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get familyGuardiansSection => 'Guardians';

  @override
  String get familyChildrenSection => 'Children';

  @override
  String get familyAddGuardian => '+ Another guardian';

  @override
  String get familyEditGuardian => 'Edit guardian';

  @override
  String get familyUnlinkGuardian => 'Unlink from family';

  @override
  String familyUnlinkConfirmTitle(String name) {
    return 'Unlink $name from the family?';
  }

  @override
  String get familyUnlinkConfirmBody =>
      'The children keep their other guardians, and the account stays, with no children. A child\'s last guardian can\'t be unlinked.';

  @override
  String get familyUnlinkRecorded => '⦿ The unlink is recorded in your name.';

  @override
  String get familyUnlinkCta => 'Unlink';

  @override
  String get familyUnlinkDone => 'Guardian unlinked from the family.';

  @override
  String get familyGuardianUpdated => 'Saved.';

  @override
  String get familyGuardianLinkedExisting =>
      'An existing account was linked to the children. Its password is unchanged.';

  @override
  String get familyGuardianLinked => 'Guardian linked to the children.';

  @override
  String get familyPhoneUnchangedHint =>
      'Leave empty to keep the current number';

  @override
  String get familyPhoneChangeWarning =>
      'Changing the number signs the guardian out on every device. They sign in again with the new number and the same password.';

  @override
  String get familyEditChild => 'Edit child';

  @override
  String get familyChildAdded => 'Child added to the family.';

  @override
  String get familyChildUpdated => 'Saved.';

  @override
  String get familyEditRecorded => '⦿ The change is recorded in your name.';

  @override
  String get familyNotFoundTitle => 'This family is no longer available';

  @override
  String get familyNotFoundBody =>
      'Its guardians may have changed from another device. Go back to the families list.';

  @override
  String get familyBackToList => 'To families';

  @override
  String get saveAction => 'Save';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get newGroupCta => '+ New group';

  @override
  String get groupAssignHere => '+ Assign children';

  @override
  String get newGroupTitle => 'New group';

  @override
  String get fieldName => 'Name';

  @override
  String get groupNameHint => 'e.g. الأشبال 3';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldCapacity => 'Capacity';

  @override
  String get fieldSchedule => 'Schedule';

  @override
  String get fieldEducators => 'Educators';

  @override
  String educatorLoad(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
      zero: 'no groups',
    );
    return '$_temp0';
  }

  @override
  String get fieldChildrenOptional =>
      'Children (optional) — from the unassigned list';

  @override
  String get checklistNameOk => '✓ Name';

  @override
  String get checklistNameMissing => '○ Name required';

  @override
  String get checklistCategoryMissing => '○ Category required';

  @override
  String get checklistEducatorOk => '✓ Educator';

  @override
  String get checklistEducatorMissing => '○ At least one educator';

  @override
  String checklistChildren(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '✓ $count children',
      one: '✓ 1 child',
      zero: '○ No children (fine)',
    );
    return '$_temp0';
  }

  @override
  String get checklistLogged => '⦿ recorded under your name';

  @override
  String createGroupCta(String name) {
    return 'Create “$name”';
  }

  @override
  String groupCreatedToast(String name) {
    return '“$name” created';
  }

  @override
  String get theGroup => 'the group';

  @override
  String get weekdaySun => 'Sunday';

  @override
  String get weekdayMon => 'Monday';

  @override
  String get weekdayTue => 'Tuesday';

  @override
  String get weekdayWed => 'Wednesday';

  @override
  String get weekdayThu => 'Thursday';

  @override
  String get weekdayFri => 'Friday';

  @override
  String get weekdaySat => 'Saturday';

  @override
  String get scheduleEditTitle => 'Weekly schedule';

  @override
  String get scheduleAddSlot => '+ Weekly slot';

  @override
  String get scheduleEmptyHint =>
      'No schedule yet: without one, no sessions are created for this group.';

  @override
  String get scheduleRecorded =>
      '⦿ The change is recorded in your name and the coming weeks\' sessions are created at once.';

  @override
  String get scheduleSavedToast => 'Schedule saved';

  @override
  String get newFamilyTitle => 'New family';

  @override
  String get reviewStepTitle => 'Review';

  @override
  String stepOfThree(int step) {
    return 'Step $step of 3';
  }

  @override
  String get guardianNameHint => 'Guardian\'s name';

  @override
  String get guardianPhoneHint => '6XX XXX XXX';

  @override
  String get addGuardian => '+ Another guardian';

  @override
  String childN(int n) {
    return 'Child $n';
  }

  @override
  String get remove => 'Remove';

  @override
  String get childNameHint => 'Child\'s name';

  @override
  String get dobLabel => 'Date of birth';

  @override
  String get dobPick => 'Pick a date';

  @override
  String get mainGroupLabel => 'Main group';

  @override
  String get groupLater => 'Later';

  @override
  String get groupFull => 'full';

  @override
  String get healthNotHere =>
      'Health information is entered by the guardian from their own account — not here.';

  @override
  String get addChild => '+ Another child';

  @override
  String get whatHappens => 'What will happen';

  @override
  String willInvite(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '• SMS invitation to $count guardians, who accept privacy and image rights before seeing anything.',
      one: '• SMS invitation to 1 guardian, who accepts privacy and image rights before seeing anything.',
    );
    return '$_temp0';
  }

  @override
  String get willShow =>
      '• The children appear to the guardian with group, schedule and educator.';

  @override
  String get willLog => '• ⦿ The creation is recorded under your name.';

  @override
  String unassignedWarn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '▲ $count children with no group — no educator sees them until assigned.',
      one: '▲ 1 child with no group — no educator sees them until assigned.',
    );
    return '$_temp0';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String createAndInvite(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Create and send $count invitations',
      one: 'Create and send 1 invitation',
      zero: 'Create',
    );
    return '$_temp0';
  }

  @override
  String familyCreatedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Family created · $count invitations',
      one: 'Family created · 1 invitation',
      zero: 'Family created',
    );
    return '$_temp0';
  }

  @override
  String get reportsTitle => 'Reports';

  @override
  String get repTabAttendance => 'Attendance';

  @override
  String get repTabEducators => 'Educators';

  @override
  String get repTabEngagement => 'Engagement';

  @override
  String get repTabExport => 'Export';

  @override
  String get repByEducator => 'Attendance by educator';

  @override
  String get repByCategory => 'By category';

  @override
  String get repRawNote => 'Rate with the raw count';

  @override
  String repPlanned(int delivered, int planned) {
    return 'planned/delivered $delivered/$planned';
  }

  @override
  String repOnTime(int ontime, int planned) {
    return 'on time $ontime of $planned';
  }

  @override
  String get repReplyUnknown => 'reply —';

  @override
  String get repActivated => 'Guardian accounts activated';

  @override
  String get repPresenceAnswers => 'Presence confirmations answered';

  @override
  String get repHomework => 'Homework done';

  @override
  String get selfReported => 'self-reported';

  @override
  String get repNotYet => 'Not available yet';

  @override
  String get repNoData => 'No data yet';

  @override
  String get exportIntro =>
      'Export the children list. Health fields are off by default.';

  @override
  String get exportName => 'Full name';

  @override
  String get exportDob => 'Date of birth';

  @override
  String get exportGroup => 'Category and group';

  @override
  String get exportGuardian => 'Guardian\'s name';

  @override
  String get exportPhone => 'Guardian\'s phone';

  @override
  String get exportConsent => 'Image rights';

  @override
  String get exportAllergies => 'Allergies';

  @override
  String get exportMedications => 'Medications';

  @override
  String get healthTag => 'health';

  @override
  String get exportLogged =>
      'The export is recorded under your name with the chosen fields.';

  @override
  String get exportContainsHealth =>
      'Contains health data — for the intended recipient only.';

  @override
  String exportCta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Create file · $count fields',
      one: 'Create file · 1 field',
    );
    return '$_temp0';
  }

  @override
  String get exportBusy => 'Preparing the file…';

  @override
  String get exportReady => 'File ready';

  @override
  String exportRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows',
      one: '1 row',
      zero: 'no rows',
    );
    return '$_temp0';
  }

  @override
  String get exportShare => 'Share file';

  @override
  String get exportLoggedToast => 'Export recorded under your name';

  @override
  String get structureTitle => 'Structure';

  @override
  String get strTabSeasons => 'Seasons';

  @override
  String get strTabCategories => 'Categories';

  @override
  String get strTabBranches => 'Branches';

  @override
  String get seasonActive => 'active';

  @override
  String get seasonArchived => 'archived';

  @override
  String get seasonArchive => 'Archive';

  @override
  String get seasonsNote => 'Seasons are archived, never deleted.';

  @override
  String get archiveKind => 'Archive — reversible';

  @override
  String archiveTitle(String label) {
    return 'Archive season $label?';
  }

  @override
  String get archiveBody =>
      'Groups and enrolments become read-only. Nothing is deleted.';

  @override
  String get archiveLog => 'The archive is recorded under your name.';

  @override
  String get archiveCta => 'Archive season';

  @override
  String get archivedToast => 'Season archived';

  @override
  String get catsOpenDecision =>
      'Age ranges and gender are the board\'s decision and not yet taken. The fields are empty on purpose.';

  @override
  String get catAgeGenderUnset => 'age/gender: not set';

  @override
  String catAgeRange(int min, int max) {
    return 'ages $min–$max';
  }

  @override
  String get genderBoys => 'boys';

  @override
  String get genderGirls => 'girls';

  @override
  String get genderMixed => 'mixed';

  @override
  String get branchesNote =>
      'One branch today. When a second is added, the branch picker appears for executives.';

  @override
  String get newBranch => '+ New branch';

  @override
  String get branchNameHint => 'Branch name';

  @override
  String get branchAddressHint => 'Address';

  @override
  String get branchCreatedToast => 'Branch created';

  @override
  String get newCategory => '+ New category';

  @override
  String get categoryNameHint => 'Category name';

  @override
  String get categoryCreatedToast => 'Category created';

  @override
  String get newSeason => '+ New season';

  @override
  String get seasonLabelHint => 'Season label, e.g. 2026-2027';

  @override
  String get seasonStartPick => 'Start date';

  @override
  String get seasonEndPick => 'End date';

  @override
  String get seasonCreatedToast => 'Season opened';

  @override
  String get adminOnlyTitle => 'This section is for admins only';

  @override
  String adminOnlyBody(String role) {
    return 'Your role: $role. Ask the association\'s president for it.';
  }

  @override
  String get adminOnlyLogged =>
      '⦿ The access attempt is recorded — that is normal.';

  @override
  String get logsTitle => 'Logs';

  @override
  String get logTabAudit => 'Audit';

  @override
  String get logTabHealth => 'Health access';

  @override
  String get logsAppendOnly =>
      '⦿ Append-only — no edits, no deletes. Retention:';

  @override
  String get retentionUnset => 'not set yet';

  @override
  String get healthLogIntro =>
      'Who viewed which child\'s health information and when — the promise made at every reveal.';

  @override
  String get logsEmpty => 'No entries yet';

  @override
  String get actionLogin => 'sign-in';

  @override
  String get actionCorrect => 'attendance correction';

  @override
  String get actionExport => 'export';

  @override
  String get actionHideMessage => 'message hidden';

  @override
  String get actionHealthView => 'health data viewed';

  @override
  String get actionPhoneReveal => 'phone revealed';

  @override
  String get actionAssign => 'assignment';

  @override
  String get actionCreate => 'created';

  @override
  String get actionUpdate => 'Edit';

  @override
  String get actionLink => 'Guardian linked';

  @override
  String get actionUnlink => 'Guardian unlinked';

  @override
  String get actionEmergencyCall => 'Emergency call';

  @override
  String get actionPublish => 'announcement published';

  @override
  String get actionApprovePost => 'post approved';

  @override
  String get actionHidePost => 'post hidden';

  @override
  String get actionOversightRead => 'oversight read';

  @override
  String get actionDenied => 'access denied';

  @override
  String get actionArchive => 'archive';

  @override
  String get actionDismissReport => 'report dismissed';

  @override
  String get actionInvite => 'invitation resent';

  @override
  String get actionOther => 'action';

  @override
  String get eduTabToday => 'Today';

  @override
  String get eduTabSessions => 'Sessions';

  @override
  String get eduTabGroups => 'Groups';

  @override
  String get eduTabMessages => 'Messages';

  @override
  String get eduTabMemories => 'Memories';

  @override
  String get eduGreetingMorning => 'Good morning';

  @override
  String get eduGreetingEvening => 'Good evening';

  @override
  String get todayNextSession => 'Next session';

  @override
  String todayInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count min',
      one: 'in 1 min',
      zero: 'now',
    );
    return '$_temp0';
  }

  @override
  String get todayLive => 'Live now';

  @override
  String get presTallyYes => 'Coming';

  @override
  String get presTallyLate => 'Late';

  @override
  String get presTallyNo => 'Not coming';

  @override
  String get presTallyNone => 'No answer';

  @override
  String get todayRecordAttendance => 'Record attendance';

  @override
  String todayAttendanceDone(String group) {
    return 'Attendance recorded — $group';
  }

  @override
  String todayAttendanceSummary(
    int present,
    int late,
    int excused,
    int absent,
  ) {
    return 'Present $present · late $late · excused $excused · absent $absent';
  }

  @override
  String get todaySessionSummaryCta => 'Session summary';

  @override
  String todayNoContent(String group, String time) {
    return 'No content yet for the $group · $time session — created from the schedule.';
  }

  @override
  String get todayAdd => 'Add';

  @override
  String get shortcutHomework => 'Homework';

  @override
  String get shortcutMemory => 'Memory';

  @override
  String get shortcutAnnouncement => 'Announcement';

  @override
  String get todayFromManagement => 'From management';

  @override
  String get todayAckCta => 'I’ve read this';

  @override
  String get todayAckDone => '✓ Read confirmed';

  @override
  String get todayNoSession => 'No session today';

  @override
  String todayNextOn(String date) {
    return 'Next: $date';
  }

  @override
  String get todayNoSessionsAtAll =>
      'No upcoming sessions — check your groups’ schedule with an executive.';

  @override
  String get presTitle => 'Presence confirmations';

  @override
  String presSubtitle(String group, String time, String sent) {
    return '$group · $time · sent $sent';
  }

  @override
  String presSubtitleNotSent(String group, String time) {
    return '$group · $time · not sent yet';
  }

  @override
  String get presPlanning => 'For planning (materials, snack, transport)';

  @override
  String presExpectedOf(int count) {
    return 'expected of $count';
  }

  @override
  String presRemind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remind those who haven’t answered ($count)',
      zero: 'Everyone answered',
    );
    return '$_temp0';
  }

  @override
  String get presRemindDone => '✓ Reminder sent';

  @override
  String presRemindNote(String time) {
    return 'The reminder is sent once — deadline $time';
  }

  @override
  String presRemindedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reminder sent to $count guardians',
      one: 'Reminder sent to 1 guardian',
      zero: 'No one to remind',
    );
    return '$_temp0';
  }

  @override
  String get presNotSent =>
      'No confirmation request was sent for this session.';

  @override
  String attTitle(String group) {
    return 'Attendance — $group';
  }

  @override
  String attSubtitle(String time, String title) {
    return '$time · $title · pre-filled from guardians’ answers';
  }

  @override
  String attUnmarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unmarked',
      zero: 'All marked',
    );
    return '$_temp0';
  }

  @override
  String attMarkRest(int count) {
    return '✓ Mark the remaining ($count) present';
  }

  @override
  String get attPresYes => 'Guardian confirmed';

  @override
  String get attPresLate => 'Late announced';

  @override
  String get attPresNo => 'Absence announced';

  @override
  String get attPresNone => 'Guardian hasn’t answered';

  @override
  String get attSave => 'Save attendance';

  @override
  String attSaveAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save · alert $count guardians',
      one: 'Save · alert 1 guardian',
    );
    return '$_temp0';
  }

  @override
  String get attSaveOffline => 'Save on this phone';

  @override
  String get attEditHint =>
      'Editable for 30 minutes, then through an executive';

  @override
  String get attUnmarkedKind => 'Before saving';

  @override
  String attUnmarkedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count children unmarked',
      one: '1 child unmarked',
    );
    return '$_temp0';
  }

  @override
  String get attUnmarkedBody =>
      'Give every child a status. If they really are not here, choose “absent” — their guardians are alerted at once.';

  @override
  String get attUnmarkedCta => 'Keep marking';

  @override
  String get attAlertKind => 'Safety alert to guardians';

  @override
  String attAlertTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count children’s guardians will be alerted now',
      one: '1 child’s guardians will be alerted now',
    );
    return '$_temp0';
  }

  @override
  String attAlertBody(String names) {
    return '$names: absent without notice. Their guardians get an immediate notification (and an SMS if they don’t open the app), because a guardian may believe their child is here.';
  }

  @override
  String get attAlertCta => 'Save and send the alert';

  @override
  String get attAlertCancel => 'Review the list';

  @override
  String attSavedAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Attendance saved · $count guardians alerted',
      one: 'Attendance saved · 1 guardian alerted',
    );
    return '$_temp0';
  }

  @override
  String get attStatusExcusedShort => 'Excused';

  @override
  String get sessTitle => 'Sessions';

  @override
  String sessWeekRange(String from, String to) {
    return 'Week $from – $to';
  }

  @override
  String get sessPrevWeek => 'Previous week';

  @override
  String get sessNextWeek => 'Next week';

  @override
  String get sessAllGroups => 'All my groups';

  @override
  String get sessStateUpcoming => 'Upcoming';

  @override
  String sessStateSoon(int count) {
    return 'in $count min';
  }

  @override
  String get sessStateLive => 'Live';

  @override
  String get sessStateNoContent => 'No content';

  @override
  String get sessStateMoved => 'Rescheduled';

  @override
  String sessMetaMaterials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materials',
      one: '1 material',
      zero: 'no materials',
    );
    return '$_temp0';
  }

  @override
  String get sessMetaHomework => 'homework';

  @override
  String get sessMetaGenerated => 'created from the schedule';

  @override
  String sessMetaWith(String name) {
    return 'with $name';
  }

  @override
  String get sessFooter =>
      'Sessions come from the group schedule — add content, or create an activity with +.';

  @override
  String get sessEmptyWeek => 'No sessions this week';

  @override
  String get activityNewTitle => 'New activity';

  @override
  String get activityNewSubtitle =>
      'A session, sport or workshop for one of your groups';

  @override
  String get activityGroup => 'Group';

  @override
  String get activityKind => 'Kind';

  @override
  String get activityKindSession => 'Session';

  @override
  String get activityKindSport => 'Sport';

  @override
  String get activityKindWorkshop => 'Workshop';

  @override
  String get activitySlot => 'When';

  @override
  String get activityPickDay => 'Pick a day';

  @override
  String get activityTitleHint => 'e.g. Friendly match, Calligraphy workshop';

  @override
  String get activityPlace => 'Place';

  @override
  String get activityPlaceHint => 'Hall, pitch…';

  @override
  String get activityContent => 'Content';

  @override
  String get activityContentHint => 'What will happen — guardians see this.';

  @override
  String get activityNotice =>
      'The group\'s guardians are notified at once and the activity appears on their children\'s schedule. ⦿ Recorded in your name.';

  @override
  String get activityCreateCta => 'Create and notify guardians';

  @override
  String get activityCreatedToast => 'Activity created, guardians notified';

  @override
  String get shortcutActivity => 'Activity';

  @override
  String get childScheduleEmpty => 'Nothing coming up for this group.';

  @override
  String get childScheduleNoGroup => 'The child is not in a group yet.';

  @override
  String get childScheduleCancelled => 'cancelled';

  @override
  String get sessObjectives => 'Objectives';

  @override
  String get sessMaterials => 'Materials';

  @override
  String get sessHomework => 'Homework';

  @override
  String get sessAddHomework => '+ homework';

  @override
  String sessHomeworkMeta(String target, String due, int done, int total) {
    return '$target · due $due · $done/$total done (self-reported)';
  }

  @override
  String get sessWholeGroup => 'Whole group';

  @override
  String get sessAttendanceDone => '✓ Attendance';

  @override
  String get sessSummaryDone => '✓ Summary';

  @override
  String get sessSummaryCta => 'Session summary';

  @override
  String get sessCancelCta => 'Cancel or reschedule';

  @override
  String get sessCancelledBanner =>
      '✕ This session was cancelled · guardians and team told';

  @override
  String sessMovedBanner(String when) {
    return '⏱ Moved to $when · guardians told';
  }

  @override
  String get sessNoObjectives => 'No objectives yet — add them through “edit”.';

  @override
  String get sessNoMaterials => 'No materials yet';

  @override
  String get sessNoHomework => 'No homework for this session';

  @override
  String get sessEdit => 'Edit';

  @override
  String get visBefore => 'Before the session';

  @override
  String get visAfter => 'After the session';

  @override
  String get visStaff => 'Staff only';

  @override
  String get matKindDocument => 'File';

  @override
  String get matKindImage => 'Photo';

  @override
  String get matKindAudio => 'Audio';

  @override
  String get matKindVideo => 'Video';

  @override
  String get matKindLink => 'Link';

  @override
  String get sessContentTitle => 'Session content';

  @override
  String sessContentSubtitle(String group, String time) {
    return '$group · $time · from the weekly schedule';
  }

  @override
  String get sessTitleHint => 'e.g. Quran circle — Surat al-Mulk';

  @override
  String get sessTheme => 'Theme';

  @override
  String get themeQuran => 'Quran';

  @override
  String get themeSira => 'Sira';

  @override
  String get themeAkhlaq => 'Character';

  @override
  String get themeHadith => 'Hadith';

  @override
  String get themeSkills => 'Skills';

  @override
  String get sessObjectivesHint => 'One objective per line…';

  @override
  String get sessMaterialsWho => 'Materials and who sees them';

  @override
  String get sessVideoLimit => 'Video ≤ 50 MB · long ones as a link';

  @override
  String get addFile => '+ file';

  @override
  String get addPhoto => '+ photo';

  @override
  String get addAudio => '+ audio';

  @override
  String get addLink => '+ link';

  @override
  String get sessSaveContent => 'Save content';

  @override
  String get sessContentSaved => 'Session content saved';

  @override
  String get linkUrlHint => 'https://…';

  @override
  String get linkTitleHint => 'Link title';

  @override
  String get linkAdd => 'Add link';

  @override
  String get uploadFailed => 'The upload failed';

  @override
  String get sumTitle => 'What did we do today?';

  @override
  String sumSubtitle(String group) {
    return 'A summary sent to the guardians of $group';
  }

  @override
  String get sumHint =>
      'What the children learned, and what guardians could review…';

  @override
  String get sumConsentNote =>
      'Photos with faces go through image rights, like the wall.';

  @override
  String sumConsentBlocked(String name) {
    return '$name: “not allowed” — attach no photo they appear in.';
  }

  @override
  String sumReach(int families, int guardians) {
    return 'Reaches $families families ($guardians guardians) · shown on the session page';
  }

  @override
  String get sumSend => 'Send to the group’s guardians';

  @override
  String get sumSent => '✓ Sent to guardians';

  @override
  String sumSentToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Summary sent to $count families',
      one: 'Summary sent to 1 family',
    );
    return '$_temp0';
  }

  @override
  String get cancelSheetTitle => 'Cancel or reschedule the session';

  @override
  String get cancelModeCancel => 'Cancel';

  @override
  String get cancelModeMove => 'Reschedule';

  @override
  String get cancelNewSlot => 'New slot';

  @override
  String get cancelPickSlot => 'Pick the new slot';

  @override
  String get cancelReasonHint => 'Reason (guardians see it)…';

  @override
  String cancelNotice(int guardians) {
    return '$guardians guardians, co-educators and executives are told. ⦿ Recorded in your name.';
  }

  @override
  String get cancelCta => 'Cancel and tell everyone';

  @override
  String get moveCta => 'Reschedule and tell everyone';

  @override
  String cancelledToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Session cancelled · $count people told',
      one: 'Session cancelled · 1 person told',
    );
    return '$_temp0';
  }

  @override
  String movedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Session moved · $count people told',
      one: 'Session moved · 1 person told',
    );
    return '$_temp0';
  }

  @override
  String get hwNewTitle => 'New homework';

  @override
  String hwNewSubtitle(String day, String group) {
    return 'Linked to the $day session · $group';
  }

  @override
  String get hwInstructions => 'Instructions';

  @override
  String get hwInstructionsHint => 'What the child should do';

  @override
  String get hwTitleHint => 'e.g. review verses 1–10';

  @override
  String get hwFor => 'For whom?';

  @override
  String hwWholeGroup(int count) {
    return 'Whole group ($count)';
  }

  @override
  String get hwSpecific => 'Specific children';

  @override
  String get hwDue => 'Due';

  @override
  String get hwReminderNote =>
      'Automatic reminder to guardians the day before if not marked done.';

  @override
  String get hwAttachment => '+ attachment (sheet, audio…)';

  @override
  String hwAttachmentAdded(String name) {
    return '✓ Attached: $name';
  }

  @override
  String hwSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Send to $count children',
      one: 'Send to 1 child',
      zero: 'Pick children',
    );
    return '$_temp0';
  }

  @override
  String get hwPickOne => 'Pick at least one child';

  @override
  String get hwSentToast => 'Homework sent to guardians';

  @override
  String get eduGroupsTitle => 'My groups';

  @override
  String get eduGroupsSubtitle => 'You see only your groups’ children';

  @override
  String get eduGroupsEmpty => 'No groups assigned to you';

  @override
  String get statAttendance => 'Attendance';

  @override
  String get statHomework => 'Homework';

  @override
  String get statNext => 'Next';

  @override
  String groupFlag(String name) {
    return '$name: 3 absences in a row — a care call';
  }

  @override
  String get eduGroupsFooter =>
      'Adding or moving children is done by an executive.';

  @override
  String get grpTabHomework => 'Homework';

  @override
  String get grpTabStaff => 'Team channel';

  @override
  String rosterAttendance(int present, int expected) {
    return 'attendance $present/$expected';
  }

  @override
  String get rosterNew => 'new';

  @override
  String get rosterCare => '▲ 3 absences in a row — follow up';

  @override
  String get hwStateOpen => 'Open';

  @override
  String get hwStateClosed => 'Closed';

  @override
  String hwListMeta(String target, String date) {
    return '$target · due $date';
  }

  @override
  String hwListMetaClosed(String target, String date) {
    return '$target · ended $date';
  }

  @override
  String hwTargetChildren(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count children',
      one: '1 child',
    );
    return '$_temp0';
  }

  @override
  String get hwFooter =>
      'Done is self-reported · no public ranking of children';

  @override
  String get hwEmpty => 'No homework yet';

  @override
  String get staffChannelNote =>
      'Educators’ and executives’ channel — guardians never see it.';

  @override
  String get staffChannelOpen => 'Open the team channel';

  @override
  String get staffChannelMissing => 'No team channel for this group yet';

  @override
  String get guardianMessage => 'Message';

  @override
  String get guardianEmergency => 'emergency';

  @override
  String get guardianEmergencyHint => 'Number hidden · call through the app';

  @override
  String get guardianCall => '☏ Call';

  @override
  String get guardianCallToast =>
      'Call through the app — number hidden · ⦿ recorded';

  @override
  String get guardianCallUnavailable => 'No number on file for this guardian';

  @override
  String get notesTitle => 'Notes';

  @override
  String get notesPhase2 => 'Phase 2';

  @override
  String get notesStaff => 'Staff only';

  @override
  String get notesShared => 'Shared with guardians';

  @override
  String get notesStaffBody => 'Notes only staff see — coming in phase 2.';

  @override
  String get notesSharedBody => 'Notes guardians receive — coming in phase 2.';

  @override
  String get eduChildHomeworkTile => 'Homework';

  @override
  String msgAvailability(String window) {
    return 'Available $window · outside it messages arrive silently';
  }

  @override
  String get msgAvailabilityUnset =>
      'No availability hours yet — set them in More';

  @override
  String msgSectionChildrenOf(String group) {
    return 'Children · $group';
  }

  @override
  String get msgSectionTeam => 'Team and management';

  @override
  String get msgFooterEdu =>
      'There is no private child conversation — every thread holds the guardians and the group’s educators.';

  @override
  String get quickReply1 => 'Hello, thank you very much';

  @override
  String get quickReply2 => 'Did very well today, well done';

  @override
  String get quickReply3 => 'See you at the next session, inshallah';

  @override
  String get msgComposerHintEdu => 'Write a message…';

  @override
  String get eduMemSubtitle =>
      'Private to your groups’ guardians · no outside sharing';

  @override
  String get memNewPost => '+ post';

  @override
  String get memMyPosts => 'My posts';

  @override
  String get memAlbumsTitle => 'Albums';

  @override
  String get memStatePending => 'Awaiting approval';

  @override
  String get memStatePublished => 'Published';

  @override
  String get memStateEdit => 'Edit requested';

  @override
  String memMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String memTaggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tagged',
      one: '1 tagged',
      zero: 'no tags',
    );
    return '$_temp0';
  }

  @override
  String get memMyPostsEmpty =>
      'Nothing posted yet — add your group’s first memory.';

  @override
  String memPostsInAlbum(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
      zero: 'no posts',
    );
    return '$_temp0';
  }

  @override
  String get memComposeTitle => 'New post';

  @override
  String get memComposeSubtitle => 'Reviewed by an executive before publishing';

  @override
  String get memComposeSubtitleLive =>
      'Published at once to the group’s guardians';

  @override
  String get memAlbumLabel => 'Album';

  @override
  String get memAudienceLabel => 'Audience';

  @override
  String memAudienceOf(String group) {
    return 'Guardians of $group';
  }

  @override
  String get memAudienceAll => 'All guardians';

  @override
  String get memPickAlbum => 'Pick an album';

  @override
  String get memCaptionHint => 'A short caption…';

  @override
  String get memTagTitle => 'Tag the children who appear';

  @override
  String memTagCount(int count) {
    return '$count tagged';
  }

  @override
  String memBlocked(String name) {
    return '⊘ Cannot tag $name — image rights “not allowed”. If they appear in a photo, remove it before publishing.';
  }

  @override
  String get memSubmit => 'Send for approval';

  @override
  String get memPublish => 'Publish';

  @override
  String get memSubmittedToast => 'Sent to an executive for approval';

  @override
  String get memPublishedToast => 'Published to the group’s guardians';

  @override
  String get memNeedMedia => 'Add at least one photo';

  @override
  String get memUploading => 'Uploading…';

  @override
  String get memConsentBlockedToast =>
      'Remove the not-allowed children before publishing';

  @override
  String get memRemovePhoto => 'Remove photo';

  @override
  String get annEduTitle => 'Announcement to my groups';

  @override
  String get annToGuardians => 'To the guardians of';

  @override
  String annReachGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reaches $count guardians + co-educators',
      one: 'Reaches 1 guardian + co-educators',
      zero: 'No one',
    );
    return '$_temp0';
  }

  @override
  String get annPickGroup => 'Pick at least one group';

  @override
  String get annAckTitle => 'Ask for “I’ve read this”';

  @override
  String get annAckBody => 'You see who confirmed and who didn’t';

  @override
  String get annUrgentExecOnly =>
      'Urgent (SMS) announcements are the executives’ alone.';

  @override
  String get annPublishCta => 'Publish';

  @override
  String annPublishedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Announcement published to $count guardians',
      one: 'Announcement published to 1 guardian',
      zero: 'Announcement published',
    );
    return '$_temp0';
  }

  @override
  String moreEduRole(String groups) {
    return 'Educator · $groups';
  }

  @override
  String get availTitle => 'Availability hours';

  @override
  String get availBody =>
      'Outside them guardians’ messages arrive silently, and they see the association’s number for emergencies.';

  @override
  String get availSavedToast => 'Availability saved';

  @override
  String get attReminderRow => 'Attendance reminder';

  @override
  String get attReminderLocked => 'after 30 min · locked';

  @override
  String get offlineAttendanceBanner =>
      '⦸ Offline — attendance is kept on this phone and synced when the network is back.';

  @override
  String get notAvailableToYou => 'Not available to you';
}

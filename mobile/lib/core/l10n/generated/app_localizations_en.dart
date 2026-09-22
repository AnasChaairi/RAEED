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
  String get otpEnterCode => 'Enter the code';

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
}

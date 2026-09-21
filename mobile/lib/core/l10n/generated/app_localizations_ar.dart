// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppL10nAr extends AppL10n {
  AppL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'الرائد';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonBack => 'رجوع';

  @override
  String get errorNetworkTitle => 'تعذّر الاتصال';

  @override
  String get errorNetworkBody => 'تحقّق من اتصالك بالإنترنت ثم أعد المحاولة.';

  @override
  String get errorGenericTitle => 'حدث خطأ';

  @override
  String get errorGenericBody =>
      'لم نتمكّن من إتمام العملية. أعد المحاولة بعد قليل.';

  @override
  String get errorForbiddenTitle => 'غير متاح لك';

  @override
  String get errorForbiddenBody =>
      'لا تملك صلاحية الاطلاع على هذا المحتوى. تواصل مع إدارة الأكاديمية إن كنت ترى أن هذا خطأ.';

  @override
  String get errorSessionExpiredTitle => 'انتهت الجلسة';

  @override
  String get errorSessionExpiredBody => 'يرجى تسجيل الدخول من جديد.';

  @override
  String get errorContractTitle => 'تحديث مطلوب';

  @override
  String get errorContractBody =>
      'هذه النسخة من التطبيق لم تعد متوافقة مع الخادم. يرجى تحديث التطبيق.';

  @override
  String get offlineBannerMessage =>
      'أنت غير متصل بالإنترنت. تُعرض آخر البيانات المحفوظة.';

  @override
  String get offlineRefreshFailed => 'تعذّر التحديث';

  @override
  String get loginTitle => 'مرحبًا بك في الرائد';

  @override
  String get loginSubtitle => 'أدخل رقم هاتفك لتلقّي رمز الدخول.';

  @override
  String get loginPhoneLabel => 'رقم الهاتف';

  @override
  String get loginPhoneHint => '‎+212 6XX XXX XXX';

  @override
  String get loginPhoneInvalid => 'أدخل رقم هاتف صحيحًا.';

  @override
  String get loginRequestCode => 'إرسال رمز الدخول';

  @override
  String get loginNoAccountNotice =>
      'الحسابات تُنشأ من طرف إدارة الأكاديمية فقط. إن لم يكن لديك حساب، تواصل مع الإدارة.';

  @override
  String get otpTitle => 'رمز الدخول';

  @override
  String otpSentTo(String phone) {
    return 'أرسلنا رمزًا من ستة أرقام إلى $phone.';
  }

  @override
  String get otpCodeLabel => 'الرمز';

  @override
  String get otpVerify => 'تأكيد';

  @override
  String get otpInvalid => 'الرمز غير صحيح أو انتهت صلاحيته.';

  @override
  String get otpRateLimited => 'لقد طلبت رموزًا كثيرة. حاول مجددًا بعد ساعة.';

  @override
  String get otpResend => 'إعادة إرسال الرمز';

  @override
  String otpResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'إعادة الإرسال بعد $seconds ثانية',
      many: 'إعادة الإرسال بعد $seconds ثانية',
      few: 'إعادة الإرسال بعد $seconds ثوانٍ',
      two: 'إعادة الإرسال بعد ثانيتين',
      one: 'إعادة الإرسال بعد ثانية واحدة',
      zero: 'يمكنك إعادة الإرسال الآن',
    );
    return '$_temp0';
  }

  @override
  String get consentTitle => 'الخصوصية وحقوق الصورة';

  @override
  String get consentIntro =>
      'قبل المتابعة، نحتاج موافقتك على سياسة الخصوصية وتحديد مستوى حقوق الصورة لكل طفل.';

  @override
  String get consentPrivacyPolicyAccept => 'أوافق على سياسة الخصوصية';

  @override
  String get consentPrivacyPolicyRead => 'قراءة سياسة الخصوصية';

  @override
  String get consentImageRightsTitle => 'حقوق الصورة';

  @override
  String consentImageRightsForChild(String childName) {
    return 'حقوق الصورة لـ $childName';
  }

  @override
  String get consentImageRightsAllowed => 'مسموح';

  @override
  String get consentImageRightsAllowedHelp =>
      'يمكن نشر صور الطفل داخل التطبيق وفي القنوات الرسمية للأكاديمية.';

  @override
  String get consentImageRightsAppOnly => 'داخل التطبيق فقط';

  @override
  String get consentImageRightsAppOnlyHelp =>
      'تُعرض صور الطفل داخل التطبيق فقط، ولا تُنشر خارجه.';

  @override
  String get consentImageRightsNotAllowed => 'غير مسموح';

  @override
  String get consentImageRightsNotAllowedHelp =>
      'لن تُنشر أي صورة للطفل في أي مكان.';

  @override
  String get consentChangeLater =>
      'يمكنك تغيير هذا الاختيار في أي وقت من إعدادات الطفل.';

  @override
  String get consentSubmit => 'حفظ الموافقات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSchedule => 'الجدول';

  @override
  String get navMessages => 'الرسائل';

  @override
  String get navMemories => 'الذكريات';

  @override
  String get navMore => 'المزيد';

  @override
  String get navGroups => 'المجموعات';

  @override
  String get navDashboard => 'لوحة القيادة';

  @override
  String get roleParent => 'وليّ الأمر';

  @override
  String get roleEducator => 'مؤطِّر';

  @override
  String get roleExecutive => 'مشرف';

  @override
  String get roleAdmin => 'مدير النظام';

  @override
  String get roleSwitchTitle => 'تبديل الدور';

  @override
  String get notFoundTitle => 'الصفحة غير موجودة';

  @override
  String get notFoundBody => 'الرابط الذي فتحته لم يعد صالحًا.';

  @override
  String get notFoundGoHome => 'العودة إلى الرئيسية';

  @override
  String get homeTitleParent => 'أطفالي';

  @override
  String get homeTitleEducator => 'مجموعاتي';

  @override
  String get homeTitleExecutive => 'الأطفال';

  @override
  String get homeEmptyTitle => 'لا يوجد أي طفل مرتبط بحسابك';

  @override
  String get homeEmptyBody =>
      'يرجى التواصل مع إدارة الأكاديمية لربط طفلك بحسابك.';

  @override
  String childAgeYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years سنة',
      many: '$years سنة',
      few: '$years سنوات',
      two: 'سنتان',
      one: 'سنة واحدة',
      zero: 'أقل من سنة',
    );
    return '$_temp0';
  }

  @override
  String get childNoSessionToday => 'لا حصة اليوم';

  @override
  String childNextSession(String when) {
    return 'الحصة القادمة: $when';
  }

  @override
  String get statusAwaitingAnswer => 'بانتظار تأكيد الحضور';

  @override
  String get statusPresenceConfirmed => 'مؤكَّد الحضور';

  @override
  String get statusPresenceDeclined => 'غياب معلَن';

  @override
  String get statusPresenceLate => 'سيتأخر';

  @override
  String get statusPresent => 'حاضر';

  @override
  String get statusLate => 'متأخر';

  @override
  String get statusAbsent => 'غائب';

  @override
  String get statusExcused => 'غياب بعذر';

  @override
  String get statusUnknown => '—';

  @override
  String get absenceAlertTitle => 'غياب بدون إشعار';

  @override
  String get healthAlertBadgeLabel => 'تنبيه صحي — اضغط للاطلاع';

  @override
  String get announcementsStripTitle => 'إعلانات';

  @override
  String get announcementUrgent => 'عاجل';

  @override
  String get announcementsEmpty => 'لا إعلانات حاليًا';

  @override
  String get childProfileTitle => 'ملف الطفل';

  @override
  String get childProfileGroupLabel => 'المجموعة';

  @override
  String get childProfileHealthTitle => 'معلومات صحية';

  @override
  String get childProfileNoHealthInfo => 'لا توجد معلومات صحية مسجَّلة.';

  @override
  String get childHealthAllergies => 'حساسية';

  @override
  String get childHealthConditions => 'حالات صحية';

  @override
  String get childHealthMedications => 'أدوية';

  @override
  String get childHealthDiet => 'ملاحظات غذائية';

  @override
  String get childHealthOther => 'أخرى';

  @override
  String get childProfileComingSoon => 'سيتوفر هذا القسم قريبًا.';

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String get childTabSchedule => 'الجدول';

  @override
  String get childTabAttendance => 'الحضور';

  @override
  String get childTabHomework => 'الواجبات';

  @override
  String get childTabMaterials => 'المواد';

  @override
  String get attendanceTitle => 'تسجيل الحضور';

  @override
  String get attendancePresent => 'حاضر';

  @override
  String get attendanceLate => 'متأخر';

  @override
  String get attendanceAbsent => 'غائب';

  @override
  String get attendanceExcused => 'بعذر';

  @override
  String get attendanceNotMarked => 'لم يُسجَّل';

  @override
  String attendanceSummaryConfirmed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مؤكَّد',
      many: '$count مؤكَّدًا',
      few: '$count مؤكَّدين',
      two: 'مؤكَّدان',
      one: 'مؤكَّد واحد',
      zero: 'لا مؤكَّد',
    );
    return '$_temp0';
  }

  @override
  String attendanceSummaryAbsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غياب',
      many: '$count غيابًا',
      few: '$count غيابات',
      two: 'غيابان',
      one: 'غياب واحد',
      zero: 'لا غياب',
    );
    return '$_temp0';
  }

  @override
  String attendanceSummaryNoAnswer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بدون جواب',
      many: '$count بدون جواب',
      few: '$count بدون جواب',
      two: 'اثنان بدون جواب',
      one: 'واحد بدون جواب',
      zero: 'لا أحد بدون جواب',
    );
    return '$_temp0';
  }

  @override
  String attendanceMarkedOf(int marked, int total) {
    return 'تم تسجيل $marked من $total';
  }

  @override
  String get attendanceMarkRemainingPresent => 'تسجيل الباقي حاضرين';

  @override
  String get attendanceSubmit => 'إرسال';

  @override
  String get attendanceSubmitted => 'تم إرسال الحضور';

  @override
  String get attendanceEmptyGroup => 'لا يوجد أطفال في هذه المجموعة بعد';

  @override
  String get attendanceOfflineSaved =>
      'محفوظ على هذا الجهاز، سيُرسل عند عودة الاتصال';

  @override
  String attendancePendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تسجيل بانتظار الإرسال',
      many: '$count تسجيلًا بانتظار الإرسال',
      few: '$count تسجيلات بانتظار الإرسال',
      two: 'تسجيلان بانتظار الإرسال',
      one: 'تسجيل واحد بانتظار الإرسال',
      zero: 'لا شيء بانتظار الإرسال',
    );
    return '$_temp0';
  }

  @override
  String get attendanceConflictTitle => 'تعارض في التسجيل';

  @override
  String attendanceConflictBody(String attempted, String server) {
    return 'سجّلت $attempted لهذا الطفل، لكن تم تسجيل $server قبل ذلك من جهاز آخر.';
  }

  @override
  String get attendanceConflictKeepMine => 'اعتماد تسجيلي';

  @override
  String get attendanceConflictKeepServer => 'اعتماد المسجَّل';

  @override
  String get attendanceUnknownChild =>
      'لم يعد هذا الطفل ضمن هذه المجموعة، ولم يُسجَّل.';

  @override
  String get presenceTitle => 'تأكيد الحضور';

  @override
  String presenceQuestion(String childName, String when) {
    return 'هل سيحضر $childName حصة $when؟';
  }

  @override
  String get presenceYes => 'نعم';

  @override
  String get presenceNo => 'لا';

  @override
  String get presenceLate => 'سيتأخر';

  @override
  String get presenceReasonPrompt => 'السبب (اختياري)';

  @override
  String get presenceReasonIllness => 'مرض';

  @override
  String get presenceReasonTravel => 'سفر';

  @override
  String get presenceReasonExam => 'امتحان';

  @override
  String get presenceReasonOther => 'سبب آخر';

  @override
  String get presenceOtherNoteLabel => 'اذكر السبب';

  @override
  String get presenceAnswered => 'شكرًا، تم تسجيل جوابك';

  @override
  String get presenceNoneOutstanding => 'لا توجد تأكيدات معلّقة';

  @override
  String get brandTagline => 'صالح في نفسه، مصلح لغيره';

  @override
  String get otpEnterCode => 'أدخل الرمز';

  @override
  String consentStepOf(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get consentChoose => 'اختر';

  @override
  String get homeGreeting => 'السلام عليكم';

  @override
  String get homeTodaySessions => 'جلسات اليوم';

  @override
  String get homeNotifications => 'الإشعارات';

  @override
  String homeNotificationsWithUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الإشعارات، $count إشعار غير مقروء',
      many: 'الإشعارات، $count إشعارًا غير مقروء',
      few: 'الإشعارات، $count إشعارات غير مقروءة',
      two: 'الإشعارات، إشعاران غير مقروءين',
      one: 'الإشعارات، إشعار غير مقروء',
      zero: 'الإشعارات',
    );
    return '$_temp0';
  }

  @override
  String get homeNeedsYourReply => 'يحتاج ردّك';

  @override
  String get execTabDashboard => 'اللوحة';

  @override
  String get execTabAnnouncements => 'الإعلانات';

  @override
  String get execTabMessages => 'الرسائل';

  @override
  String get execTabMemories => 'الذكريات';

  @override
  String get execTabGroups => 'المجموعات';

  @override
  String get execNavLabel => 'التنقل';

  @override
  String get execMore => 'المزيد';

  @override
  String get execScopeAllBranches => 'كل الفروع';

  @override
  String get execScopeRestricted => 'فرعك فقط (مقيَّد)';

  @override
  String execStaleOffline(String time) {
    return 'بلا اتصال — تُعرض آخر نسخة ($time).';
  }

  @override
  String execStaleRefreshFailed(String time) {
    return 'تعذّر التحديث — تُعرض نسخة $time.';
  }

  @override
  String get recordedActionMarker =>
      'هذا الإجراء يُسجَّل باسمك مع الوقت والجهاز.';

  @override
  String get recordedShort => 'مُسجَّل';

  @override
  String dashSessionsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جلسة اليوم',
      many: '$count جلسة اليوم',
      few: '$count جلسات اليوم',
      two: 'جلستان اليوم',
      one: 'جلسة واحدة اليوم',
      zero: 'لا جلسات اليوم',
    );
    return '$_temp0';
  }

  @override
  String dashSessionsBreakdown(int live, int upcoming) {
    return '$live جارية · $upcoming قادمة';
  }

  @override
  String get dashNeedsAttention => 'يحتاج انتباهك';

  @override
  String get dashNoAlertsTitle => 'لا شيء يحتاج انتباهك اليوم';

  @override
  String get dashNoAlertsBody => 'لا تنبيهات ولا طلبات معلقة الآن.';

  @override
  String get severityDanger => 'خطر';

  @override
  String get severityWarning => 'تنبيه';

  @override
  String get severityInfo => 'للعلم';

  @override
  String get statChildren => 'الأطفال';

  @override
  String get statFamilies => 'الأسر';

  @override
  String get statGroups => 'المجموعات';

  @override
  String get statEducators => 'المؤطرون';

  @override
  String get dashWeeklyAttendance => 'حضور الأسبوع';

  @override
  String get dashTooLittleData => 'بيانات غير كافية بعد';

  @override
  String get dashTodaySessions => 'جلسات اليوم';

  @override
  String get dashNoSessionsToday => 'لا جلسات اليوم';

  @override
  String get sessionAttendanceRecorded => 'مسجَّل';

  @override
  String get sessionAttendanceNotRecorded => 'غير مسجَّل';

  @override
  String get sessionAttendanceLive => 'جارية';

  @override
  String get sessionAttendanceUpcoming => 'قادمة';

  @override
  String get annNew => 'إعلان جديد';

  @override
  String get annStatePublished => 'منشور';

  @override
  String get annStateScheduled => 'مجدوَل';

  @override
  String get annStateDraft => 'مسودة';

  @override
  String get annStateExpired => 'منتهٍ';

  @override
  String annReadBy(int percent) {
    return 'قرأه $percent%';
  }

  @override
  String get annPinned => 'مثبَّت';

  @override
  String get annEmptyTitle => 'لا إعلانات بعد';

  @override
  String get annEmptyBody => 'أنشئ أول إعلان لأولياء الأمور أو المؤطرين.';

  @override
  String annMetaPublished(String when) {
    return 'نُشر $when';
  }

  @override
  String annMetaScheduled(String when) {
    return 'مجدوَل $when';
  }

  @override
  String annMetaExpires(String when) {
    return 'ينتهي $when';
  }

  @override
  String get annFieldTitle => 'العنوان';

  @override
  String get annFieldBody => 'النص';

  @override
  String get annTitleHint => 'عنوان الإعلان';

  @override
  String get annBodyHint => 'نص الإعلان';

  @override
  String get annFieldAudience => 'الجمهور';

  @override
  String get annChange => 'تغيير';

  @override
  String get annPublishTiming => 'النشر';

  @override
  String get annPublishNow => 'الآن';

  @override
  String get annExpires => 'ينتهي';

  @override
  String get annNoExpiry => 'بلا انتهاء';

  @override
  String get annUrgentTitle => 'أولوية عاجلة';

  @override
  String get annUrgentBody =>
      'إشعار فوري + SMS لمن لم يفتح التطبيق. للطوارئ فقط.';

  @override
  String get annSend => 'نشر الإعلان';

  @override
  String annSendUrgent(int reach) {
    return 'إرسال عاجل · $reach';
  }

  @override
  String get annAudienceSheetTitle => 'من يصله الإعلان؟';

  @override
  String get audAll => 'الجميع';

  @override
  String get audParents => 'أولياء الأمور فقط';

  @override
  String get audEducators => 'المؤطرون فقط';

  @override
  String get audCategories => 'فئات محددة';

  @override
  String get audCategoriesHeading => 'الفئات';

  @override
  String audPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخص',
      many: '$count شخصًا',
      few: '$count أشخاص',
      two: 'شخصان',
      one: 'شخص واحد',
      zero: 'لا أحد',
    );
    return '$_temp0';
  }

  @override
  String get audDone => 'تم';

  @override
  String get audSummaryAll => 'كل الأولياء والمؤطرين في نطاقك.';

  @override
  String get audSummaryParents => 'كل أولياء أمور الأطفال المسجَّلين.';

  @override
  String get audSummaryEducators => 'المؤطرون دون الأولياء.';

  @override
  String audSummaryCategories(String names) {
    return 'أولياء أطفال: $names.';
  }

  @override
  String get audSummaryNone => 'لم تختر فئة — لن يصل لأحد.';

  @override
  String get annUrgentConfirmKind => 'واسع الأثر — قناة حرجة';

  @override
  String annUrgentConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إرسال عاجل إلى $count شخص؟',
      many: 'إرسال عاجل إلى $count شخصًا؟',
      few: 'إرسال عاجل إلى $count أشخاص؟',
      two: 'إرسال عاجل إلى شخصين؟',
      one: 'إرسال عاجل إلى شخص واحد؟',
      zero: 'إرسال عاجل إلى لا أحد؟',
    );
    return '$_temp0';
  }

  @override
  String get annUrgentConfirmBody =>
      'إشعار فوري للجميع، وSMS لمن لم يفتح التطبيق خلال 10 دقائق، بتكلفة على الجمعية. للطوارئ فقط.';

  @override
  String get annUrgentConfirmLog =>
      'يُسجَّل الإرسال العاجل باسمك مع الجمهور والتكلفة.';

  @override
  String get annUrgentConfirmCta => 'نعم، إرسال عاجل';

  @override
  String annPublished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نُشر الإعلان إلى $count شخص',
      many: 'نُشر الإعلان إلى $count شخصًا',
      few: 'نُشر الإعلان إلى $count أشخاص',
      two: 'نُشر الإعلان إلى شخصين',
      one: 'نُشر الإعلان إلى شخص واحد',
      zero: 'نُشر الإعلان',
    );
    return '$_temp0';
  }

  @override
  String annPublishedUrgent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُرسل الإعلان العاجل إلى $count شخص',
      many: 'أُرسل الإعلان العاجل إلى $count شخصًا',
      few: 'أُرسل الإعلان العاجل إلى $count أشخاص',
      two: 'أُرسل الإعلان العاجل إلى شخصين',
      one: 'أُرسل الإعلان العاجل إلى شخص واحد',
      zero: 'أُرسل الإعلان العاجل',
    );
    return '$_temp0';
  }

  @override
  String get annUrgentTag => 'عاجل';

  @override
  String get msgOversightSubtitle =>
      'إشراف — قراءتك للمحادثات التي لست عضوًا فيها تُسجَّل.';

  @override
  String get msgSectionChildren => 'محادثات الأطفال';

  @override
  String get msgSectionStaff => 'قنوات المؤطرين';

  @override
  String get msgSectionExecutives => 'المشرفون';

  @override
  String get msgEmptyTitle => 'لا محادثات بعد';

  @override
  String get msgEmptyBody => 'تُنشأ محادثة لكل طفل عند تسجيله.';

  @override
  String get msgOversightNotice =>
      'لست عضوًا هنا — قراءتك إشرافٌ مُسجَّل ومعلوم للأعضاء.';

  @override
  String msgReportedBy(String name, String reason) {
    return 'بلاغ من $name: $reason';
  }

  @override
  String get msgHide => 'إخفاء';

  @override
  String get msgDismissReport => 'رفض البلاغ';

  @override
  String msgHiddenStub(String name, String time) {
    return 'مخفية · أخفاها $name $time · يراها المشرفون فقط';
  }

  @override
  String get msgComposerHint => 'اكتب كمشرف…';

  @override
  String get msgSend => 'إرسال';

  @override
  String get msgVoiceNote => 'تسجيل صوتي';

  @override
  String get msgHideConfirmKind => 'إخفاء — قابل للتراجع';

  @override
  String msgHideConfirmTitle(String name) {
    return 'إخفاء رسالة $name؟';
  }

  @override
  String get msgHideConfirmBody =>
      'تختفي عن الأعضاء وتبقى للمشرفين بعلامة «مخفية». لا حذف نهائي. سيُبلَّغ المرسل بالسبب.';

  @override
  String get msgHideConfirmLog => 'يُسجَّل الإخفاء باسمك ويُقفل البلاغ.';

  @override
  String get msgHideConfirmCta => 'إخفاء الرسالة';

  @override
  String get msgHiddenToast => 'أُخفيت الرسالة';

  @override
  String get msgReportDismissedToast => 'رُفض البلاغ';

  @override
  String get msgThreadEmpty => 'لا رسائل بعد';

  @override
  String get memTitle => 'مراجعة الذكريات';

  @override
  String memQueueLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشور بانتظارك',
      many: '$count منشورًا بانتظارك',
      few: '$count منشورات بانتظارك',
      two: 'منشوران بانتظارك',
      one: 'منشور واحد بانتظارك',
      zero: 'لا منشورات بانتظارك',
    );
    return '$_temp0';
  }

  @override
  String get memModeApproveFirst => 'الاعتماد أولًا';

  @override
  String get memModePublishThenReview => 'النشر ثم المراجعة';

  @override
  String get memModeUnset => 'وضع المراجعة لم يُحدَّد بعد';

  @override
  String get memBlockedBadge => 'محجوب — حقوق الصورة تغيّرت بعد النشر';

  @override
  String memBlockedBody(String name) {
    return '$name صار «غير مسموح». أزل الصورة أو أبقِ المنشور مخفيًا.';
  }

  @override
  String memCounter(int index, int count) {
    return '$index / $count';
  }

  @override
  String get imageRightsAllowed => 'مسموح';

  @override
  String get imageRightsAppOnly => 'داخل التطبيق فقط';

  @override
  String get imageRightsNotAllowed => 'غير مسموح';

  @override
  String imageRightsLabel(String level) {
    return 'حقوق الصورة: $level';
  }

  @override
  String get memHide => 'إخفاء';

  @override
  String get memEdit => 'تعديل';

  @override
  String get memApprove => 'اعتماد';

  @override
  String get memKeep => 'إبقاء';

  @override
  String get memReapprove => 'إعادة الاعتماد';

  @override
  String get memHideHint => 'الإخفاء ليس حذفًا — يبقى المنشور للمشرفين.';

  @override
  String get memAllReviewedTitle => 'راجعت كل شيء';

  @override
  String get memAllReviewedBody => 'لا منشورات بانتظارك.';

  @override
  String get memWall => 'الجدار';

  @override
  String memAlbumPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشور',
      many: '$count منشورًا',
      few: '$count منشورات',
      two: 'منشوران',
      one: 'منشور واحد',
      zero: 'لا منشورات',
    );
    return '$_temp0';
  }

  @override
  String get memNoAlbums => 'لا ألبومات هذا الموسم';

  @override
  String get memApprovedToast => 'اعتُمد المنشور';

  @override
  String get memHiddenToast => 'أُخفي المنشور (لا حذف)';

  @override
  String grpCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجموعة',
      many: '$count مجموعة',
      few: '$count مجموعات',
      two: 'مجموعتان',
      one: 'مجموعة واحدة',
      zero: 'لا مجموعات',
    );
    return '$_temp0';
  }

  @override
  String get grpEmptyTitle => 'لا مجموعات هذا الموسم';

  @override
  String get grpEmptyBody => 'تُنشأ المجموعات من لوحة الويب.';

  @override
  String get grpOverCapacity => 'فوق السعة';

  @override
  String get grpTabSessions => 'الجلسات';

  @override
  String get grpTabRoster => 'القائمة';

  @override
  String get grpSessionsEmpty => 'لا جلسات بعد';

  @override
  String get grpRosterEmpty => 'لا أطفال في هذه المجموعة';

  @override
  String get sessionEnded => 'انتهت';

  @override
  String get sessionCancelled => 'ملغاة';

  @override
  String get sessionToday => 'اليوم';

  @override
  String reviewTitle(String group) {
    return 'حضور $group';
  }

  @override
  String reviewRecordedBy(String name, String time) {
    return 'سجّله $name $time';
  }

  @override
  String get reviewCorrect => 'تصحيح';

  @override
  String get reviewGuardianNoAnswer => 'بلا رد';

  @override
  String get reviewGuardianConfirmed => 'أكّد الولي الحضور';

  @override
  String get reviewGuardianDeclared => 'أعلن الولي الغياب';

  @override
  String get reviewGuardianLate => 'أعلن الولي تأخره';

  @override
  String reviewTrailOriginal(String status, String name, String time) {
    return 'سُجّل $status — $name · $time';
  }

  @override
  String reviewTrailCorrected(String status, String name, String time) {
    return 'صُحّح إلى $status — $name · $time';
  }

  @override
  String reviewTrailRefers(String id) {
    return 'يشير إلى #$id';
  }

  @override
  String get reviewTrailNotified => 'أُبلغ الأولياء';

  @override
  String corrTitle(String name) {
    return 'تصحيح حضور $name';
  }

  @override
  String get corrBody =>
      'سجل جديد يشير إلى السجل الأصلي — لا يُمحى شيء. يظهر للأولياء والمؤطر.';

  @override
  String get corrNoteHint => 'ملاحظة (اختيارية)';

  @override
  String get corrSave => 'حفظ التصحيح';

  @override
  String get corrSavedToast => 'أُضيف سجل تصحيح';

  @override
  String get notifTitle => 'الإشعارات';

  @override
  String get notifMarkAllRead => 'تعليم الكل كمقروء';

  @override
  String get notifFilterAll => 'الكل';

  @override
  String get notifFilterCritical => 'حرِج';

  @override
  String get notifFilterRequests => 'طلبات';

  @override
  String get notifFilterMemories => 'الذكريات';

  @override
  String get notifEmptyTitle => 'لا جديد';

  @override
  String get notifEmptyBody => 'أنت على اطلاع بكل شيء.';

  @override
  String get timeJustNow => 'الآن';

  @override
  String timeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count دقيقة',
      many: 'قبل $count دقيقة',
      few: 'قبل $count دقائق',
      two: 'قبل دقيقتين',
      one: 'قبل دقيقة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count ساعة',
      many: 'قبل $count ساعة',
      few: 'قبل $count ساعات',
      two: 'قبل ساعتين',
      one: 'قبل ساعة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count يوم',
      many: 'قبل $count يومًا',
      few: 'قبل $count أيام',
      two: 'قبل يومين',
      one: 'أمس',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String get moreCurrentRole => 'الدور الحالي';

  @override
  String moreRolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لديك $count دور',
      many: 'لديك $count دورًا',
      few: 'لديك $count أدوار',
      two: 'لديك دوران',
      one: 'لديك دور واحد',
      zero: 'لا أدوار',
    );
    return '$_temp0';
  }

  @override
  String get roleHintExecutive => 'لوحة المتابعة والإشراف على المجموعات كلها';

  @override
  String get roleHintAdmin => 'كل صلاحيات المشرف مع إدارة الهيكل والمستخدمين';

  @override
  String get roleHintEducator => 'تسجيل الحضور والواجبات لمجموعاتك';

  @override
  String get roleHintParent => 'متابعة أطفالك';

  @override
  String get moreDarkMode => 'الوضع الليلي';

  @override
  String get moreLanguage => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get moreCriticalChannel => 'إشعارات القناة الحرجة';

  @override
  String get moreCriticalChannelLocked =>
      'مقفلة: تنبيهات الغياب والإعلانات العاجلة وتغييرات الجلسات خلال 24 ساعة تصل دائمًا.';

  @override
  String moreVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get moreTagline => 'صالح في نفسه، مصلح لغيره';

  @override
  String get dialogCancel => 'إلغاء';
}

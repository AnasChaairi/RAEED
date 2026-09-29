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
  String get errorLastGuardian =>
      'لا يمكن فصل هذا الولي: سيبقى أحد الأطفال بلا وليّ. أضف وليًا آخر أولًا.';

  @override
  String get errorPhoneTaken => 'هذا الرقم مستعمل في حساب آخر.';

  @override
  String get errorGuardianAlreadyLinked =>
      'هذا الحساب وليٌّ لهؤلاء الأطفال بالفعل.';

  @override
  String get errorNoActiveSeason =>
      'لا يوجد موسم نشط. افتح موسمًا من «الهيكل» ثم أنشئ المجموعة.';

  @override
  String get errorNoBranch =>
      'لا يوجد فرع بعد. أضف فرعًا من «الهيكل» ثم أنشئ المجموعة.';

  @override
  String get openStructure => 'الهيكل';

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
  String get loginPhoneLabel => 'رقم الهاتف';

  @override
  String get loginPhoneHint => '6XX XXX XXX';

  @override
  String get loginPhoneInvalid => 'أدخل رقم هاتف صحيحًا.';

  @override
  String get loginNoAccountNotice =>
      'الحسابات تُنشأ من طرف إدارة الأكاديمية فقط. إن لم يكن لديك حساب، تواصل مع الإدارة.';

  @override
  String get loginSubtitle => 'أدخل رقم هاتفك وكلمة المرور.';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get loginPasswordRule => '6 أحرف أو أرقام';

  @override
  String get loginPasswordInvalid => 'كلمة المرور من 6 أحرف أو أرقام بالضبط.';

  @override
  String get loginPasswordShow => 'إظهار كلمة المرور';

  @override
  String get loginPasswordHide => 'إخفاء كلمة المرور';

  @override
  String get loginSubmit => 'دخول';

  @override
  String get loginInvalidCredentials => 'رقم الهاتف أو كلمة المرور غير صحيحة.';

  @override
  String get loginRateLimited =>
      'محاولات كثيرة خاطئة. حاول مجددًا بعد 15 دقيقة.';

  @override
  String get morePassword => 'تغيير كلمة المرور';

  @override
  String get pwdTitle => 'تغيير كلمة المرور';

  @override
  String get pwdIntro =>
      'كلمة المرور من 6 أحرف أو أرقام. أدخل الحالية ثم الجديدة مرتين.';

  @override
  String get pwdCurrent => 'كلمة المرور الحالية';

  @override
  String get pwdNew => 'كلمة المرور الجديدة';

  @override
  String get pwdConfirm => 'تأكيد كلمة المرور الجديدة';

  @override
  String get pwdMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get pwdWrongCurrent => 'كلمة المرور الحالية غير صحيحة.';

  @override
  String get pwdSave => 'حفظ';

  @override
  String get pwdSavedToast => 'تم تغيير كلمة المرور';

  @override
  String get handoverTitle => 'كلمات المرور المؤقتة';

  @override
  String get handoverIntro =>
      'سلّمها للولي شخصيًا. تُعرض مرة واحدة فقط ولا تُرسل برسالة.';

  @override
  String get handoverExisting => 'لديه حساب من قبل — كلمة مروره لم تتغير.';

  @override
  String get handoverDone => 'سلّمتها';

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
  String get roleExecutive => 'إداري';

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
  String get msgSectionExecutives => 'الإداريون';

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
    return 'مخفية · أخفاها $name $time · يراها الإداريون فقط';
  }

  @override
  String get msgComposerHint => 'اكتب كإداري…';

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
      'تختفي عن الأعضاء وتبقى للإداريين بعلامة «مخفية». لا حذف نهائي. سيُبلَّغ المرسل بالسبب.';

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
  String get memHideHint => 'الإخفاء ليس حذفًا — يبقى المنشور للإداريين.';

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
  String get roleHintAdmin => 'كل صلاحيات الإداري مع إدارة الهيكل والمستخدمين';

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

  @override
  String get moreChildren => 'الأطفال';

  @override
  String get moreChildrenHint => 'الملفات والموافقات';

  @override
  String get moreManage => 'الأسر والمجموعات';

  @override
  String get moreManageHint => 'إنشاء مجموعة · أسرة جديدة · إسناد';

  @override
  String get moreReports => 'التقارير والتصدير';

  @override
  String get moreReportsHint => 'حضور · مؤطرون · تفاعل';

  @override
  String get moreStructure => 'الهيكل';

  @override
  String get moreStructureHint => 'المواسم · الفئات · الفروع';

  @override
  String get moreLogs => 'السجلات';

  @override
  String get moreLogsHint => 'التدقيق · الوصول الصحي';

  @override
  String get adminTag => 'مدير النظام';

  @override
  String get moreAdminHint =>
      'مدير النظام وحده يفتح «الهيكل» و«السجلات». محاولة غيره تُرفض وتُسجَّل.';

  @override
  String get moreSignOut => 'تسجيل الخروج';

  @override
  String childrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طفل',
      many: '$count طفلًا',
      few: '$count أطفال',
      two: 'طفلان',
      one: 'طفل واحد',
      zero: 'لا أطفال',
    );
    return '$_temp0';
  }

  @override
  String get childrenSearchHint => 'ابحث عن طفل';

  @override
  String get filterAll => 'الكل';

  @override
  String get childrenEmptyTitle => 'لا أطفال مطابقون';

  @override
  String get childrenEmptyBody => 'جرّب بحثًا آخر أو فئة أخرى.';

  @override
  String attendanceShort(String ratio) {
    return 'حضور $ratio';
  }

  @override
  String get imageRightsLegend => 'حقوق الصورة:';

  @override
  String get childSeasonAttendance => 'حضور الموسم';

  @override
  String get childImageRightsTile => 'حقوق الصورة';

  @override
  String get healthSectionTitle => 'المعلومات الصحية';

  @override
  String get healthEveryViewLogged => 'كل عرض يُسجَّل';

  @override
  String get healthCollapsedBody =>
      'يوجد تنبيه صحي. المحتوى مطويٌّ عمدًا — يظهر عند طلبك ويُقيَّد في سجل الوصول الصحي.';

  @override
  String get healthNoneBody => 'لا تنبيه صحي مسجَّل لهذا الطفل.';

  @override
  String get healthShowButton => 'عرض المعلومات الصحية';

  @override
  String get healthConfirmTitle => 'سيُسجَّل هذا العرض';

  @override
  String healthConfirmBody(String actor, String child) {
    return 'سيُقيَّد أن $actor عرض بيانات $child الصحية الآن. لا تفتحه بلا سبب.';
  }

  @override
  String get healthContinue => 'متابعة';

  @override
  String get healthBack => 'تراجع';

  @override
  String get healthAlertTitle => 'التنبيه الصحي';

  @override
  String healthRecordedAt(String time) {
    return 'سُجّل $time';
  }

  @override
  String get healthFieldsPending => 'الحقول التفصيلية تُقرَّ بعد تصريح CNDP.';

  @override
  String get healthCollapse => 'طيّ';

  @override
  String get healthAllergies => 'الحساسية';

  @override
  String get healthConditions => 'الحالات الصحية';

  @override
  String get healthMedications => 'الأدوية';

  @override
  String get healthDietary => 'ملاحظات غذائية';

  @override
  String get healthSpecialNeeds => 'احتياجات خاصة';

  @override
  String get guardiansTitle => 'الأولياء';

  @override
  String get relMother => 'الأم';

  @override
  String get relFather => 'الأب';

  @override
  String get relGuardian => 'ولي الأمر';

  @override
  String get guardianAccountActive => 'مفعَّل';

  @override
  String get guardianAccountPending => 'لم يدخل بعد';

  @override
  String guardianLastSeen(String when) {
    return 'آخر دخول $when';
  }

  @override
  String get guardianReveal => 'إظهار';

  @override
  String get guardianRevealLogged => 'كل إظهار يُسجَّل باسمك مع الوقت.';

  @override
  String get guardianRevealToast => 'سُجّل إظهار الرقم باسمك';

  @override
  String get consentsTitle => 'الموافقات';

  @override
  String get consentPrivacyLabel => 'سياسة الخصوصية';

  @override
  String consentVersionAt(int version, String when) {
    return 'v$version · $when';
  }

  @override
  String get consentImageRightsChangeable => 'يغيّرها الولي متى شاء';

  @override
  String get consentApproved => 'موافَق';

  @override
  String get consentMissing => 'لم يوافق بعد';

  @override
  String get childGroupsTitle => 'المجموعات';

  @override
  String get groupMainTag => 'رئيسية';

  @override
  String openChildThread(String name) {
    return 'فتح محادثة $name (إشراف · يُسجَّل)';
  }

  @override
  String get manageTitle => 'الأسر والمجموعات';

  @override
  String familiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أسرة',
      many: '$count أسرة',
      few: '$count أسر',
      two: 'أسرتان',
      one: 'أسرة واحدة',
      zero: 'لا أسر',
    );
    return '$_temp0';
  }

  @override
  String get manageTabUnassigned => 'بلا مجموعة';

  @override
  String get manageTabFamilies => 'الأسر';

  @override
  String get manageTabGroups => 'المجموعات';

  @override
  String get unassignedHint =>
      'مسجَّلون بلا مجموعة رئيسية. اختر أطفالًا ثم اضغط «إسناد».';

  @override
  String get unassignedEmpty => 'كل الأطفال في مجموعات.';

  @override
  String assignCta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إسناد $count طفل إلى مجموعة…',
      many: 'إسناد $count طفلًا إلى مجموعة…',
      few: 'إسناد $count أطفال إلى مجموعة…',
      two: 'إسناد طفلين إلى مجموعة…',
      one: 'إسناد طفل واحد إلى مجموعة…',
    );
    return '$_temp0';
  }

  @override
  String assignSheetTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إسناد $count طفل إلى مجموعة',
      many: 'إسناد $count طفلًا إلى مجموعة',
      few: 'إسناد $count أطفال إلى مجموعة',
      two: 'إسناد طفلين إلى مجموعة',
      one: 'إسناد طفل واحد إلى مجموعة',
    );
    return '$_temp0';
  }

  @override
  String assignWarn(int after, int capacity, String group) {
    return '$group ستصير $after من $capacity — تظهر بعلامة «فوق السعة».';
  }

  @override
  String get assignLogged => 'يُسجَّل الإسناد باسمك ويُبلَّغ الأولياء.';

  @override
  String assignTo(String group) {
    return 'إسناد إلى $group';
  }

  @override
  String get assignPick => 'اختر مجموعة';

  @override
  String get assignOverKind => 'فوق السعة';

  @override
  String assignOverTitle(String group) {
    return 'إسناد إلى $group فوق السعة؟';
  }

  @override
  String get assignOverLog => 'يُسجَّل الإسناد والتجاوز باسمك.';

  @override
  String get assignOverCta => 'نعم، إسناد';

  @override
  String assignedToast(int count, String group) {
    return 'أُسند $count إلى $group';
  }

  @override
  String get familyStatusActive => 'مفعَّلة';

  @override
  String get familyStatusPartial => 'بعض الأولياء';

  @override
  String get familyStatusPending => 'دعوة معلقة';

  @override
  String get familyResend => 'إعادة الدعوة';

  @override
  String get familyResentToast => 'أُعيد إرسال الدعوة';

  @override
  String get familyAddChild => '+ طفل';

  @override
  String get familyNoGroup => 'بلا مجموعة';

  @override
  String get familiesEmpty => 'لا أسر بعد';

  @override
  String get newFamilyCta => '+ أسرة جديدة';

  @override
  String familyDetailSubtitle(int guardians, int children) {
    String _temp0 = intl.Intl.pluralLogic(
      guardians,
      locale: localeName,
      other: '$guardians وليّ',
      many: '$guardians وليًّا',
      few: '$guardians أولياء',
      two: 'وليّان',
      one: 'وليّ واحد',
    );
    String _temp1 = intl.Intl.pluralLogic(
      children,
      locale: localeName,
      other: '$children طفل',
      many: '$children طفلًا',
      few: '$children أطفال',
      two: 'طفلان',
      one: 'طفل واحد',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get familyGuardiansSection => 'الأولياء';

  @override
  String get familyChildrenSection => 'الأطفال';

  @override
  String get familyAddGuardian => '+ وليّ آخر';

  @override
  String get familyEditGuardian => 'تعديل الوليّ';

  @override
  String get familyUnlinkGuardian => 'فصل عن الأسرة';

  @override
  String familyUnlinkConfirmTitle(String name) {
    return 'فصل $name عن الأسرة؟';
  }

  @override
  String get familyUnlinkConfirmBody =>
      'يبقى الأطفال مع أوليائهم الآخرين، ويبقى الحساب موجودًا دون أطفال. لا يمكن فصل آخر وليّ لطفل.';

  @override
  String get familyUnlinkRecorded => '⦿ يُسجَّل الفصل باسمك.';

  @override
  String get familyUnlinkCta => 'فصل';

  @override
  String get familyUnlinkDone => 'فُصل الوليّ عن الأسرة.';

  @override
  String get familyGuardianUpdated => 'حُفظ التعديل.';

  @override
  String get familyGuardianLinkedExisting =>
      'رُبط حساب موجود بالأطفال. كلمة مروره لم تتغيّر.';

  @override
  String get familyGuardianLinked => 'رُبط الوليّ بالأطفال.';

  @override
  String get familyPhoneUnchangedHint => 'اتركه فارغًا لإبقاء الرقم الحالي';

  @override
  String get familyPhoneChangeWarning =>
      'تغيير الرقم يُخرج الوليّ من التطبيق على كل أجهزته. يدخل من جديد بالرقم الجديد وكلمة المرور نفسها.';

  @override
  String get familyEditChild => 'تعديل الطفل';

  @override
  String get familyChildAdded => 'أُضيف الطفل إلى الأسرة.';

  @override
  String get familyChildUpdated => 'حُفظ التعديل.';

  @override
  String get familyEditRecorded => '⦿ يُسجَّل التعديل باسمك.';

  @override
  String get familyNotFoundTitle => 'هذه الأسرة لم تعد متاحة';

  @override
  String get familyNotFoundBody =>
      'ربما تغيّر أولياؤها من جهاز آخر. ارجع إلى قائمة الأسر.';

  @override
  String get familyBackToList => 'إلى الأسر';

  @override
  String get saveAction => 'حفظ';

  @override
  String get cancelAction => 'إلغاء';

  @override
  String get newGroupCta => '+ مجموعة جديدة';

  @override
  String get groupAssignHere => '+ إسناد أطفال';

  @override
  String get newGroupTitle => 'مجموعة جديدة';

  @override
  String get fieldName => 'الاسم';

  @override
  String get groupNameHint => 'مثال: الأشبال 3';

  @override
  String get fieldCategory => 'الفئة';

  @override
  String get fieldCapacity => 'السعة';

  @override
  String get fieldSchedule => 'الجدول';

  @override
  String get fieldEducators => 'المؤطرون';

  @override
  String educatorLoad(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجموعة',
      many: '$count مجموعة',
      few: '$count مجموعات',
      two: 'مجموعتان',
      one: 'مجموعة واحدة',
      zero: 'بلا مجموعات',
    );
    return '$_temp0';
  }

  @override
  String get fieldChildrenOptional => 'أطفال (اختياري) — من «بلا مجموعة»';

  @override
  String get checklistNameOk => '✓ الاسم';

  @override
  String get checklistNameMissing => '○ الاسم مطلوب';

  @override
  String get checklistCategoryMissing => '○ الفئة مطلوبة';

  @override
  String get checklistEducatorOk => '✓ مؤطر';

  @override
  String get checklistEducatorMissing => '○ مؤطر واحد على الأقل';

  @override
  String checklistChildren(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '✓ $count طفل',
      many: '✓ $count طفلًا',
      few: '✓ $count أطفال',
      two: '✓ طفلان',
      one: '✓ طفل واحد',
      zero: '○ بلا أطفال (مقبول)',
    );
    return '$_temp0';
  }

  @override
  String get checklistLogged => '⦿ يُسجَّل باسمك';

  @override
  String createGroupCta(String name) {
    return 'إنشاء «$name»';
  }

  @override
  String groupCreatedToast(String name) {
    return 'أُنشئت «$name»';
  }

  @override
  String get theGroup => 'المجموعة';

  @override
  String get weekdaySun => 'الأحد';

  @override
  String get weekdayMon => 'الاثنين';

  @override
  String get weekdayTue => 'الثلاثاء';

  @override
  String get weekdayWed => 'الأربعاء';

  @override
  String get weekdayThu => 'الخميس';

  @override
  String get weekdayFri => 'الجمعة';

  @override
  String get weekdaySat => 'السبت';

  @override
  String get scheduleEditTitle => 'الجدول الأسبوعي';

  @override
  String get scheduleAddSlot => '+ حصة أسبوعية';

  @override
  String get scheduleEmptyHint =>
      'لا جدول بعد: بلا جدول لا تُنشأ جلسات لهذه المجموعة.';

  @override
  String get scheduleRecorded =>
      '⦿ يُسجَّل التعديل باسمك، وتُنشأ جلسات الأسابيع القادمة فورًا.';

  @override
  String get scheduleSavedToast => 'حُفظ الجدول';

  @override
  String get newFamilyTitle => 'أسرة جديدة';

  @override
  String get reviewStepTitle => 'المراجعة';

  @override
  String stepOfThree(int step) {
    return 'الخطوة $step من 3';
  }

  @override
  String get guardianNameHint => 'اسم ولي الأمر';

  @override
  String get guardianPhoneHint => '6XX XXX XXX';

  @override
  String get addGuardian => '+ ولي آخر';

  @override
  String childN(int n) {
    return 'الطفل $n';
  }

  @override
  String get remove => 'إزالة';

  @override
  String get childNameHint => 'اسم الطفل';

  @override
  String get dobLabel => 'تاريخ الولادة';

  @override
  String get dobPick => 'اختر التاريخ';

  @override
  String get mainGroupLabel => 'المجموعة الرئيسية';

  @override
  String get groupLater => 'لاحقًا';

  @override
  String get groupFull => 'ممتلئة';

  @override
  String get healthNotHere =>
      'المعلومات الصحية يُدخلها الولي من حسابه — لا هنا.';

  @override
  String get addChild => '+ طفل آخر';

  @override
  String get whatHappens => 'ماذا سيحدث';

  @override
  String willInvite(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '• دعوة SMS إلى $count أولياء؛ يوافقون على الخصوصية وحقوق الصورة قبل رؤية أي شيء.',
      two: '• دعوة SMS إلى وليَّين؛ يوافقان على الخصوصية وحقوق الصورة قبل رؤية أي شيء.',
      one: '• دعوة SMS إلى ولي واحد؛ يوافق على الخصوصية وحقوق الصورة قبل رؤية أي شيء.',
    );
    return '$_temp0';
  }

  @override
  String get willShow => '• يظهر الأطفال للولي مع المجموعة والجدول والمؤطر.';

  @override
  String get willLog => '• ⦿ يُسجَّل الإنشاء باسمك.';

  @override
  String unassignedWarn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '▲ $count أطفال بلا مجموعة — لن يراهم أي مؤطر حتى يُسندوا.',
      two: '▲ طفلان بلا مجموعة — لن يراهما أي مؤطر حتى يُسندا.',
      one: '▲ طفل واحد بلا مجموعة — لن يراه أي مؤطر حتى يُسند.',
    );
    return '$_temp0';
  }

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String createAndInvite(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إنشاء وإرسال $count دعوة',
      many: 'إنشاء وإرسال $count دعوة',
      few: 'إنشاء وإرسال $count دعوات',
      two: 'إنشاء وإرسال دعوتين',
      one: 'إنشاء وإرسال دعوة واحدة',
      zero: 'إنشاء',
    );
    return '$_temp0';
  }

  @override
  String familyCreatedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُنشئت الأسرة · $count دعوة',
      many: 'أُنشئت الأسرة · $count دعوة',
      few: 'أُنشئت الأسرة · $count دعوات',
      two: 'أُنشئت الأسرة · دعوتان',
      one: 'أُنشئت الأسرة · دعوة واحدة',
      zero: 'أُنشئت الأسرة',
    );
    return '$_temp0';
  }

  @override
  String get reportsTitle => 'التقارير';

  @override
  String get repTabAttendance => 'الحضور';

  @override
  String get repTabEducators => 'المؤطرون';

  @override
  String get repTabEngagement => 'التفاعل';

  @override
  String get repTabExport => 'التصدير';

  @override
  String get repByEducator => 'نسبة الحضور حسب المؤطر';

  @override
  String get repByCategory => 'حسب الفئة';

  @override
  String get repRawNote => 'النسبة مع العدد الخام';

  @override
  String repPlanned(int delivered, int planned) {
    return 'مخطَّطة/مُنجزة $delivered/$planned';
  }

  @override
  String repOnTime(int ontime, int planned) {
    return 'في وقته $ontime من $planned';
  }

  @override
  String get repReplyUnknown => 'الرد —';

  @override
  String get repActivated => 'تفعيل حسابات الأولياء';

  @override
  String get repPresenceAnswers => 'الرد على تأكيد الحضور';

  @override
  String get repHomework => 'إنجاز الواجبات';

  @override
  String get selfReported => 'تصريح ذاتي';

  @override
  String get repNotYet => 'غير متاح بعد';

  @override
  String get repNoData => 'لا بيانات بعد';

  @override
  String get exportIntro =>
      'تصدير قائمة الأطفال. الحقول الصحية معطَّلة افتراضيًا.';

  @override
  String get exportName => 'الاسم الكامل';

  @override
  String get exportDob => 'تاريخ الولادة';

  @override
  String get exportGroup => 'الفئة والمجموعة';

  @override
  String get exportGuardian => 'اسم ولي الأمر';

  @override
  String get exportPhone => 'هاتف ولي الأمر';

  @override
  String get exportConsent => 'حقوق الصورة';

  @override
  String get exportAllergies => 'الحساسية';

  @override
  String get exportMedications => 'الأدوية';

  @override
  String get healthTag => 'صحي';

  @override
  String get exportLogged => 'يُسجَّل التصدير باسمك والحقول المختارة.';

  @override
  String get exportContainsHealth => 'يحتوي بيانات صحية — للجهة المعنية فقط.';

  @override
  String exportCta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إنشاء الملف · $count حقل',
      many: 'إنشاء الملف · $count حقلًا',
      few: 'إنشاء الملف · $count حقول',
      two: 'إنشاء الملف · حقلان',
      one: 'إنشاء الملف · حقل واحد',
    );
    return '$_temp0';
  }

  @override
  String get exportBusy => 'يُجهَّز الملف…';

  @override
  String get exportReady => 'الملف جاهز';

  @override
  String exportRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صف',
      many: '$count صفًا',
      few: '$count صفوف',
      two: 'صفان',
      one: 'صف واحد',
      zero: 'لا صفوف',
    );
    return '$_temp0';
  }

  @override
  String get exportShare => 'مشاركة الملف';

  @override
  String get exportLoggedToast => 'سُجّل التصدير باسمك';

  @override
  String get structureTitle => 'الهيكل';

  @override
  String get strTabSeasons => 'المواسم';

  @override
  String get strTabCategories => 'الفئات';

  @override
  String get strTabBranches => 'الفروع';

  @override
  String get seasonActive => 'نشط';

  @override
  String get seasonArchived => 'مؤرشف';

  @override
  String get seasonArchive => 'أرشفة';

  @override
  String get seasonsNote => 'المواسم تُؤرشف ولا تُحذف.';

  @override
  String get archiveKind => 'أرشفة — قابلة للتراجع';

  @override
  String archiveTitle(String label) {
    return 'أرشفة موسم $label؟';
  }

  @override
  String get archiveBody =>
      'تُغلق المجموعات والتسجيلات للقراءة فقط. لا يُحذف شيء.';

  @override
  String get archiveLog => 'تُسجَّل الأرشفة باسمك.';

  @override
  String get archiveCta => 'أرشفة الموسم';

  @override
  String get archivedToast => 'أُرشف الموسم';

  @override
  String get catsOpenDecision =>
      'الفئات العمرية والجنس قرار مجلس الإدارة ولم يُتَّخذ بعد. الحقول فارغة عن قصد.';

  @override
  String get catAgeGenderUnset => 'العمر/الجنس: لم يُحدَّد';

  @override
  String catAgeRange(int min, int max) {
    return '$min–$max سنة';
  }

  @override
  String get genderBoys => 'ذكور';

  @override
  String get genderGirls => 'إناث';

  @override
  String get genderMixed => 'مختلط';

  @override
  String get branchesNote =>
      'فرع واحد اليوم. عند إضافة ثانٍ يظهر محدِّد الفرع للإداريين.';

  @override
  String get newBranch => '+ فرع جديد';

  @override
  String get branchNameHint => 'اسم الفرع';

  @override
  String get branchAddressHint => 'العنوان';

  @override
  String get branchCreatedToast => 'أُنشئ الفرع';

  @override
  String get newCategory => '+ فئة جديدة';

  @override
  String get categoryNameHint => 'اسم الفئة';

  @override
  String get categoryCreatedToast => 'أُنشئت الفئة';

  @override
  String get newSeason => '+ موسم جديد';

  @override
  String get seasonLabelHint => 'اسم الموسم، مثل 2026-2027';

  @override
  String get seasonStartPick => 'تاريخ البداية';

  @override
  String get seasonEndPick => 'تاريخ النهاية';

  @override
  String get seasonCreatedToast => 'فُتح الموسم';

  @override
  String get adminOnlyTitle => 'هذا القسم لمدير النظام فقط';

  @override
  String adminOnlyBody(String role) {
    return 'صلاحيتك: $role. اطلبها من رئيس الجمعية.';
  }

  @override
  String get adminOnlyLogged => '⦿ محاولة الوصول مسجَّلة — هذا طبيعي.';

  @override
  String get logsTitle => 'السجلات';

  @override
  String get logTabAudit => 'التدقيق';

  @override
  String get logTabHealth => 'الوصول الصحي';

  @override
  String get logsAppendOnly => '⦿ إضافيّ فقط — لا تعديل ولا حذف. مدة الاحتفاظ:';

  @override
  String get retentionUnset => 'لم تُحدَّد بعد';

  @override
  String get healthLogIntro =>
      'من عرض المعلومات الصحية لأي طفل ومتى — الوعد الذي يُقطَع عند كل «عرض».';

  @override
  String get logsEmpty => 'لا سجلات بعد';

  @override
  String get actionLogin => 'دخول';

  @override
  String get actionCorrect => 'تصحيح حضور';

  @override
  String get actionExport => 'تصدير';

  @override
  String get actionHideMessage => 'إخفاء رسالة';

  @override
  String get actionHealthView => 'عرض بيانات صحية';

  @override
  String get actionPhoneReveal => 'إظهار هاتف';

  @override
  String get actionAssign => 'إسناد';

  @override
  String get actionCreate => 'إنشاء';

  @override
  String get actionPublish => 'نشر إعلان';

  @override
  String get actionApprovePost => 'اعتماد منشور';

  @override
  String get actionHidePost => 'إخفاء منشور';

  @override
  String get actionOversightRead => 'قراءة إشرافية';

  @override
  String get actionDenied => 'محاولة وصول مرفوضة';

  @override
  String get actionArchive => 'أرشفة';

  @override
  String get actionDismissReport => 'رفض بلاغ';

  @override
  String get actionInvite => 'إعادة دعوة';

  @override
  String get actionOther => 'إجراء';

  @override
  String get eduTabToday => 'اليوم';

  @override
  String get eduTabSessions => 'الجلسات';

  @override
  String get eduTabGroups => 'المجموعات';

  @override
  String get eduTabMessages => 'الرسائل';

  @override
  String get eduTabMemories => 'الذكريات';

  @override
  String get eduGreetingMorning => 'صباح الخير';

  @override
  String get eduGreetingEvening => 'مساء الخير';

  @override
  String get todayNextSession => 'الجلسة التالية';

  @override
  String todayInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بعد $count دقيقة',
      many: 'بعد $count دقيقة',
      few: 'بعد $count دقائق',
      two: 'بعد دقيقتين',
      one: 'بعد دقيقة',
      zero: 'الآن',
    );
    return '$_temp0';
  }

  @override
  String get todayLive => 'جارية الآن';

  @override
  String get presTallyYes => 'سيحضر';

  @override
  String get presTallyLate => 'متأخر';

  @override
  String get presTallyNo => 'لن يحضر';

  @override
  String get presTallyNone => 'بلا رد';

  @override
  String get todayRecordAttendance => 'تسجيل الحضور';

  @override
  String todayAttendanceDone(String group) {
    return 'سُجّل حضور $group';
  }

  @override
  String todayAttendanceSummary(
    int present,
    int late,
    int excused,
    int absent,
  ) {
    return 'حاضر $present · متأخر $late · معذور $excused · غائب $absent';
  }

  @override
  String get todaySessionSummaryCta => 'ملخص الجلسة';

  @override
  String todayNoContent(String group, String time) {
    return 'لم تُضف محتوى جلسة $group · $time بعد — أنشئت تلقائيًا من الجدول.';
  }

  @override
  String get todayAdd => 'إضافة';

  @override
  String get shortcutHomework => 'واجب';

  @override
  String get shortcutMemory => 'ذكرى';

  @override
  String get shortcutAnnouncement => 'إعلان';

  @override
  String get todayFromManagement => 'من الإدارة';

  @override
  String get todayAckCta => 'قرأتُ';

  @override
  String get todayAckDone => '✓ أكّدت القراءة';

  @override
  String get todayNoSession => 'لا جلسة اليوم';

  @override
  String todayNextOn(String date) {
    return 'التالية: $date';
  }

  @override
  String get todayNoSessionsAtAll =>
      'لا جلسات قادمة — تأكد من جدول مجموعاتك مع الإداري.';

  @override
  String get presTitle => 'تأكيد الحضور';

  @override
  String presSubtitle(String group, String time, String sent) {
    return '$group · $time · أُرسل $sent تلقائيًا';
  }

  @override
  String presSubtitleNotSent(String group, String time) {
    return '$group · $time · لم يُرسل بعد';
  }

  @override
  String get presPlanning => 'للتخطيط (الأدوات، الوجبة، النقل)';

  @override
  String presExpectedOf(int count) {
    return 'متوقَّع من $count';
  }

  @override
  String presRemind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تذكير من لم يردّ ($count)',
      many: 'تذكير من لم يردّ ($count)',
      few: 'تذكير من لم يردّ ($count)',
      two: 'تذكير من لم يردّ (2)',
      one: 'تذكير من لم يردّ (1)',
      zero: 'لا أحد بلا رد',
    );
    return '$_temp0';
  }

  @override
  String get presRemindDone => '✓ أُرسل التذكير';

  @override
  String presRemindNote(String time) {
    return 'التذكير يُرسل مرة واحدة فقط — الموعد النهائي $time';
  }

  @override
  String presRemindedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُرسل تذكير إلى $count وليّ',
      many: 'أُرسل تذكير إلى $count وليًّا',
      few: 'أُرسل تذكير إلى $count أولياء',
      two: 'أُرسل تذكير إلى وليَّين',
      one: 'أُرسل تذكير إلى وليّ واحد',
      zero: 'لا أحد لتذكيره',
    );
    return '$_temp0';
  }

  @override
  String get presNotSent => 'لم يُرسل طلب تأكيد لهذه الجلسة.';

  @override
  String attTitle(String group) {
    return 'حضور $group';
  }

  @override
  String attSubtitle(String time, String title) {
    return '$time · $title · معبّأ من تأكيدات الأولياء';
  }

  @override
  String attUnmarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بلا تسجيل',
      many: '$count بلا تسجيل',
      few: '$count بلا تسجيل',
      two: '2 بلا تسجيل',
      one: '1 بلا تسجيل',
      zero: 'الكل مسجَّل',
    );
    return '$_temp0';
  }

  @override
  String attMarkRest(int count) {
    return '✓ تسجيل الباقين ($count) حاضرين';
  }

  @override
  String get attPresYes => 'أكّد الولي الحضور';

  @override
  String get attPresLate => 'أعلن التأخر';

  @override
  String get attPresNo => 'أعلن الغياب';

  @override
  String get attPresNone => 'لم يردّ الولي';

  @override
  String get attSave => 'حفظ الحضور';

  @override
  String attSaveAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حفظ · تنبيه $count وليّ',
      many: 'حفظ · تنبيه $count وليًّا',
      few: 'حفظ · تنبيه $count أولياء',
      two: 'حفظ · تنبيه وليَّين',
      one: 'حفظ · تنبيه وليّ واحد',
    );
    return '$_temp0';
  }

  @override
  String get attSaveOffline => 'حفظ على الهاتف';

  @override
  String get attEditHint => 'يمكن التعديل خلال 30 دقيقة، بعدها عبر الإداري';

  @override
  String get attUnmarkedKind => 'قبل الحفظ';

  @override
  String attUnmarkedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طفل بلا تسجيل',
      many: '$count طفلًا بلا تسجيل',
      few: '$count أطفال بلا تسجيل',
      two: 'طفلان بلا تسجيل',
      one: 'طفل واحد بلا تسجيل',
    );
    return '$_temp0';
  }

  @override
  String get attUnmarkedBody =>
      'سجّل حالة كل طفل. إن كانوا غير موجودين فعلًا، اختر «غائب» — سيُبلَّغ أولياؤهم فورًا.';

  @override
  String get attUnmarkedCta => 'متابعة التسجيل';

  @override
  String get attAlertKind => 'تنبيه أمان للأولياء';

  @override
  String attAlertTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيُبلَّغ أولياء $count طفل فورًا',
      many: 'سيُبلَّغ أولياء $count طفلًا فورًا',
      few: 'سيُبلَّغ أولياء $count أطفال فورًا',
      two: 'سيُبلَّغ أولياء طفلين فورًا',
      one: 'سيُبلَّغ وليّ طفل واحد فورًا',
    );
    return '$_temp0';
  }

  @override
  String attAlertBody(String names) {
    return '$names غائب دون إشعار مسبق. يصل لأوليائهم إشعار فوري (وSMS إن لم يفتحوا التطبيق)، لأن الولي قد يظنّ أن طفله هنا.';
  }

  @override
  String get attAlertCta => 'حفظ وإرسال التنبيه';

  @override
  String get attAlertCancel => 'مراجعة القائمة';

  @override
  String attSavedAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سُجّل الحضور · أُبلغ $count وليّ',
      many: 'سُجّل الحضور · أُبلغ $count وليًّا',
      few: 'سُجّل الحضور · أُبلغ $count أولياء',
      two: 'سُجّل الحضور · أُبلغ وليَّان',
      one: 'سُجّل الحضور · أُبلغ وليّ واحد',
    );
    return '$_temp0';
  }

  @override
  String get attStatusExcusedShort => 'معذور';

  @override
  String get sessTitle => 'الجلسات';

  @override
  String sessWeekRange(String from, String to) {
    return 'أسبوع $from – $to';
  }

  @override
  String get sessPrevWeek => 'الأسبوع السابق';

  @override
  String get sessNextWeek => 'الأسبوع التالي';

  @override
  String get sessAllGroups => 'كل مجموعاتي';

  @override
  String get sessStateUpcoming => 'قادمة';

  @override
  String sessStateSoon(int count) {
    return 'بعد $count د';
  }

  @override
  String get sessStateLive => 'جارية';

  @override
  String get sessStateNoContent => 'بلا محتوى';

  @override
  String get sessStateMoved => 'مؤجَّلة';

  @override
  String sessMetaMaterials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مادة',
      many: '$count مادة',
      few: '$count مواد',
      two: 'مادتان',
      one: 'مادة واحدة',
      zero: 'بلا مواد',
    );
    return '$_temp0';
  }

  @override
  String get sessMetaHomework => 'واجب';

  @override
  String get sessMetaGenerated => 'أُنشئت من الجدول';

  @override
  String sessMetaWith(String name) {
    return 'مع $name';
  }

  @override
  String get sessFooter =>
      'الجلسات تُنشأ تلقائيًا من جدول المجموعة — أضف المحتوى فقط.';

  @override
  String get sessEmptyWeek => 'لا جلسات هذا الأسبوع';

  @override
  String get sessObjectives => 'الأهداف';

  @override
  String get sessMaterials => 'المواد';

  @override
  String get sessHomework => 'الواجب';

  @override
  String get sessAddHomework => '+ واجب';

  @override
  String sessHomeworkMeta(String target, String due, int done, int total) {
    return '$target · آخر أجل $due · $done/$total أنجز (تصريح الأولياء)';
  }

  @override
  String get sessWholeGroup => 'كل المجموعة';

  @override
  String get sessAttendanceDone => '✓ الحضور';

  @override
  String get sessSummaryDone => '✓ الملخّص';

  @override
  String get sessSummaryCta => 'ملخّص الجلسة';

  @override
  String get sessCancelCta => 'إلغاء أو تأجيل الجلسة';

  @override
  String get sessCancelledBanner =>
      '✕ ألغيت هذه الجلسة · أُبلغ الأولياء والفريق';

  @override
  String sessMovedBanner(String when) {
    return '⏱ أُجّلت إلى $when · أُبلغ الأولياء';
  }

  @override
  String get sessNoObjectives => 'لا أهداف بعد — أضفها من «تعديل».';

  @override
  String get sessNoMaterials => 'لا مواد بعد';

  @override
  String get sessNoHomework => 'لا واجب مرتبط بهذه الجلسة';

  @override
  String get sessEdit => 'تعديل';

  @override
  String get visBefore => 'قبل الجلسة';

  @override
  String get visAfter => 'بعد الجلسة';

  @override
  String get visStaff => 'للمؤطرين فقط';

  @override
  String get matKindDocument => 'ملف';

  @override
  String get matKindImage => 'صورة';

  @override
  String get matKindAudio => 'صوت';

  @override
  String get matKindVideo => 'فيديو';

  @override
  String get matKindLink => 'رابط';

  @override
  String get sessContentTitle => 'محتوى الجلسة';

  @override
  String sessContentSubtitle(String group, String time) {
    return '$group · $time · من الجدول الأسبوعي';
  }

  @override
  String get sessTitleHint => 'مثال: حلقة القرآن — سورة الملك';

  @override
  String get sessTheme => 'المحور';

  @override
  String get themeQuran => 'القرآن الكريم';

  @override
  String get themeSira => 'السيرة';

  @override
  String get themeAkhlaq => 'الأخلاق';

  @override
  String get themeHadith => 'الحديث';

  @override
  String get themeSkills => 'المهارات';

  @override
  String get sessObjectivesHint => 'هدف في كل سطر…';

  @override
  String get sessMaterialsWho => 'المواد ومن يراها';

  @override
  String get sessVideoLimit => 'فيديو ≤ 50 م.ب · الطويل كرابط';

  @override
  String get addFile => '+ ملف';

  @override
  String get addPhoto => '+ صورة';

  @override
  String get addAudio => '+ صوت';

  @override
  String get addLink => '+ رابط';

  @override
  String get sessSaveContent => 'حفظ المحتوى';

  @override
  String get sessContentSaved => 'حُفظ محتوى الجلسة';

  @override
  String get linkUrlHint => 'https://…';

  @override
  String get linkTitleHint => 'عنوان الرابط';

  @override
  String get linkAdd => 'إضافة الرابط';

  @override
  String get uploadFailed => 'تعذّر رفع الملف';

  @override
  String get sumTitle => 'ماذا فعلنا اليوم؟';

  @override
  String sumSubtitle(String group) {
    return 'ملخّص يصل لأولياء $group';
  }

  @override
  String get sumHint =>
      'اكتب ما حفظه الأطفال وتعلّموه، وما ترجو من الأولياء مراجعته…';

  @override
  String get sumConsentNote =>
      'الصور التي تظهر فيها وجوه تمرّ عبر وسم حقوق الصورة مثل الذكريات.';

  @override
  String sumConsentBlocked(String name) {
    return '$name «غير مسموح» — لا تُرفق صورة يظهر فيها.';
  }

  @override
  String sumReach(int families, int guardians) {
    return 'يصل إلى $families أسرة ($guardians وليًّا) · يظهر في صفحة الجلسة لدى الأولياء';
  }

  @override
  String get sumSend => 'إرسال لأولياء المجموعة';

  @override
  String get sumSent => '✓ أُرسل للأولياء';

  @override
  String sumSentToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُرسل الملخّص إلى $count أسرة',
      many: 'أُرسل الملخّص إلى $count أسرة',
      few: 'أُرسل الملخّص إلى $count أسر',
      two: 'أُرسل الملخّص إلى أسرتين',
      one: 'أُرسل الملخّص إلى أسرة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get cancelSheetTitle => 'إلغاء أو تأجيل الجلسة';

  @override
  String get cancelModeCancel => 'إلغاء';

  @override
  String get cancelModeMove => 'تأجيل';

  @override
  String get cancelNewSlot => 'الموعد الجديد';

  @override
  String get cancelPickSlot => 'اختر الموعد الجديد';

  @override
  String get cancelReasonHint => 'السبب (يراه الأولياء)…';

  @override
  String cancelNotice(int guardians) {
    return 'يُبلَّغ تلقائيًا $guardians وليًّا، والمؤطرون المشاركون، والإداريون. ⦿ يُسجَّل باسمك.';
  }

  @override
  String get cancelCta => 'إلغاء وإبلاغ الجميع';

  @override
  String get moveCta => 'تأجيل وإبلاغ الجميع';

  @override
  String cancelledToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُلغيت الجلسة · أُبلغ $count شخص',
      many: 'أُلغيت الجلسة · أُبلغ $count شخصًا',
      few: 'أُلغيت الجلسة · أُبلغ $count أشخاص',
      two: 'أُلغيت الجلسة · أُبلغ شخصان',
      one: 'أُلغيت الجلسة · أُبلغ شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String movedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُجّلت الجلسة · أُبلغ $count شخص',
      many: 'أُجّلت الجلسة · أُبلغ $count شخصًا',
      few: 'أُجّلت الجلسة · أُبلغ $count أشخاص',
      two: 'أُجّلت الجلسة · أُبلغ شخصان',
      one: 'أُجّلت الجلسة · أُبلغ شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String get hwNewTitle => 'واجب جديد';

  @override
  String hwNewSubtitle(String day, String group) {
    return 'مرتبط بجلسة $day · $group';
  }

  @override
  String get hwInstructions => 'التعليمات';

  @override
  String get hwInstructionsHint => 'ما المطلوب من الطفل؟';

  @override
  String get hwTitleHint => 'مثال: مراجعة الآيات 1–10';

  @override
  String get hwFor => 'لمن؟';

  @override
  String hwWholeGroup(int count) {
    return 'كل المجموعة ($count)';
  }

  @override
  String get hwSpecific => 'أطفال محددون';

  @override
  String get hwDue => 'آخر أجل';

  @override
  String get hwReminderNote =>
      'تذكير تلقائي للأولياء قبل الأجل بيوم إن لم يُعلَّم «أُنجز».';

  @override
  String get hwAttachment => '+ مرفق (ورقة الحفظ، تسجيل صوتي…)';

  @override
  String hwAttachmentAdded(String name) {
    return '✓ مرفق: $name';
  }

  @override
  String hwSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إرسال لـ $count طفل',
      many: 'إرسال لـ $count طفلًا',
      few: 'إرسال لـ $count أطفال',
      two: 'إرسال لطفلين',
      one: 'إرسال لطفل واحد',
      zero: 'اختر الأطفال',
    );
    return '$_temp0';
  }

  @override
  String get hwPickOne => 'اختر طفلًا واحدًا على الأقل';

  @override
  String get hwSentToast => 'أُرسل الواجب للأولياء';

  @override
  String get eduGroupsTitle => 'مجموعاتي';

  @override
  String get eduGroupsSubtitle => 'ترى أطفال مجموعاتك فقط';

  @override
  String get eduGroupsEmpty => 'لا مجموعات مسندة إليك';

  @override
  String get statAttendance => 'الحضور';

  @override
  String get statHomework => 'الواجبات';

  @override
  String get statNext => 'القادمة';

  @override
  String groupFlag(String name) {
    return '$name غاب 3 مرات متتالية — تواصل رعاية';
  }

  @override
  String get eduGroupsFooter =>
      'إضافة الأطفال أو نقلهم بين المجموعات يتمّ عبر الإداري.';

  @override
  String get grpTabHomework => 'الواجبات';

  @override
  String get grpTabStaff => 'قناة الفريق';

  @override
  String rosterAttendance(int present, int expected) {
    return 'حضور $present/$expected';
  }

  @override
  String get rosterNew => 'جديد';

  @override
  String get rosterCare => '▲ غاب 3 مرات متتالية — للمتابعة';

  @override
  String get hwStateOpen => 'جارٍ';

  @override
  String get hwStateClosed => 'منتهٍ';

  @override
  String hwListMeta(String target, String date) {
    return '$target · آخر أجل $date';
  }

  @override
  String hwListMetaClosed(String target, String date) {
    return '$target · انتهى $date';
  }

  @override
  String hwTargetChildren(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طفل',
      many: '$count طفلًا',
      few: '$count أطفال',
      two: 'طفلان',
      one: 'طفل واحد',
    );
    return '$_temp0';
  }

  @override
  String get hwFooter => 'الإنجاز تصريح من الأولياء · لا ترتيب علني للأطفال';

  @override
  String get hwEmpty => 'لا واجبات بعد';

  @override
  String get staffChannelNote =>
      'قناة المؤطرين والإداريين — لا يراها الأولياء.';

  @override
  String get staffChannelOpen => 'فتح قناة الفريق';

  @override
  String get staffChannelMissing => 'لا قناة فريق لهذه المجموعة بعد';

  @override
  String get guardianMessage => 'مراسلة';

  @override
  String get guardianEmergency => 'طوارئ';

  @override
  String get guardianEmergencyHint => 'الرقم لا يظهر · الاتصال عبر التطبيق';

  @override
  String get guardianCall => '☏ اتصال';

  @override
  String get guardianCallToast => 'اتصال عبر التطبيق — الرقم مخفي · ⦿ مُسجَّل';

  @override
  String get guardianCallUnavailable => 'لا رقم مسجَّل لهذا الولي';

  @override
  String get notesTitle => 'ملاحظات';

  @override
  String get notesPhase2 => 'المرحلة الثانية';

  @override
  String get notesStaff => 'للفريق فقط';

  @override
  String get notesShared => 'للأولياء';

  @override
  String get notesStaffBody =>
      'ملاحظات يراها المؤطرون والإداريون فقط — تُفعَّل في المرحلة الثانية.';

  @override
  String get notesSharedBody =>
      'ملاحظات تصل للأولياء — تُفعَّل في المرحلة الثانية.';

  @override
  String get eduChildHomeworkTile => 'الواجبات';

  @override
  String msgAvailability(String window) {
    return 'ساعات تواجدك $window · خارجها تصل الرسائل بصمت';
  }

  @override
  String get msgAvailabilityUnset => 'لم تحدد ساعات التواجد بعد — من «المزيد»';

  @override
  String msgSectionChildrenOf(String group) {
    return 'محادثات الأطفال · $group';
  }

  @override
  String get msgSectionTeam => 'الفريق والإدارة';

  @override
  String get msgFooterEdu =>
      'لا توجد محادثة خاصة مع طفل — كل محادثة تضمّ الأولياء ومؤطري المجموعة.';

  @override
  String get quickReply1 => 'وعليكم السلام، جزاكم الله خيرًا';

  @override
  String get quickReply2 => 'ما شاء الله، أحسن اليوم';

  @override
  String get quickReply3 => 'نراكم في الجلسة القادمة إن شاء الله';

  @override
  String get msgComposerHintEdu => 'اكتب رسالة…';

  @override
  String get eduMemSubtitle => 'خاصة بأولياء مجموعاتك · لا مشاركة خارجية';

  @override
  String get memNewPost => '+ منشور';

  @override
  String get memMyPosts => 'منشوراتي';

  @override
  String get memAlbumsTitle => 'الألبومات';

  @override
  String get memStatePending => 'بانتظار الاعتماد';

  @override
  String get memStatePublished => 'منشور';

  @override
  String get memStateEdit => 'طُلب تعديل';

  @override
  String memMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صورة',
      many: '$count صورة',
      few: '$count صور',
      two: 'صورتان',
      one: 'صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String memTaggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count موسوم',
      many: '$count موسومًا',
      few: '$count موسومين',
      two: 'موسومان',
      one: 'موسوم واحد',
      zero: 'بلا وسم',
    );
    return '$_temp0';
  }

  @override
  String get memMyPostsEmpty => 'لم تنشر بعد — أضف أول ذكرى لمجموعتك.';

  @override
  String memPostsInAlbum(int count) {
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
  String get memComposeTitle => 'منشور جديد';

  @override
  String get memComposeSubtitle => 'يُعرض على الإداري قبل النشر';

  @override
  String get memComposeSubtitleLive => 'يُنشر فورًا لأولياء المجموعة';

  @override
  String get memAlbumLabel => 'الألبوم';

  @override
  String get memAudienceLabel => 'الجمهور';

  @override
  String memAudienceOf(String group) {
    return 'أولياء $group';
  }

  @override
  String get memAudienceAll => 'أولياء الجمعية';

  @override
  String get memPickAlbum => 'اختر ألبومًا';

  @override
  String get memCaptionHint => 'اكتب تعليقًا قصيرًا…';

  @override
  String get memTagTitle => 'وسم الأطفال الظاهرين';

  @override
  String memTagCount(int count) {
    return '$count موسوم';
  }

  @override
  String memBlocked(String name) {
    return '⊘ لا يمكن وسم $name — حقوق الصورة «غير مسموح». إن كان ظاهرًا في صورة، احذفها قبل النشر.';
  }

  @override
  String get memSubmit => 'إرسال للاعتماد';

  @override
  String get memPublish => 'نشر';

  @override
  String get memSubmittedToast => 'أُرسل للإداري للاعتماد';

  @override
  String get memPublishedToast => 'نُشر لأولياء المجموعة';

  @override
  String get memNeedMedia => 'أضف صورة واحدة على الأقل';

  @override
  String get memUploading => 'جارٍ الرفع…';

  @override
  String get memConsentBlockedToast => 'أزل الأطفال الممنوعين قبل النشر';

  @override
  String get memRemovePhoto => 'إزالة الصورة';

  @override
  String get annEduTitle => 'إعلان لمجموعاتي';

  @override
  String get annToGuardians => 'إلى أولياء';

  @override
  String annReachGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يصل إلى $count وليّ + المؤطرين المشاركين',
      many: 'يصل إلى $count وليًّا + المؤطرين المشاركين',
      few: 'يصل إلى $count أولياء + المؤطرين المشاركين',
      two: 'يصل إلى وليَّين + المؤطرين المشاركين',
      one: 'يصل إلى وليّ واحد + المؤطرين المشاركين',
      zero: 'لا أحد',
    );
    return '$_temp0';
  }

  @override
  String get annPickGroup => 'اختر مجموعة واحدة على الأقل';

  @override
  String get annAckTitle => 'طلب تأكيد «قرأتُ»';

  @override
  String get annAckBody => 'ترى من أكّد القراءة ومن لم يؤكد';

  @override
  String get annUrgentExecOnly =>
      'الإعلانات العاجلة (SMS) من صلاحية الإداريين فقط.';

  @override
  String get annPublishCta => 'نشر';

  @override
  String annPublishedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نُشر الإعلان إلى $count وليّ',
      many: 'نُشر الإعلان إلى $count وليًّا',
      few: 'نُشر الإعلان إلى $count أولياء',
      two: 'نُشر الإعلان إلى وليَّين',
      one: 'نُشر الإعلان إلى وليّ واحد',
      zero: 'نُشر الإعلان',
    );
    return '$_temp0';
  }

  @override
  String moreEduRole(String groups) {
    return 'مؤطر · $groups';
  }

  @override
  String get availTitle => 'ساعات التواجد';

  @override
  String get availBody =>
      'خارجها تصل رسائل الأولياء بصمت، ويرون ملاحظة برقم الجمعية للأمور العاجلة.';

  @override
  String get availSavedToast => 'حُفظت ساعات التواجد';

  @override
  String get attReminderRow => 'تذكير تسجيل الحضور';

  @override
  String get attReminderLocked => 'بعد 30 دقيقة · مقفل';

  @override
  String get offlineAttendanceBanner =>
      '⦸ بلا اتصال — الحضور يُحفظ على الهاتف ويُزامَن عند عودة الشبكة.';

  @override
  String get notAvailableToYou => 'غير متاح لك';
}

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
}

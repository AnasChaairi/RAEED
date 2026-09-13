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
}

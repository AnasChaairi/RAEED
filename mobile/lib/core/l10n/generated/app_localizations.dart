import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The application name as shown in the app bar and launcher.
  ///
  /// In ar, this message translates to:
  /// **'الرائد'**
  String get appName;

  /// Button that re-runs a failed request.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get commonConfirm;

  /// No description provided for @commonContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get commonContinue;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get commonBack;

  /// Shown when the device cannot reach the server at all.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkBody.
  ///
  /// In ar, this message translates to:
  /// **'تحقّق من اتصالك بالإنترنت ثم أعد المحاولة.'**
  String get errorNetworkBody;

  /// No description provided for @errorGenericTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericBody.
  ///
  /// In ar, this message translates to:
  /// **'لم نتمكّن من إتمام العملية. أعد المحاولة بعد قليل.'**
  String get errorGenericBody;

  /// Shown for scope.forbidden — the caller is authenticated but outside their permission scope. Deliberately does not say whether the resource exists.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح لك'**
  String get errorForbiddenTitle;

  /// No description provided for @errorForbiddenBody.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك صلاحية الاطلاع على هذا المحتوى. تواصل مع إدارة الأكاديمية إن كنت ترى أن هذا خطأ.'**
  String get errorForbiddenBody;

  /// No description provided for @errorSessionExpiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجلسة'**
  String get errorSessionExpiredTitle;

  /// No description provided for @errorSessionExpiredBody.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تسجيل الدخول من جديد.'**
  String get errorSessionExpiredBody;

  /// Shown when the server response does not match what this app build understands.
  ///
  /// In ar, this message translates to:
  /// **'تحديث مطلوب'**
  String get errorContractTitle;

  /// No description provided for @errorContractBody.
  ///
  /// In ar, this message translates to:
  /// **'هذه النسخة من التطبيق لم تعد متوافقة مع الخادم. يرجى تحديث التطبيق.'**
  String get errorContractBody;

  /// Persistent banner shown while the device is offline and the screen is showing cached data.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل بالإنترنت. تُعرض آخر البيانات المحفوظة.'**
  String get offlineBannerMessage;

  /// Subtle banner on a screen that is showing cached content because the refresh failed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحديث'**
  String get offlineRefreshFailed;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا بك في الرائد'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك لتلقّي رمز الدخول.'**
  String get loginSubtitle;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'‎+212 6XX XXX XXX'**
  String get loginPhoneHint;

  /// No description provided for @loginPhoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف صحيحًا.'**
  String get loginPhoneInvalid;

  /// No description provided for @loginRequestCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رمز الدخول'**
  String get loginRequestCode;

  /// Registration is Executive/Admin-only (ACC-02) — there is no public sign-up.
  ///
  /// In ar, this message translates to:
  /// **'الحسابات تُنشأ من طرف إدارة الأكاديمية فقط. إن لم يكن لديك حساب، تواصل مع الإدارة.'**
  String get loginNoAccountNotice;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز الدخول'**
  String get otpTitle;

  /// Confirms where the OTP was sent. The phone number is masked before it reaches this string.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رمزًا من ستة أرقام إلى {phone}.'**
  String otpSentTo(String phone);

  /// No description provided for @otpCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرمز'**
  String get otpCodeLabel;

  /// No description provided for @otpVerify.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get otpVerify;

  /// No description provided for @otpInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الرمز غير صحيح أو انتهت صلاحيته.'**
  String get otpInvalid;

  /// No description provided for @otpRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'لقد طلبت رموزًا كثيرة. حاول مجددًا بعد ساعة.'**
  String get otpRateLimited;

  /// No description provided for @otpResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get otpResend;

  /// Countdown before the resend button re-enables. All six Arabic plural categories are authored, not defaulted.
  ///
  /// In ar, this message translates to:
  /// **'{seconds, plural, zero{يمكنك إعادة الإرسال الآن} one{إعادة الإرسال بعد ثانية واحدة} two{إعادة الإرسال بعد ثانيتين} few{إعادة الإرسال بعد {seconds} ثوانٍ} many{إعادة الإرسال بعد {seconds} ثانية} other{إعادة الإرسال بعد {seconds} ثانية}}'**
  String otpResendIn(int seconds);

  /// No description provided for @consentTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية وحقوق الصورة'**
  String get consentTitle;

  /// No description provided for @consentIntro.
  ///
  /// In ar, this message translates to:
  /// **'قبل المتابعة، نحتاج موافقتك على سياسة الخصوصية وتحديد مستوى حقوق الصورة لكل طفل.'**
  String get consentIntro;

  /// No description provided for @consentPrivacyPolicyAccept.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على سياسة الخصوصية'**
  String get consentPrivacyPolicyAccept;

  /// No description provided for @consentPrivacyPolicyRead.
  ///
  /// In ar, this message translates to:
  /// **'قراءة سياسة الخصوصية'**
  String get consentPrivacyPolicyRead;

  /// No description provided for @consentImageRightsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حقوق الصورة'**
  String get consentImageRightsTitle;

  /// No description provided for @consentImageRightsForChild.
  ///
  /// In ar, this message translates to:
  /// **'حقوق الصورة لـ {childName}'**
  String consentImageRightsForChild(String childName);

  /// image_rights_level = allowed
  ///
  /// In ar, this message translates to:
  /// **'مسموح'**
  String get consentImageRightsAllowed;

  /// No description provided for @consentImageRightsAllowedHelp.
  ///
  /// In ar, this message translates to:
  /// **'يمكن نشر صور الطفل داخل التطبيق وفي القنوات الرسمية للأكاديمية.'**
  String get consentImageRightsAllowedHelp;

  /// image_rights_level = app_only
  ///
  /// In ar, this message translates to:
  /// **'داخل التطبيق فقط'**
  String get consentImageRightsAppOnly;

  /// No description provided for @consentImageRightsAppOnlyHelp.
  ///
  /// In ar, this message translates to:
  /// **'تُعرض صور الطفل داخل التطبيق فقط، ولا تُنشر خارجه.'**
  String get consentImageRightsAppOnlyHelp;

  /// image_rights_level = not_allowed — the most restrictive level, and the default.
  ///
  /// In ar, this message translates to:
  /// **'غير مسموح'**
  String get consentImageRightsNotAllowed;

  /// No description provided for @consentImageRightsNotAllowedHelp.
  ///
  /// In ar, this message translates to:
  /// **'لن تُنشر أي صورة للطفل في أي مكان.'**
  String get consentImageRightsNotAllowedHelp;

  /// No description provided for @consentChangeLater.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تغيير هذا الاختيار في أي وقت من إعدادات الطفل.'**
  String get consentChangeLater;

  /// No description provided for @consentSubmit.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الموافقات'**
  String get consentSubmit;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navSchedule.
  ///
  /// In ar, this message translates to:
  /// **'الجدول'**
  String get navSchedule;

  /// No description provided for @navMessages.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل'**
  String get navMessages;

  /// No description provided for @navMemories.
  ///
  /// In ar, this message translates to:
  /// **'الذكريات'**
  String get navMemories;

  /// No description provided for @navMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get navMore;

  /// No description provided for @navGroups.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get navGroups;

  /// No description provided for @navDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة القيادة'**
  String get navDashboard;

  /// No description provided for @roleParent.
  ///
  /// In ar, this message translates to:
  /// **'وليّ الأمر'**
  String get roleParent;

  /// No description provided for @roleEducator.
  ///
  /// In ar, this message translates to:
  /// **'مؤطِّر'**
  String get roleEducator;

  /// No description provided for @roleExecutive.
  ///
  /// In ar, this message translates to:
  /// **'مشرف'**
  String get roleExecutive;

  /// No description provided for @roleAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام'**
  String get roleAdmin;

  /// A user may hold more than one role — e.g. an educator who is also a parent.
  ///
  /// In ar, this message translates to:
  /// **'تبديل الدور'**
  String get roleSwitchTitle;

  /// No description provided for @notFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة غير موجودة'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In ar, this message translates to:
  /// **'الرابط الذي فتحته لم يعد صالحًا.'**
  String get notFoundBody;

  /// No description provided for @notFoundGoHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الرئيسية'**
  String get notFoundGoHome;

  /// Parent home screen title.
  ///
  /// In ar, this message translates to:
  /// **'أطفالي'**
  String get homeTitleParent;

  /// No description provided for @homeTitleEducator.
  ///
  /// In ar, this message translates to:
  /// **'مجموعاتي'**
  String get homeTitleEducator;

  /// No description provided for @homeTitleExecutive.
  ///
  /// In ar, this message translates to:
  /// **'الأطفال'**
  String get homeTitleExecutive;

  /// Should not occur post-onboarding; if it does it signals a data problem, so the copy points at the association rather than at the user.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أي طفل مرتبط بحسابك'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'يرجى التواصل مع إدارة الأكاديمية لربط طفلك بحسابك.'**
  String get homeEmptyBody;

  /// A child's age. Arabic needs all six categories: 3-10 take few, 11-99 take many.
  ///
  /// In ar, this message translates to:
  /// **'{years, plural, zero{أقل من سنة} one{سنة واحدة} two{سنتان} few{{years} سنوات} many{{years} سنة} other{{years} سنة}}'**
  String childAgeYears(int years);

  /// No description provided for @childNoSessionToday.
  ///
  /// In ar, this message translates to:
  /// **'لا حصة اليوم'**
  String get childNoSessionToday;

  /// No description provided for @childNextSession.
  ///
  /// In ar, this message translates to:
  /// **'الحصة القادمة: {when}'**
  String childNextSession(String when);

  /// A presence confirmation is open and unanswered — tappable.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار تأكيد الحضور'**
  String get statusAwaitingAnswer;

  /// No description provided for @statusPresenceConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكَّد الحضور'**
  String get statusPresenceConfirmed;

  /// No description provided for @statusPresenceDeclined.
  ///
  /// In ar, this message translates to:
  /// **'غياب معلَن'**
  String get statusPresenceDeclined;

  /// No description provided for @statusPresenceLate.
  ///
  /// In ar, this message translates to:
  /// **'سيتأخر'**
  String get statusPresenceLate;

  /// No description provided for @statusPresent.
  ///
  /// In ar, this message translates to:
  /// **'حاضر'**
  String get statusPresent;

  /// No description provided for @statusLate.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get statusLate;

  /// No description provided for @statusAbsent.
  ///
  /// In ar, this message translates to:
  /// **'غائب'**
  String get statusAbsent;

  /// No description provided for @statusExcused.
  ///
  /// In ar, this message translates to:
  /// **'غياب بعذر'**
  String get statusExcused;

  /// A status this build predates; rendered neutrally rather than crashing.
  ///
  /// In ar, this message translates to:
  /// **'—'**
  String get statusUnknown;

  /// High-contrast alert state overriding the status pill (ATT-07).
  ///
  /// In ar, this message translates to:
  /// **'غياب بدون إشعار'**
  String get absenceAlertTitle;

  /// Screen-reader label for the icon-only health badge. The health text itself is never rendered in a list view.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه صحي — اضغط للاطلاع'**
  String get healthAlertBadgeLabel;

  /// No description provided for @announcementsStripTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات'**
  String get announcementsStripTitle;

  /// No description provided for @announcementUrgent.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get announcementUrgent;

  /// No description provided for @announcementsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا إعلانات حاليًا'**
  String get announcementsEmpty;

  /// No description provided for @childProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملف الطفل'**
  String get childProfileTitle;

  /// No description provided for @childProfileGroupLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة'**
  String get childProfileGroupLabel;

  /// No description provided for @childProfileHealthTitle.
  ///
  /// In ar, this message translates to:
  /// **'معلومات صحية'**
  String get childProfileHealthTitle;

  /// No description provided for @childProfileNoHealthInfo.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معلومات صحية مسجَّلة.'**
  String get childProfileNoHealthInfo;

  /// No description provided for @childHealthAllergies.
  ///
  /// In ar, this message translates to:
  /// **'حساسية'**
  String get childHealthAllergies;

  /// No description provided for @childHealthConditions.
  ///
  /// In ar, this message translates to:
  /// **'حالات صحية'**
  String get childHealthConditions;

  /// No description provided for @childHealthMedications.
  ///
  /// In ar, this message translates to:
  /// **'أدوية'**
  String get childHealthMedications;

  /// No description provided for @childHealthDiet.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات غذائية'**
  String get childHealthDiet;

  /// No description provided for @childHealthOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get childHealthOther;

  /// No description provided for @childProfileComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'سيتوفر هذا القسم قريبًا.'**
  String get childProfileComingSoon;

  /// No description provided for @pullToRefresh.
  ///
  /// In ar, this message translates to:
  /// **'اسحب للتحديث'**
  String get pullToRefresh;

  /// Child profile sub-tab.
  ///
  /// In ar, this message translates to:
  /// **'الجدول'**
  String get childTabSchedule;

  /// No description provided for @childTabAttendance.
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get childTabAttendance;

  /// No description provided for @childTabHomework.
  ///
  /// In ar, this message translates to:
  /// **'الواجبات'**
  String get childTabHomework;

  /// No description provided for @childTabMaterials.
  ///
  /// In ar, this message translates to:
  /// **'المواد'**
  String get childTabMaterials;

  /// Attendance marking screen title.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الحضور'**
  String get attendanceTitle;

  /// No description provided for @attendancePresent.
  ///
  /// In ar, this message translates to:
  /// **'حاضر'**
  String get attendancePresent;

  /// No description provided for @attendanceLate.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get attendanceLate;

  /// No description provided for @attendanceAbsent.
  ///
  /// In ar, this message translates to:
  /// **'غائب'**
  String get attendanceAbsent;

  /// No description provided for @attendanceExcused.
  ///
  /// In ar, this message translates to:
  /// **'بعذر'**
  String get attendanceExcused;

  /// No description provided for @attendanceNotMarked.
  ///
  /// In ar, this message translates to:
  /// **'لم يُسجَّل'**
  String get attendanceNotMarked;

  /// Live count of children whose guardian confirmed attendance. Arabic needs all six categories.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا مؤكَّد} one{مؤكَّد واحد} two{مؤكَّدان} few{{count} مؤكَّدين} many{{count} مؤكَّدًا} other{{count} مؤكَّد}}'**
  String attendanceSummaryConfirmed(int count);

  /// No description provided for @attendanceSummaryAbsent.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا غياب} one{غياب واحد} two{غيابان} few{{count} غيابات} many{{count} غيابًا} other{{count} غياب}}'**
  String attendanceSummaryAbsent(int count);

  /// No description provided for @attendanceSummaryNoAnswer.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا أحد بدون جواب} one{واحد بدون جواب} two{اثنان بدون جواب} few{{count} بدون جواب} many{{count} بدون جواب} other{{count} بدون جواب}}'**
  String attendanceSummaryNoAnswer(int count);

  /// Progress line above the marking bar. Two numbers, so not a plural — Arabic would need six categories for each and the pair reads as a fraction anyway.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل {marked} من {total}'**
  String attendanceMarkedOf(int marked, int total);

  /// No description provided for @attendanceMarkRemainingPresent.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الباقي حاضرين'**
  String get attendanceMarkRemainingPresent;

  /// No description provided for @attendanceSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get attendanceSubmit;

  /// No description provided for @attendanceSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الحضور'**
  String get attendanceSubmitted;

  /// Empty state for a group with no enrolled children.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أطفال في هذه المجموعة بعد'**
  String get attendanceEmptyGroup;

  /// Offline banner on the attendance screen. Must never read as an error — marking offline is a supported flow, and submission is never blocked.
  ///
  /// In ar, this message translates to:
  /// **'محفوظ على هذا الجهاز، سيُرسل عند عودة الاتصال'**
  String get attendanceOfflineSaved;

  /// No description provided for @attendancePendingCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا شيء بانتظار الإرسال} one{تسجيل واحد بانتظار الإرسال} two{تسجيلان بانتظار الإرسال} few{{count} تسجيلات بانتظار الإرسال} many{{count} تسجيلًا بانتظار الإرسال} other{{count} تسجيل بانتظار الإرسال}}'**
  String attendancePendingCount(int count);

  /// A mark this device made was refused as stale. Never silently discarded.
  ///
  /// In ar, this message translates to:
  /// **'تعارض في التسجيل'**
  String get attendanceConflictTitle;

  /// No description provided for @attendanceConflictBody.
  ///
  /// In ar, this message translates to:
  /// **'سجّلت {attempted} لهذا الطفل، لكن تم تسجيل {server} قبل ذلك من جهاز آخر.'**
  String attendanceConflictBody(String attempted, String server);

  /// No description provided for @attendanceConflictKeepMine.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد تسجيلي'**
  String get attendanceConflictKeepMine;

  /// No description provided for @attendanceConflictKeepServer.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد المسجَّل'**
  String get attendanceConflictKeepServer;

  /// No description provided for @attendanceUnknownChild.
  ///
  /// In ar, this message translates to:
  /// **'لم يعد هذا الطفل ضمن هذه المجموعة، ولم يُسجَّل.'**
  String get attendanceUnknownChild;

  /// No description provided for @presenceTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحضور'**
  String get presenceTitle;

  /// No description provided for @presenceQuestion.
  ///
  /// In ar, this message translates to:
  /// **'هل سيحضر {childName} حصة {when}؟'**
  String presenceQuestion(String childName, String when);

  /// No description provided for @presenceYes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get presenceYes;

  /// No description provided for @presenceNo.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get presenceNo;

  /// No description provided for @presenceLate.
  ///
  /// In ar, this message translates to:
  /// **'سيتأخر'**
  String get presenceLate;

  /// No description provided for @presenceReasonPrompt.
  ///
  /// In ar, this message translates to:
  /// **'السبب (اختياري)'**
  String get presenceReasonPrompt;

  /// No description provided for @presenceReasonIllness.
  ///
  /// In ar, this message translates to:
  /// **'مرض'**
  String get presenceReasonIllness;

  /// No description provided for @presenceReasonTravel.
  ///
  /// In ar, this message translates to:
  /// **'سفر'**
  String get presenceReasonTravel;

  /// No description provided for @presenceReasonExam.
  ///
  /// In ar, this message translates to:
  /// **'امتحان'**
  String get presenceReasonExam;

  /// No description provided for @presenceReasonOther.
  ///
  /// In ar, this message translates to:
  /// **'سبب آخر'**
  String get presenceReasonOther;

  /// No description provided for @presenceOtherNoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'اذكر السبب'**
  String get presenceOtherNoteLabel;

  /// No description provided for @presenceAnswered.
  ///
  /// In ar, this message translates to:
  /// **'شكرًا، تم تسجيل جوابك'**
  String get presenceAnswered;

  /// No description provided for @presenceNoneOutstanding.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تأكيدات معلّقة'**
  String get presenceNoneOutstanding;

  /// The academy's motto, shown under the wordmark on sign-in.
  ///
  /// In ar, this message translates to:
  /// **'صالح في نفسه، مصلح لغيره'**
  String get brandTagline;

  /// No description provided for @otpEnterCode.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز'**
  String get otpEnterCode;

  /// No description provided for @consentStepOf.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة {current} من {total}'**
  String consentStepOf(int current, int total);

  /// Compact affordance on a child whose level is not set yet.
  ///
  /// In ar, this message translates to:
  /// **'اختر'**
  String get consentChoose;

  /// No description provided for @homeGreeting.
  ///
  /// In ar, this message translates to:
  /// **'السلام عليكم'**
  String get homeGreeting;

  /// No description provided for @homeTodaySessions.
  ///
  /// In ar, this message translates to:
  /// **'جلسات اليوم'**
  String get homeTodaySessions;

  /// No description provided for @homeNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get homeNotifications;

  /// Screen-reader label for the bell.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{الإشعارات} one{الإشعارات، إشعار غير مقروء} two{الإشعارات، إشعاران غير مقروءين} few{الإشعارات، {count} إشعارات غير مقروءة} many{الإشعارات، {count} إشعارًا غير مقروء} other{الإشعارات، {count} إشعار غير مقروء}}'**
  String homeNotificationsWithUnread(int count);

  /// Header of the presence-confirmation prompt on Home.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج ردّك'**
  String get homeNeedsYourReply;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppL10nAr();
    case 'en':
      return AppL10nEn();
    case 'fr':
      return AppL10nFr();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

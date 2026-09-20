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

  /// No description provided for @execTabDashboard.
  ///
  /// In ar, this message translates to:
  /// **'اللوحة'**
  String get execTabDashboard;

  /// No description provided for @execTabAnnouncements.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات'**
  String get execTabAnnouncements;

  /// No description provided for @execTabMessages.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل'**
  String get execTabMessages;

  /// No description provided for @execTabMemories.
  ///
  /// In ar, this message translates to:
  /// **'الذكريات'**
  String get execTabMemories;

  /// No description provided for @execTabGroups.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get execTabGroups;

  /// No description provided for @execNavLabel.
  ///
  /// In ar, this message translates to:
  /// **'التنقل'**
  String get execNavLabel;

  /// No description provided for @execMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get execMore;

  /// No description provided for @execScopeAllBranches.
  ///
  /// In ar, this message translates to:
  /// **'كل الفروع'**
  String get execScopeAllBranches;

  /// No description provided for @execScopeRestricted.
  ///
  /// In ar, this message translates to:
  /// **'فرعك فقط (مقيَّد)'**
  String get execScopeRestricted;

  /// No description provided for @execStaleOffline.
  ///
  /// In ar, this message translates to:
  /// **'بلا اتصال — تُعرض آخر نسخة ({time}).'**
  String execStaleOffline(String time);

  /// No description provided for @execStaleRefreshFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحديث — تُعرض نسخة {time}.'**
  String execStaleRefreshFailed(String time);

  /// No description provided for @recordedActionMarker.
  ///
  /// In ar, this message translates to:
  /// **'هذا الإجراء يُسجَّل باسمك مع الوقت والجهاز.'**
  String get recordedActionMarker;

  /// No description provided for @recordedShort.
  ///
  /// In ar, this message translates to:
  /// **'مُسجَّل'**
  String get recordedShort;

  /// No description provided for @dashSessionsToday.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا جلسات اليوم} one{جلسة واحدة اليوم} two{جلستان اليوم} few{{count} جلسات اليوم} many{{count} جلسة اليوم} other{{count} جلسة اليوم}}'**
  String dashSessionsToday(int count);

  /// No description provided for @dashSessionsBreakdown.
  ///
  /// In ar, this message translates to:
  /// **'{live} جارية · {upcoming} قادمة'**
  String dashSessionsBreakdown(int live, int upcoming);

  /// No description provided for @dashNeedsAttention.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج انتباهك'**
  String get dashNeedsAttention;

  /// No description provided for @dashNoAlertsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا شيء يحتاج انتباهك اليوم'**
  String get dashNoAlertsTitle;

  /// No description provided for @dashNoAlertsBody.
  ///
  /// In ar, this message translates to:
  /// **'لا تنبيهات ولا طلبات معلقة الآن.'**
  String get dashNoAlertsBody;

  /// No description provided for @severityDanger.
  ///
  /// In ar, this message translates to:
  /// **'خطر'**
  String get severityDanger;

  /// No description provided for @severityWarning.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get severityWarning;

  /// No description provided for @severityInfo.
  ///
  /// In ar, this message translates to:
  /// **'للعلم'**
  String get severityInfo;

  /// No description provided for @statChildren.
  ///
  /// In ar, this message translates to:
  /// **'الأطفال'**
  String get statChildren;

  /// No description provided for @statFamilies.
  ///
  /// In ar, this message translates to:
  /// **'الأسر'**
  String get statFamilies;

  /// No description provided for @statGroups.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get statGroups;

  /// No description provided for @statEducators.
  ///
  /// In ar, this message translates to:
  /// **'المؤطرون'**
  String get statEducators;

  /// No description provided for @dashWeeklyAttendance.
  ///
  /// In ar, this message translates to:
  /// **'حضور الأسبوع'**
  String get dashWeeklyAttendance;

  /// No description provided for @dashTooLittleData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات غير كافية بعد'**
  String get dashTooLittleData;

  /// No description provided for @dashTodaySessions.
  ///
  /// In ar, this message translates to:
  /// **'جلسات اليوم'**
  String get dashTodaySessions;

  /// No description provided for @dashNoSessionsToday.
  ///
  /// In ar, this message translates to:
  /// **'لا جلسات اليوم'**
  String get dashNoSessionsToday;

  /// No description provided for @sessionAttendanceRecorded.
  ///
  /// In ar, this message translates to:
  /// **'مسجَّل'**
  String get sessionAttendanceRecorded;

  /// No description provided for @sessionAttendanceNotRecorded.
  ///
  /// In ar, this message translates to:
  /// **'غير مسجَّل'**
  String get sessionAttendanceNotRecorded;

  /// No description provided for @sessionAttendanceLive.
  ///
  /// In ar, this message translates to:
  /// **'جارية'**
  String get sessionAttendanceLive;

  /// No description provided for @sessionAttendanceUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'قادمة'**
  String get sessionAttendanceUpcoming;

  /// No description provided for @annNew.
  ///
  /// In ar, this message translates to:
  /// **'إعلان جديد'**
  String get annNew;

  /// No description provided for @annStatePublished.
  ///
  /// In ar, this message translates to:
  /// **'منشور'**
  String get annStatePublished;

  /// No description provided for @annStateScheduled.
  ///
  /// In ar, this message translates to:
  /// **'مجدوَل'**
  String get annStateScheduled;

  /// No description provided for @annStateDraft.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get annStateDraft;

  /// No description provided for @annStateExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهٍ'**
  String get annStateExpired;

  /// No description provided for @annReadBy.
  ///
  /// In ar, this message translates to:
  /// **'قرأه {percent}%'**
  String annReadBy(int percent);

  /// No description provided for @annPinned.
  ///
  /// In ar, this message translates to:
  /// **'مثبَّت'**
  String get annPinned;

  /// No description provided for @annEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا إعلانات بعد'**
  String get annEmptyTitle;

  /// No description provided for @annEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ أول إعلان لأولياء الأمور أو المؤطرين.'**
  String get annEmptyBody;

  /// No description provided for @annMetaPublished.
  ///
  /// In ar, this message translates to:
  /// **'نُشر {when}'**
  String annMetaPublished(String when);

  /// No description provided for @annMetaScheduled.
  ///
  /// In ar, this message translates to:
  /// **'مجدوَل {when}'**
  String annMetaScheduled(String when);

  /// No description provided for @annMetaExpires.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي {when}'**
  String annMetaExpires(String when);

  /// No description provided for @annFieldTitle.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get annFieldTitle;

  /// No description provided for @annFieldBody.
  ///
  /// In ar, this message translates to:
  /// **'النص'**
  String get annFieldBody;

  /// No description provided for @annTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الإعلان'**
  String get annTitleHint;

  /// No description provided for @annBodyHint.
  ///
  /// In ar, this message translates to:
  /// **'نص الإعلان'**
  String get annBodyHint;

  /// No description provided for @annFieldAudience.
  ///
  /// In ar, this message translates to:
  /// **'الجمهور'**
  String get annFieldAudience;

  /// No description provided for @annChange.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get annChange;

  /// No description provided for @annPublishTiming.
  ///
  /// In ar, this message translates to:
  /// **'النشر'**
  String get annPublishTiming;

  /// No description provided for @annPublishNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get annPublishNow;

  /// No description provided for @annExpires.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي'**
  String get annExpires;

  /// No description provided for @annNoExpiry.
  ///
  /// In ar, this message translates to:
  /// **'بلا انتهاء'**
  String get annNoExpiry;

  /// No description provided for @annUrgentTitle.
  ///
  /// In ar, this message translates to:
  /// **'أولوية عاجلة'**
  String get annUrgentTitle;

  /// No description provided for @annUrgentBody.
  ///
  /// In ar, this message translates to:
  /// **'إشعار فوري + SMS لمن لم يفتح التطبيق. للطوارئ فقط.'**
  String get annUrgentBody;

  /// No description provided for @annSend.
  ///
  /// In ar, this message translates to:
  /// **'نشر الإعلان'**
  String get annSend;

  /// No description provided for @annSendUrgent.
  ///
  /// In ar, this message translates to:
  /// **'إرسال عاجل · {reach}'**
  String annSendUrgent(int reach);

  /// No description provided for @annAudienceSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'من يصله الإعلان؟'**
  String get annAudienceSheetTitle;

  /// No description provided for @audAll.
  ///
  /// In ar, this message translates to:
  /// **'الجميع'**
  String get audAll;

  /// No description provided for @audParents.
  ///
  /// In ar, this message translates to:
  /// **'أولياء الأمور فقط'**
  String get audParents;

  /// No description provided for @audEducators.
  ///
  /// In ar, this message translates to:
  /// **'المؤطرون فقط'**
  String get audEducators;

  /// No description provided for @audCategories.
  ///
  /// In ar, this message translates to:
  /// **'فئات محددة'**
  String get audCategories;

  /// No description provided for @audCategoriesHeading.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get audCategoriesHeading;

  /// No description provided for @audPeople.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا أحد} one{شخص واحد} two{شخصان} few{{count} أشخاص} many{{count} شخصًا} other{{count} شخص}}'**
  String audPeople(int count);

  /// No description provided for @audDone.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get audDone;

  /// No description provided for @audSummaryAll.
  ///
  /// In ar, this message translates to:
  /// **'كل الأولياء والمؤطرين في نطاقك.'**
  String get audSummaryAll;

  /// No description provided for @audSummaryParents.
  ///
  /// In ar, this message translates to:
  /// **'كل أولياء أمور الأطفال المسجَّلين.'**
  String get audSummaryParents;

  /// No description provided for @audSummaryEducators.
  ///
  /// In ar, this message translates to:
  /// **'المؤطرون دون الأولياء.'**
  String get audSummaryEducators;

  /// No description provided for @audSummaryCategories.
  ///
  /// In ar, this message translates to:
  /// **'أولياء أطفال: {names}.'**
  String audSummaryCategories(String names);

  /// No description provided for @audSummaryNone.
  ///
  /// In ar, this message translates to:
  /// **'لم تختر فئة — لن يصل لأحد.'**
  String get audSummaryNone;

  /// No description provided for @annUrgentConfirmKind.
  ///
  /// In ar, this message translates to:
  /// **'واسع الأثر — قناة حرجة'**
  String get annUrgentConfirmKind;

  /// No description provided for @annUrgentConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{إرسال عاجل إلى لا أحد؟} one{إرسال عاجل إلى شخص واحد؟} two{إرسال عاجل إلى شخصين؟} few{إرسال عاجل إلى {count} أشخاص؟} many{إرسال عاجل إلى {count} شخصًا؟} other{إرسال عاجل إلى {count} شخص؟}}'**
  String annUrgentConfirmTitle(int count);

  /// No description provided for @annUrgentConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'إشعار فوري للجميع، وSMS لمن لم يفتح التطبيق خلال 10 دقائق، بتكلفة على الجمعية. للطوارئ فقط.'**
  String get annUrgentConfirmBody;

  /// No description provided for @annUrgentConfirmLog.
  ///
  /// In ar, this message translates to:
  /// **'يُسجَّل الإرسال العاجل باسمك مع الجمهور والتكلفة.'**
  String get annUrgentConfirmLog;

  /// No description provided for @annUrgentConfirmCta.
  ///
  /// In ar, this message translates to:
  /// **'نعم، إرسال عاجل'**
  String get annUrgentConfirmCta;

  /// No description provided for @annPublished.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{نُشر الإعلان} one{نُشر الإعلان إلى شخص واحد} two{نُشر الإعلان إلى شخصين} few{نُشر الإعلان إلى {count} أشخاص} many{نُشر الإعلان إلى {count} شخصًا} other{نُشر الإعلان إلى {count} شخص}}'**
  String annPublished(int count);

  /// No description provided for @annPublishedUrgent.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{أُرسل الإعلان العاجل} one{أُرسل الإعلان العاجل إلى شخص واحد} two{أُرسل الإعلان العاجل إلى شخصين} few{أُرسل الإعلان العاجل إلى {count} أشخاص} many{أُرسل الإعلان العاجل إلى {count} شخصًا} other{أُرسل الإعلان العاجل إلى {count} شخص}}'**
  String annPublishedUrgent(int count);

  /// No description provided for @annUrgentTag.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get annUrgentTag;

  /// No description provided for @msgOversightSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إشراف — قراءتك للمحادثات التي لست عضوًا فيها تُسجَّل.'**
  String get msgOversightSubtitle;

  /// No description provided for @msgSectionChildren.
  ///
  /// In ar, this message translates to:
  /// **'محادثات الأطفال'**
  String get msgSectionChildren;

  /// No description provided for @msgSectionStaff.
  ///
  /// In ar, this message translates to:
  /// **'قنوات المؤطرين'**
  String get msgSectionStaff;

  /// No description provided for @msgSectionExecutives.
  ///
  /// In ar, this message translates to:
  /// **'المشرفون'**
  String get msgSectionExecutives;

  /// No description provided for @msgEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا محادثات بعد'**
  String get msgEmptyTitle;

  /// No description provided for @msgEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'تُنشأ محادثة لكل طفل عند تسجيله.'**
  String get msgEmptyBody;

  /// No description provided for @msgOversightNotice.
  ///
  /// In ar, this message translates to:
  /// **'لست عضوًا هنا — قراءتك إشرافٌ مُسجَّل ومعلوم للأعضاء.'**
  String get msgOversightNotice;

  /// No description provided for @msgReportedBy.
  ///
  /// In ar, this message translates to:
  /// **'بلاغ من {name}: {reason}'**
  String msgReportedBy(String name, String reason);

  /// No description provided for @msgHide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get msgHide;

  /// No description provided for @msgDismissReport.
  ///
  /// In ar, this message translates to:
  /// **'رفض البلاغ'**
  String get msgDismissReport;

  /// No description provided for @msgHiddenStub.
  ///
  /// In ar, this message translates to:
  /// **'مخفية · أخفاها {name} {time} · يراها المشرفون فقط'**
  String msgHiddenStub(String name, String time);

  /// No description provided for @msgComposerHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب كمشرف…'**
  String get msgComposerHint;

  /// No description provided for @msgSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get msgSend;

  /// No description provided for @msgVoiceNote.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل صوتي'**
  String get msgVoiceNote;

  /// No description provided for @msgHideConfirmKind.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء — قابل للتراجع'**
  String get msgHideConfirmKind;

  /// No description provided for @msgHideConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء رسالة {name}؟'**
  String msgHideConfirmTitle(String name);

  /// No description provided for @msgHideConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'تختفي عن الأعضاء وتبقى للمشرفين بعلامة «مخفية». لا حذف نهائي. سيُبلَّغ المرسل بالسبب.'**
  String get msgHideConfirmBody;

  /// No description provided for @msgHideConfirmLog.
  ///
  /// In ar, this message translates to:
  /// **'يُسجَّل الإخفاء باسمك ويُقفل البلاغ.'**
  String get msgHideConfirmLog;

  /// No description provided for @msgHideConfirmCta.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الرسالة'**
  String get msgHideConfirmCta;

  /// No description provided for @msgHiddenToast.
  ///
  /// In ar, this message translates to:
  /// **'أُخفيت الرسالة'**
  String get msgHiddenToast;

  /// No description provided for @msgReportDismissedToast.
  ///
  /// In ar, this message translates to:
  /// **'رُفض البلاغ'**
  String get msgReportDismissedToast;

  /// No description provided for @msgThreadEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا رسائل بعد'**
  String get msgThreadEmpty;

  /// No description provided for @memTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الذكريات'**
  String get memTitle;

  /// No description provided for @memQueueLeft.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا منشورات بانتظارك} one{منشور واحد بانتظارك} two{منشوران بانتظارك} few{{count} منشورات بانتظارك} many{{count} منشورًا بانتظارك} other{{count} منشور بانتظارك}}'**
  String memQueueLeft(int count);

  /// No description provided for @memModeApproveFirst.
  ///
  /// In ar, this message translates to:
  /// **'الاعتماد أولًا'**
  String get memModeApproveFirst;

  /// No description provided for @memModePublishThenReview.
  ///
  /// In ar, this message translates to:
  /// **'النشر ثم المراجعة'**
  String get memModePublishThenReview;

  /// No description provided for @memModeUnset.
  ///
  /// In ar, this message translates to:
  /// **'وضع المراجعة لم يُحدَّد بعد'**
  String get memModeUnset;

  /// No description provided for @memBlockedBadge.
  ///
  /// In ar, this message translates to:
  /// **'محجوب — حقوق الصورة تغيّرت بعد النشر'**
  String get memBlockedBadge;

  /// No description provided for @memBlockedBody.
  ///
  /// In ar, this message translates to:
  /// **'{name} صار «غير مسموح». أزل الصورة أو أبقِ المنشور مخفيًا.'**
  String memBlockedBody(String name);

  /// No description provided for @memCounter.
  ///
  /// In ar, this message translates to:
  /// **'{index} / {count}'**
  String memCounter(int index, int count);

  /// No description provided for @imageRightsAllowed.
  ///
  /// In ar, this message translates to:
  /// **'مسموح'**
  String get imageRightsAllowed;

  /// No description provided for @imageRightsAppOnly.
  ///
  /// In ar, this message translates to:
  /// **'داخل التطبيق فقط'**
  String get imageRightsAppOnly;

  /// No description provided for @imageRightsNotAllowed.
  ///
  /// In ar, this message translates to:
  /// **'غير مسموح'**
  String get imageRightsNotAllowed;

  /// No description provided for @imageRightsLabel.
  ///
  /// In ar, this message translates to:
  /// **'حقوق الصورة: {level}'**
  String imageRightsLabel(String level);

  /// No description provided for @memHide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get memHide;

  /// No description provided for @memEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get memEdit;

  /// No description provided for @memApprove.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد'**
  String get memApprove;

  /// No description provided for @memKeep.
  ///
  /// In ar, this message translates to:
  /// **'إبقاء'**
  String get memKeep;

  /// No description provided for @memReapprove.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الاعتماد'**
  String get memReapprove;

  /// No description provided for @memHideHint.
  ///
  /// In ar, this message translates to:
  /// **'الإخفاء ليس حذفًا — يبقى المنشور للمشرفين.'**
  String get memHideHint;

  /// No description provided for @memAllReviewedTitle.
  ///
  /// In ar, this message translates to:
  /// **'راجعت كل شيء'**
  String get memAllReviewedTitle;

  /// No description provided for @memAllReviewedBody.
  ///
  /// In ar, this message translates to:
  /// **'لا منشورات بانتظارك.'**
  String get memAllReviewedBody;

  /// No description provided for @memWall.
  ///
  /// In ar, this message translates to:
  /// **'الجدار'**
  String get memWall;

  /// No description provided for @memAlbumPosts.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا منشورات} one{منشور واحد} two{منشوران} few{{count} منشورات} many{{count} منشورًا} other{{count} منشور}}'**
  String memAlbumPosts(int count);

  /// No description provided for @memNoAlbums.
  ///
  /// In ar, this message translates to:
  /// **'لا ألبومات هذا الموسم'**
  String get memNoAlbums;

  /// No description provided for @memApprovedToast.
  ///
  /// In ar, this message translates to:
  /// **'اعتُمد المنشور'**
  String get memApprovedToast;

  /// No description provided for @memHiddenToast.
  ///
  /// In ar, this message translates to:
  /// **'أُخفي المنشور (لا حذف)'**
  String get memHiddenToast;

  /// No description provided for @grpCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا مجموعات} one{مجموعة واحدة} two{مجموعتان} few{{count} مجموعات} many{{count} مجموعة} other{{count} مجموعة}}'**
  String grpCount(int count);

  /// No description provided for @grpEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا مجموعات هذا الموسم'**
  String get grpEmptyTitle;

  /// No description provided for @grpEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'تُنشأ المجموعات من لوحة الويب.'**
  String get grpEmptyBody;

  /// No description provided for @grpOverCapacity.
  ///
  /// In ar, this message translates to:
  /// **'فوق السعة'**
  String get grpOverCapacity;

  /// No description provided for @grpTabSessions.
  ///
  /// In ar, this message translates to:
  /// **'الجلسات'**
  String get grpTabSessions;

  /// No description provided for @grpTabRoster.
  ///
  /// In ar, this message translates to:
  /// **'القائمة'**
  String get grpTabRoster;

  /// No description provided for @grpSessionsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا جلسات بعد'**
  String get grpSessionsEmpty;

  /// No description provided for @grpRosterEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا أطفال في هذه المجموعة'**
  String get grpRosterEmpty;

  /// No description provided for @sessionEnded.
  ///
  /// In ar, this message translates to:
  /// **'انتهت'**
  String get sessionEnded;

  /// No description provided for @sessionCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get sessionCancelled;

  /// No description provided for @sessionToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get sessionToday;

  /// No description provided for @reviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'حضور {group}'**
  String reviewTitle(String group);

  /// No description provided for @reviewRecordedBy.
  ///
  /// In ar, this message translates to:
  /// **'سجّله {name} {time}'**
  String reviewRecordedBy(String name, String time);

  /// No description provided for @reviewCorrect.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح'**
  String get reviewCorrect;

  /// No description provided for @reviewGuardianNoAnswer.
  ///
  /// In ar, this message translates to:
  /// **'بلا رد'**
  String get reviewGuardianNoAnswer;

  /// No description provided for @reviewGuardianConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'أكّد الولي الحضور'**
  String get reviewGuardianConfirmed;

  /// No description provided for @reviewGuardianDeclared.
  ///
  /// In ar, this message translates to:
  /// **'أعلن الولي الغياب'**
  String get reviewGuardianDeclared;

  /// No description provided for @reviewGuardianLate.
  ///
  /// In ar, this message translates to:
  /// **'أعلن الولي تأخره'**
  String get reviewGuardianLate;

  /// No description provided for @reviewTrailOriginal.
  ///
  /// In ar, this message translates to:
  /// **'سُجّل {status} — {name} · {time}'**
  String reviewTrailOriginal(String status, String name, String time);

  /// No description provided for @reviewTrailCorrected.
  ///
  /// In ar, this message translates to:
  /// **'صُحّح إلى {status} — {name} · {time}'**
  String reviewTrailCorrected(String status, String name, String time);

  /// No description provided for @reviewTrailRefers.
  ///
  /// In ar, this message translates to:
  /// **'يشير إلى #{id}'**
  String reviewTrailRefers(String id);

  /// No description provided for @reviewTrailNotified.
  ///
  /// In ar, this message translates to:
  /// **'أُبلغ الأولياء'**
  String get reviewTrailNotified;

  /// No description provided for @corrTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح حضور {name}'**
  String corrTitle(String name);

  /// No description provided for @corrBody.
  ///
  /// In ar, this message translates to:
  /// **'سجل جديد يشير إلى السجل الأصلي — لا يُمحى شيء. يظهر للأولياء والمؤطر.'**
  String get corrBody;

  /// No description provided for @corrNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختيارية)'**
  String get corrNoteHint;

  /// No description provided for @corrSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التصحيح'**
  String get corrSave;

  /// No description provided for @corrSavedToast.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف سجل تصحيح'**
  String get corrSavedToast;

  /// No description provided for @notifTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifTitle;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تعليم الكل كمقروء'**
  String get notifMarkAllRead;

  /// No description provided for @notifFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get notifFilterAll;

  /// No description provided for @notifFilterCritical.
  ///
  /// In ar, this message translates to:
  /// **'حرِج'**
  String get notifFilterCritical;

  /// No description provided for @notifFilterRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات'**
  String get notifFilterRequests;

  /// No description provided for @notifFilterMemories.
  ///
  /// In ar, this message translates to:
  /// **'الذكريات'**
  String get notifFilterMemories;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا جديد'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أنت على اطلاع بكل شيء.'**
  String get notifEmptyBody;

  /// No description provided for @timeJustNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get timeJustNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{الآن} one{قبل دقيقة} two{قبل دقيقتين} few{قبل {count} دقائق} many{قبل {count} دقيقة} other{قبل {count} دقيقة}}'**
  String timeAgoMinutes(int count);

  /// No description provided for @timeAgoHours.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{الآن} one{قبل ساعة} two{قبل ساعتين} few{قبل {count} ساعات} many{قبل {count} ساعة} other{قبل {count} ساعة}}'**
  String timeAgoHours(int count);

  /// No description provided for @timeAgoDays.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{اليوم} one{أمس} two{قبل يومين} few{قبل {count} أيام} many{قبل {count} يومًا} other{قبل {count} يوم}}'**
  String timeAgoDays(int count);

  /// No description provided for @moreCurrentRole.
  ///
  /// In ar, this message translates to:
  /// **'الدور الحالي'**
  String get moreCurrentRole;

  /// No description provided for @moreRolesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا أدوار} one{لديك دور واحد} two{لديك دوران} few{لديك {count} أدوار} many{لديك {count} دورًا} other{لديك {count} دور}}'**
  String moreRolesCount(int count);

  /// No description provided for @roleHintExecutive.
  ///
  /// In ar, this message translates to:
  /// **'لوحة المتابعة والإشراف على المجموعات كلها'**
  String get roleHintExecutive;

  /// No description provided for @roleHintAdmin.
  ///
  /// In ar, this message translates to:
  /// **'كل صلاحيات المشرف مع إدارة الهيكل والمستخدمين'**
  String get roleHintAdmin;

  /// No description provided for @roleHintEducator.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الحضور والواجبات لمجموعاتك'**
  String get roleHintEducator;

  /// No description provided for @roleHintParent.
  ///
  /// In ar, this message translates to:
  /// **'متابعة أطفالك'**
  String get roleHintParent;

  /// No description provided for @moreDarkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get moreDarkMode;

  /// No description provided for @moreLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get moreLanguage;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In ar, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @moreCriticalChannel.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات القناة الحرجة'**
  String get moreCriticalChannel;

  /// No description provided for @moreCriticalChannelLocked.
  ///
  /// In ar, this message translates to:
  /// **'مقفلة: تنبيهات الغياب والإعلانات العاجلة وتغييرات الجلسات خلال 24 ساعة تصل دائمًا.'**
  String get moreCriticalChannelLocked;

  /// No description provided for @moreVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String moreVersion(String version);

  /// No description provided for @moreTagline.
  ///
  /// In ar, this message translates to:
  /// **'صالح في نفسه، مصلح لغيره'**
  String get moreTagline;

  /// No description provided for @dialogCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get dialogCancel;
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

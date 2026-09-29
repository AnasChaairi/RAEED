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

  /// No description provided for @loginPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'6XX XXX XXX'**
  String get loginPhoneHint;

  /// No description provided for @loginPhoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف صحيحًا.'**
  String get loginPhoneInvalid;

  /// Registration is Executive/Admin-only (ACC-02) — there is no public sign-up.
  ///
  /// In ar, this message translates to:
  /// **'الحسابات تُنشأ من طرف إدارة الأكاديمية فقط. إن لم يكن لديك حساب، تواصل مع الإدارة.'**
  String get loginNoAccountNotice;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك وكلمة المرور.'**
  String get loginSubtitle;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordRule.
  ///
  /// In ar, this message translates to:
  /// **'6 أحرف أو أرقام'**
  String get loginPasswordRule;

  /// No description provided for @loginPasswordInvalid.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور من 6 أحرف أو أرقام بالضبط.'**
  String get loginPasswordInvalid;

  /// No description provided for @loginPasswordShow.
  ///
  /// In ar, this message translates to:
  /// **'إظهار كلمة المرور'**
  String get loginPasswordShow;

  /// No description provided for @loginPasswordHide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء كلمة المرور'**
  String get loginPasswordHide;

  /// No description provided for @loginSubmit.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get loginSubmit;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف أو كلمة المرور غير صحيحة.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة خاطئة. حاول مجددًا بعد 15 دقيقة.'**
  String get loginRateLimited;

  /// No description provided for @morePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get morePassword;

  /// No description provided for @pwdTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get pwdTitle;

  /// No description provided for @pwdIntro.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور من 6 أحرف أو أرقام. أدخل الحالية ثم الجديدة مرتين.'**
  String get pwdIntro;

  /// No description provided for @pwdCurrent.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get pwdCurrent;

  /// No description provided for @pwdNew.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get pwdNew;

  /// No description provided for @pwdConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور الجديدة'**
  String get pwdConfirm;

  /// No description provided for @pwdMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين.'**
  String get pwdMismatch;

  /// No description provided for @pwdWrongCurrent.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية غير صحيحة.'**
  String get pwdWrongCurrent;

  /// No description provided for @pwdSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get pwdSave;

  /// No description provided for @pwdSavedToast.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور'**
  String get pwdSavedToast;

  /// No description provided for @handoverTitle.
  ///
  /// In ar, this message translates to:
  /// **'كلمات المرور المؤقتة'**
  String get handoverTitle;

  /// No description provided for @handoverIntro.
  ///
  /// In ar, this message translates to:
  /// **'سلّمها للولي شخصيًا. تُعرض مرة واحدة فقط ولا تُرسل برسالة.'**
  String get handoverIntro;

  /// No description provided for @handoverExisting.
  ///
  /// In ar, this message translates to:
  /// **'لديه حساب من قبل — كلمة مروره لم تتغير.'**
  String get handoverExisting;

  /// No description provided for @handoverDone.
  ///
  /// In ar, this message translates to:
  /// **'سلّمتها'**
  String get handoverDone;

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
  /// **'إداري'**
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
  /// **'الإداريون'**
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
  /// **'مخفية · أخفاها {name} {time} · يراها الإداريون فقط'**
  String msgHiddenStub(String name, String time);

  /// No description provided for @msgComposerHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب كإداري…'**
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
  /// **'تختفي عن الأعضاء وتبقى للإداريين بعلامة «مخفية». لا حذف نهائي. سيُبلَّغ المرسل بالسبب.'**
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
  /// **'الإخفاء ليس حذفًا — يبقى المنشور للإداريين.'**
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
  /// **'كل صلاحيات الإداري مع إدارة الهيكل والمستخدمين'**
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

  /// No description provided for @moreChildren.
  ///
  /// In ar, this message translates to:
  /// **'الأطفال'**
  String get moreChildren;

  /// No description provided for @moreChildrenHint.
  ///
  /// In ar, this message translates to:
  /// **'الملفات والموافقات'**
  String get moreChildrenHint;

  /// No description provided for @moreManage.
  ///
  /// In ar, this message translates to:
  /// **'الأسر والمجموعات'**
  String get moreManage;

  /// No description provided for @moreManageHint.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مجموعة · أسرة جديدة · إسناد'**
  String get moreManageHint;

  /// No description provided for @moreReports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير والتصدير'**
  String get moreReports;

  /// No description provided for @moreReportsHint.
  ///
  /// In ar, this message translates to:
  /// **'حضور · مؤطرون · تفاعل'**
  String get moreReportsHint;

  /// No description provided for @moreStructure.
  ///
  /// In ar, this message translates to:
  /// **'الهيكل'**
  String get moreStructure;

  /// No description provided for @moreStructureHint.
  ///
  /// In ar, this message translates to:
  /// **'المواسم · الفئات · الفروع'**
  String get moreStructureHint;

  /// No description provided for @moreLogs.
  ///
  /// In ar, this message translates to:
  /// **'السجلات'**
  String get moreLogs;

  /// No description provided for @moreLogsHint.
  ///
  /// In ar, this message translates to:
  /// **'التدقيق · الوصول الصحي'**
  String get moreLogsHint;

  /// No description provided for @adminTag.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام'**
  String get adminTag;

  /// No description provided for @moreAdminHint.
  ///
  /// In ar, this message translates to:
  /// **'مدير النظام وحده يفتح «الهيكل» و«السجلات». محاولة غيره تُرفض وتُسجَّل.'**
  String get moreAdminHint;

  /// No description provided for @moreSignOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get moreSignOut;

  /// No description provided for @childrenCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا أطفال} one{طفل واحد} two{طفلان} few{{count} أطفال} many{{count} طفلًا} other{{count} طفل}}'**
  String childrenCount(int count);

  /// No description provided for @childrenSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن طفل'**
  String get childrenSearchHint;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @childrenEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا أطفال مطابقون'**
  String get childrenEmptyTitle;

  /// No description provided for @childrenEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'جرّب بحثًا آخر أو فئة أخرى.'**
  String get childrenEmptyBody;

  /// No description provided for @attendanceShort.
  ///
  /// In ar, this message translates to:
  /// **'حضور {ratio}'**
  String attendanceShort(String ratio);

  /// No description provided for @imageRightsLegend.
  ///
  /// In ar, this message translates to:
  /// **'حقوق الصورة:'**
  String get imageRightsLegend;

  /// No description provided for @childSeasonAttendance.
  ///
  /// In ar, this message translates to:
  /// **'حضور الموسم'**
  String get childSeasonAttendance;

  /// No description provided for @childImageRightsTile.
  ///
  /// In ar, this message translates to:
  /// **'حقوق الصورة'**
  String get childImageRightsTile;

  /// No description provided for @healthSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الصحية'**
  String get healthSectionTitle;

  /// No description provided for @healthEveryViewLogged.
  ///
  /// In ar, this message translates to:
  /// **'كل عرض يُسجَّل'**
  String get healthEveryViewLogged;

  /// No description provided for @healthCollapsedBody.
  ///
  /// In ar, this message translates to:
  /// **'يوجد تنبيه صحي. المحتوى مطويٌّ عمدًا — يظهر عند طلبك ويُقيَّد في سجل الوصول الصحي.'**
  String get healthCollapsedBody;

  /// No description provided for @healthNoneBody.
  ///
  /// In ar, this message translates to:
  /// **'لا تنبيه صحي مسجَّل لهذا الطفل.'**
  String get healthNoneBody;

  /// No description provided for @healthShowButton.
  ///
  /// In ar, this message translates to:
  /// **'عرض المعلومات الصحية'**
  String get healthShowButton;

  /// No description provided for @healthConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'سيُسجَّل هذا العرض'**
  String get healthConfirmTitle;

  /// No description provided for @healthConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُقيَّد أن {actor} عرض بيانات {child} الصحية الآن. لا تفتحه بلا سبب.'**
  String healthConfirmBody(String actor, String child);

  /// No description provided for @healthContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get healthContinue;

  /// No description provided for @healthBack.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get healthBack;

  /// No description provided for @healthAlertTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنبيه الصحي'**
  String get healthAlertTitle;

  /// No description provided for @healthRecordedAt.
  ///
  /// In ar, this message translates to:
  /// **'سُجّل {time}'**
  String healthRecordedAt(String time);

  /// No description provided for @healthFieldsPending.
  ///
  /// In ar, this message translates to:
  /// **'الحقول التفصيلية تُقرَّ بعد تصريح CNDP.'**
  String get healthFieldsPending;

  /// No description provided for @healthCollapse.
  ///
  /// In ar, this message translates to:
  /// **'طيّ'**
  String get healthCollapse;

  /// No description provided for @healthAllergies.
  ///
  /// In ar, this message translates to:
  /// **'الحساسية'**
  String get healthAllergies;

  /// No description provided for @healthConditions.
  ///
  /// In ar, this message translates to:
  /// **'الحالات الصحية'**
  String get healthConditions;

  /// No description provided for @healthMedications.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get healthMedications;

  /// No description provided for @healthDietary.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات غذائية'**
  String get healthDietary;

  /// No description provided for @healthSpecialNeeds.
  ///
  /// In ar, this message translates to:
  /// **'احتياجات خاصة'**
  String get healthSpecialNeeds;

  /// No description provided for @guardiansTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأولياء'**
  String get guardiansTitle;

  /// No description provided for @relMother.
  ///
  /// In ar, this message translates to:
  /// **'الأم'**
  String get relMother;

  /// No description provided for @relFather.
  ///
  /// In ar, this message translates to:
  /// **'الأب'**
  String get relFather;

  /// No description provided for @relGuardian.
  ///
  /// In ar, this message translates to:
  /// **'ولي الأمر'**
  String get relGuardian;

  /// No description provided for @guardianAccountActive.
  ///
  /// In ar, this message translates to:
  /// **'مفعَّل'**
  String get guardianAccountActive;

  /// No description provided for @guardianAccountPending.
  ///
  /// In ar, this message translates to:
  /// **'لم يدخل بعد'**
  String get guardianAccountPending;

  /// No description provided for @guardianLastSeen.
  ///
  /// In ar, this message translates to:
  /// **'آخر دخول {when}'**
  String guardianLastSeen(String when);

  /// No description provided for @guardianReveal.
  ///
  /// In ar, this message translates to:
  /// **'إظهار'**
  String get guardianReveal;

  /// No description provided for @guardianRevealLogged.
  ///
  /// In ar, this message translates to:
  /// **'كل إظهار يُسجَّل باسمك مع الوقت.'**
  String get guardianRevealLogged;

  /// No description provided for @guardianRevealToast.
  ///
  /// In ar, this message translates to:
  /// **'سُجّل إظهار الرقم باسمك'**
  String get guardianRevealToast;

  /// No description provided for @consentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الموافقات'**
  String get consentsTitle;

  /// No description provided for @consentPrivacyLabel.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get consentPrivacyLabel;

  /// No description provided for @consentVersionAt.
  ///
  /// In ar, this message translates to:
  /// **'v{version} · {when}'**
  String consentVersionAt(int version, String when);

  /// No description provided for @consentImageRightsChangeable.
  ///
  /// In ar, this message translates to:
  /// **'يغيّرها الولي متى شاء'**
  String get consentImageRightsChangeable;

  /// No description provided for @consentApproved.
  ///
  /// In ar, this message translates to:
  /// **'موافَق'**
  String get consentApproved;

  /// No description provided for @consentMissing.
  ///
  /// In ar, this message translates to:
  /// **'لم يوافق بعد'**
  String get consentMissing;

  /// No description provided for @childGroupsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get childGroupsTitle;

  /// No description provided for @groupMainTag.
  ///
  /// In ar, this message translates to:
  /// **'رئيسية'**
  String get groupMainTag;

  /// No description provided for @openChildThread.
  ///
  /// In ar, this message translates to:
  /// **'فتح محادثة {name} (إشراف · يُسجَّل)'**
  String openChildThread(String name);

  /// No description provided for @manageTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأسر والمجموعات'**
  String get manageTitle;

  /// No description provided for @familiesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا أسر} one{أسرة واحدة} two{أسرتان} few{{count} أسر} many{{count} أسرة} other{{count} أسرة}}'**
  String familiesCount(int count);

  /// No description provided for @manageTabUnassigned.
  ///
  /// In ar, this message translates to:
  /// **'بلا مجموعة'**
  String get manageTabUnassigned;

  /// No description provided for @manageTabFamilies.
  ///
  /// In ar, this message translates to:
  /// **'الأسر'**
  String get manageTabFamilies;

  /// No description provided for @manageTabGroups.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get manageTabGroups;

  /// No description provided for @unassignedHint.
  ///
  /// In ar, this message translates to:
  /// **'مسجَّلون بلا مجموعة رئيسية. اختر أطفالًا ثم اضغط «إسناد».'**
  String get unassignedHint;

  /// No description provided for @unassignedEmpty.
  ///
  /// In ar, this message translates to:
  /// **'كل الأطفال في مجموعات.'**
  String get unassignedEmpty;

  /// No description provided for @assignCta.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{إسناد طفل واحد إلى مجموعة…} two{إسناد طفلين إلى مجموعة…} few{إسناد {count} أطفال إلى مجموعة…} many{إسناد {count} طفلًا إلى مجموعة…} other{إسناد {count} طفل إلى مجموعة…}}'**
  String assignCta(int count);

  /// No description provided for @assignSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{إسناد طفل واحد إلى مجموعة} two{إسناد طفلين إلى مجموعة} few{إسناد {count} أطفال إلى مجموعة} many{إسناد {count} طفلًا إلى مجموعة} other{إسناد {count} طفل إلى مجموعة}}'**
  String assignSheetTitle(int count);

  /// No description provided for @assignWarn.
  ///
  /// In ar, this message translates to:
  /// **'{group} ستصير {after} من {capacity} — تظهر بعلامة «فوق السعة».'**
  String assignWarn(int after, int capacity, String group);

  /// No description provided for @assignLogged.
  ///
  /// In ar, this message translates to:
  /// **'يُسجَّل الإسناد باسمك ويُبلَّغ الأولياء.'**
  String get assignLogged;

  /// No description provided for @assignTo.
  ///
  /// In ar, this message translates to:
  /// **'إسناد إلى {group}'**
  String assignTo(String group);

  /// No description provided for @assignPick.
  ///
  /// In ar, this message translates to:
  /// **'اختر مجموعة'**
  String get assignPick;

  /// No description provided for @assignOverKind.
  ///
  /// In ar, this message translates to:
  /// **'فوق السعة'**
  String get assignOverKind;

  /// No description provided for @assignOverTitle.
  ///
  /// In ar, this message translates to:
  /// **'إسناد إلى {group} فوق السعة؟'**
  String assignOverTitle(String group);

  /// No description provided for @assignOverLog.
  ///
  /// In ar, this message translates to:
  /// **'يُسجَّل الإسناد والتجاوز باسمك.'**
  String get assignOverLog;

  /// No description provided for @assignOverCta.
  ///
  /// In ar, this message translates to:
  /// **'نعم، إسناد'**
  String get assignOverCta;

  /// No description provided for @assignedToast.
  ///
  /// In ar, this message translates to:
  /// **'أُسند {count} إلى {group}'**
  String assignedToast(int count, String group);

  /// No description provided for @familyStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'مفعَّلة'**
  String get familyStatusActive;

  /// No description provided for @familyStatusPartial.
  ///
  /// In ar, this message translates to:
  /// **'بعض الأولياء'**
  String get familyStatusPartial;

  /// No description provided for @familyStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'دعوة معلقة'**
  String get familyStatusPending;

  /// No description provided for @familyResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الدعوة'**
  String get familyResend;

  /// No description provided for @familyResentToast.
  ///
  /// In ar, this message translates to:
  /// **'أُعيد إرسال الدعوة'**
  String get familyResentToast;

  /// No description provided for @familyAddChild.
  ///
  /// In ar, this message translates to:
  /// **'+ طفل'**
  String get familyAddChild;

  /// No description provided for @familyNoGroup.
  ///
  /// In ar, this message translates to:
  /// **'بلا مجموعة'**
  String get familyNoGroup;

  /// No description provided for @familiesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا أسر بعد'**
  String get familiesEmpty;

  /// No description provided for @newFamilyCta.
  ///
  /// In ar, this message translates to:
  /// **'+ أسرة جديدة'**
  String get newFamilyCta;

  /// No description provided for @newGroupCta.
  ///
  /// In ar, this message translates to:
  /// **'+ مجموعة جديدة'**
  String get newGroupCta;

  /// No description provided for @groupAssignHere.
  ///
  /// In ar, this message translates to:
  /// **'+ إسناد أطفال'**
  String get groupAssignHere;

  /// No description provided for @newGroupTitle.
  ///
  /// In ar, this message translates to:
  /// **'مجموعة جديدة'**
  String get newGroupTitle;

  /// No description provided for @fieldName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get fieldName;

  /// No description provided for @groupNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: الأشبال 3'**
  String get groupNameHint;

  /// No description provided for @fieldCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get fieldCategory;

  /// No description provided for @fieldCapacity.
  ///
  /// In ar, this message translates to:
  /// **'السعة'**
  String get fieldCapacity;

  /// No description provided for @fieldSchedule.
  ///
  /// In ar, this message translates to:
  /// **'الجدول'**
  String get fieldSchedule;

  /// No description provided for @fieldEducators.
  ///
  /// In ar, this message translates to:
  /// **'المؤطرون'**
  String get fieldEducators;

  /// No description provided for @educatorLoad.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{بلا مجموعات} one{مجموعة واحدة} two{مجموعتان} few{{count} مجموعات} many{{count} مجموعة} other{{count} مجموعة}}'**
  String educatorLoad(int count);

  /// No description provided for @fieldChildrenOptional.
  ///
  /// In ar, this message translates to:
  /// **'أطفال (اختياري) — من «بلا مجموعة»'**
  String get fieldChildrenOptional;

  /// No description provided for @checklistNameOk.
  ///
  /// In ar, this message translates to:
  /// **'✓ الاسم'**
  String get checklistNameOk;

  /// No description provided for @checklistNameMissing.
  ///
  /// In ar, this message translates to:
  /// **'○ الاسم مطلوب'**
  String get checklistNameMissing;

  /// No description provided for @checklistCategoryMissing.
  ///
  /// In ar, this message translates to:
  /// **'○ الفئة مطلوبة'**
  String get checklistCategoryMissing;

  /// No description provided for @checklistEducatorOk.
  ///
  /// In ar, this message translates to:
  /// **'✓ مؤطر'**
  String get checklistEducatorOk;

  /// No description provided for @checklistEducatorMissing.
  ///
  /// In ar, this message translates to:
  /// **'○ مؤطر واحد على الأقل'**
  String get checklistEducatorMissing;

  /// No description provided for @checklistChildren.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{○ بلا أطفال (مقبول)} one{✓ طفل واحد} two{✓ طفلان} few{✓ {count} أطفال} many{✓ {count} طفلًا} other{✓ {count} طفل}}'**
  String checklistChildren(int count);

  /// No description provided for @checklistLogged.
  ///
  /// In ar, this message translates to:
  /// **'⦿ يُسجَّل باسمك'**
  String get checklistLogged;

  /// No description provided for @createGroupCta.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء «{name}»'**
  String createGroupCta(String name);

  /// No description provided for @groupCreatedToast.
  ///
  /// In ar, this message translates to:
  /// **'أُنشئت «{name}»'**
  String groupCreatedToast(String name);

  /// No description provided for @theGroup.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة'**
  String get theGroup;

  /// No description provided for @weekdaySun.
  ///
  /// In ar, this message translates to:
  /// **'الأحد'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In ar, this message translates to:
  /// **'الاثنين'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In ar, this message translates to:
  /// **'الثلاثاء'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In ar, this message translates to:
  /// **'الأربعاء'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In ar, this message translates to:
  /// **'الخميس'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In ar, this message translates to:
  /// **'الجمعة'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In ar, this message translates to:
  /// **'السبت'**
  String get weekdaySat;

  /// No description provided for @newFamilyTitle.
  ///
  /// In ar, this message translates to:
  /// **'أسرة جديدة'**
  String get newFamilyTitle;

  /// No description provided for @reviewStepTitle.
  ///
  /// In ar, this message translates to:
  /// **'المراجعة'**
  String get reviewStepTitle;

  /// No description provided for @stepOfThree.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة {step} من 3'**
  String stepOfThree(int step);

  /// No description provided for @guardianNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم ولي الأمر'**
  String get guardianNameHint;

  /// No description provided for @guardianPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'6XX XXX XXX'**
  String get guardianPhoneHint;

  /// No description provided for @addGuardian.
  ///
  /// In ar, this message translates to:
  /// **'+ ولي آخر'**
  String get addGuardian;

  /// No description provided for @childN.
  ///
  /// In ar, this message translates to:
  /// **'الطفل {n}'**
  String childN(int n);

  /// No description provided for @remove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get remove;

  /// No description provided for @childNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم الطفل'**
  String get childNameHint;

  /// No description provided for @dobLabel.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الولادة'**
  String get dobLabel;

  /// No description provided for @dobPick.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get dobPick;

  /// No description provided for @mainGroupLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة الرئيسية'**
  String get mainGroupLabel;

  /// No description provided for @groupLater.
  ///
  /// In ar, this message translates to:
  /// **'لاحقًا'**
  String get groupLater;

  /// No description provided for @groupFull.
  ///
  /// In ar, this message translates to:
  /// **'ممتلئة'**
  String get groupFull;

  /// No description provided for @healthNotHere.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الصحية يُدخلها الولي من حسابه — لا هنا.'**
  String get healthNotHere;

  /// No description provided for @addChild.
  ///
  /// In ar, this message translates to:
  /// **'+ طفل آخر'**
  String get addChild;

  /// No description provided for @whatHappens.
  ///
  /// In ar, this message translates to:
  /// **'ماذا سيحدث'**
  String get whatHappens;

  /// No description provided for @willInvite.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{• دعوة SMS إلى ولي واحد؛ يوافق على الخصوصية وحقوق الصورة قبل رؤية أي شيء.} two{• دعوة SMS إلى وليَّين؛ يوافقان على الخصوصية وحقوق الصورة قبل رؤية أي شيء.} other{• دعوة SMS إلى {count} أولياء؛ يوافقون على الخصوصية وحقوق الصورة قبل رؤية أي شيء.}}'**
  String willInvite(int count);

  /// No description provided for @willShow.
  ///
  /// In ar, this message translates to:
  /// **'• يظهر الأطفال للولي مع المجموعة والجدول والمؤطر.'**
  String get willShow;

  /// No description provided for @willLog.
  ///
  /// In ar, this message translates to:
  /// **'• ⦿ يُسجَّل الإنشاء باسمك.'**
  String get willLog;

  /// No description provided for @unassignedWarn.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{▲ طفل واحد بلا مجموعة — لن يراه أي مؤطر حتى يُسند.} two{▲ طفلان بلا مجموعة — لن يراهما أي مؤطر حتى يُسندا.} other{▲ {count} أطفال بلا مجموعة — لن يراهم أي مؤطر حتى يُسندوا.}}'**
  String unassignedWarn(int count);

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @createAndInvite.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{إنشاء} one{إنشاء وإرسال دعوة واحدة} two{إنشاء وإرسال دعوتين} few{إنشاء وإرسال {count} دعوات} many{إنشاء وإرسال {count} دعوة} other{إنشاء وإرسال {count} دعوة}}'**
  String createAndInvite(int count);

  /// No description provided for @familyCreatedToast.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{أُنشئت الأسرة} one{أُنشئت الأسرة · دعوة واحدة} two{أُنشئت الأسرة · دعوتان} few{أُنشئت الأسرة · {count} دعوات} many{أُنشئت الأسرة · {count} دعوة} other{أُنشئت الأسرة · {count} دعوة}}'**
  String familyCreatedToast(int count);

  /// No description provided for @reportsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reportsTitle;

  /// No description provided for @repTabAttendance.
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get repTabAttendance;

  /// No description provided for @repTabEducators.
  ///
  /// In ar, this message translates to:
  /// **'المؤطرون'**
  String get repTabEducators;

  /// No description provided for @repTabEngagement.
  ///
  /// In ar, this message translates to:
  /// **'التفاعل'**
  String get repTabEngagement;

  /// No description provided for @repTabExport.
  ///
  /// In ar, this message translates to:
  /// **'التصدير'**
  String get repTabExport;

  /// No description provided for @repByEducator.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الحضور حسب المؤطر'**
  String get repByEducator;

  /// No description provided for @repByCategory.
  ///
  /// In ar, this message translates to:
  /// **'حسب الفئة'**
  String get repByCategory;

  /// No description provided for @repRawNote.
  ///
  /// In ar, this message translates to:
  /// **'النسبة مع العدد الخام'**
  String get repRawNote;

  /// No description provided for @repPlanned.
  ///
  /// In ar, this message translates to:
  /// **'مخطَّطة/مُنجزة {delivered}/{planned}'**
  String repPlanned(int delivered, int planned);

  /// No description provided for @repOnTime.
  ///
  /// In ar, this message translates to:
  /// **'في وقته {ontime} من {planned}'**
  String repOnTime(int ontime, int planned);

  /// No description provided for @repReplyUnknown.
  ///
  /// In ar, this message translates to:
  /// **'الرد —'**
  String get repReplyUnknown;

  /// No description provided for @repActivated.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل حسابات الأولياء'**
  String get repActivated;

  /// No description provided for @repPresenceAnswers.
  ///
  /// In ar, this message translates to:
  /// **'الرد على تأكيد الحضور'**
  String get repPresenceAnswers;

  /// No description provided for @repHomework.
  ///
  /// In ar, this message translates to:
  /// **'إنجاز الواجبات'**
  String get repHomework;

  /// No description provided for @selfReported.
  ///
  /// In ar, this message translates to:
  /// **'تصريح ذاتي'**
  String get selfReported;

  /// No description provided for @repNotYet.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح بعد'**
  String get repNotYet;

  /// No description provided for @repNoData.
  ///
  /// In ar, this message translates to:
  /// **'لا بيانات بعد'**
  String get repNoData;

  /// No description provided for @exportIntro.
  ///
  /// In ar, this message translates to:
  /// **'تصدير قائمة الأطفال. الحقول الصحية معطَّلة افتراضيًا.'**
  String get exportIntro;

  /// No description provided for @exportName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get exportName;

  /// No description provided for @exportDob.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الولادة'**
  String get exportDob;

  /// No description provided for @exportGroup.
  ///
  /// In ar, this message translates to:
  /// **'الفئة والمجموعة'**
  String get exportGroup;

  /// No description provided for @exportGuardian.
  ///
  /// In ar, this message translates to:
  /// **'اسم ولي الأمر'**
  String get exportGuardian;

  /// No description provided for @exportPhone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف ولي الأمر'**
  String get exportPhone;

  /// No description provided for @exportConsent.
  ///
  /// In ar, this message translates to:
  /// **'حقوق الصورة'**
  String get exportConsent;

  /// No description provided for @exportAllergies.
  ///
  /// In ar, this message translates to:
  /// **'الحساسية'**
  String get exportAllergies;

  /// No description provided for @exportMedications.
  ///
  /// In ar, this message translates to:
  /// **'الأدوية'**
  String get exportMedications;

  /// No description provided for @healthTag.
  ///
  /// In ar, this message translates to:
  /// **'صحي'**
  String get healthTag;

  /// No description provided for @exportLogged.
  ///
  /// In ar, this message translates to:
  /// **'يُسجَّل التصدير باسمك والحقول المختارة.'**
  String get exportLogged;

  /// No description provided for @exportContainsHealth.
  ///
  /// In ar, this message translates to:
  /// **'يحتوي بيانات صحية — للجهة المعنية فقط.'**
  String get exportContainsHealth;

  /// No description provided for @exportCta.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{إنشاء الملف · حقل واحد} two{إنشاء الملف · حقلان} few{إنشاء الملف · {count} حقول} many{إنشاء الملف · {count} حقلًا} other{إنشاء الملف · {count} حقل}}'**
  String exportCta(int count);

  /// No description provided for @exportBusy.
  ///
  /// In ar, this message translates to:
  /// **'يُجهَّز الملف…'**
  String get exportBusy;

  /// No description provided for @exportReady.
  ///
  /// In ar, this message translates to:
  /// **'الملف جاهز'**
  String get exportReady;

  /// No description provided for @exportRows.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا صفوف} one{صف واحد} two{صفان} few{{count} صفوف} many{{count} صفًا} other{{count} صف}}'**
  String exportRows(int count);

  /// No description provided for @exportShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الملف'**
  String get exportShare;

  /// No description provided for @exportLoggedToast.
  ///
  /// In ar, this message translates to:
  /// **'سُجّل التصدير باسمك'**
  String get exportLoggedToast;

  /// No description provided for @structureTitle.
  ///
  /// In ar, this message translates to:
  /// **'الهيكل'**
  String get structureTitle;

  /// No description provided for @strTabSeasons.
  ///
  /// In ar, this message translates to:
  /// **'المواسم'**
  String get strTabSeasons;

  /// No description provided for @strTabCategories.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get strTabCategories;

  /// No description provided for @strTabBranches.
  ///
  /// In ar, this message translates to:
  /// **'الفروع'**
  String get strTabBranches;

  /// No description provided for @seasonActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get seasonActive;

  /// No description provided for @seasonArchived.
  ///
  /// In ar, this message translates to:
  /// **'مؤرشف'**
  String get seasonArchived;

  /// No description provided for @seasonArchive.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة'**
  String get seasonArchive;

  /// No description provided for @seasonsNote.
  ///
  /// In ar, this message translates to:
  /// **'المواسم تُؤرشف ولا تُحذف.'**
  String get seasonsNote;

  /// No description provided for @archiveKind.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة — قابلة للتراجع'**
  String get archiveKind;

  /// No description provided for @archiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة موسم {label}؟'**
  String archiveTitle(String label);

  /// No description provided for @archiveBody.
  ///
  /// In ar, this message translates to:
  /// **'تُغلق المجموعات والتسجيلات للقراءة فقط. لا يُحذف شيء.'**
  String get archiveBody;

  /// No description provided for @archiveLog.
  ///
  /// In ar, this message translates to:
  /// **'تُسجَّل الأرشفة باسمك.'**
  String get archiveLog;

  /// No description provided for @archiveCta.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة الموسم'**
  String get archiveCta;

  /// No description provided for @archivedToast.
  ///
  /// In ar, this message translates to:
  /// **'أُرشف الموسم'**
  String get archivedToast;

  /// No description provided for @catsOpenDecision.
  ///
  /// In ar, this message translates to:
  /// **'الفئات العمرية والجنس قرار مجلس الإدارة ولم يُتَّخذ بعد. الحقول فارغة عن قصد.'**
  String get catsOpenDecision;

  /// No description provided for @catAgeGenderUnset.
  ///
  /// In ar, this message translates to:
  /// **'العمر/الجنس: لم يُحدَّد'**
  String get catAgeGenderUnset;

  /// No description provided for @catAgeRange.
  ///
  /// In ar, this message translates to:
  /// **'{min}–{max} سنة'**
  String catAgeRange(int min, int max);

  /// No description provided for @genderBoys.
  ///
  /// In ar, this message translates to:
  /// **'ذكور'**
  String get genderBoys;

  /// No description provided for @genderGirls.
  ///
  /// In ar, this message translates to:
  /// **'إناث'**
  String get genderGirls;

  /// No description provided for @genderMixed.
  ///
  /// In ar, this message translates to:
  /// **'مختلط'**
  String get genderMixed;

  /// No description provided for @branchesNote.
  ///
  /// In ar, this message translates to:
  /// **'فرع واحد اليوم. عند إضافة ثانٍ يظهر محدِّد الفرع للإداريين.'**
  String get branchesNote;

  /// No description provided for @newBranch.
  ///
  /// In ar, this message translates to:
  /// **'+ فرع جديد'**
  String get newBranch;

  /// No description provided for @branchNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفرع'**
  String get branchNameHint;

  /// No description provided for @branchAddressHint.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get branchAddressHint;

  /// No description provided for @branchCreatedToast.
  ///
  /// In ar, this message translates to:
  /// **'أُنشئ الفرع'**
  String get branchCreatedToast;

  /// No description provided for @adminOnlyTitle.
  ///
  /// In ar, this message translates to:
  /// **'هذا القسم لمدير النظام فقط'**
  String get adminOnlyTitle;

  /// No description provided for @adminOnlyBody.
  ///
  /// In ar, this message translates to:
  /// **'صلاحيتك: {role}. اطلبها من رئيس الجمعية.'**
  String adminOnlyBody(String role);

  /// No description provided for @adminOnlyLogged.
  ///
  /// In ar, this message translates to:
  /// **'⦿ محاولة الوصول مسجَّلة — هذا طبيعي.'**
  String get adminOnlyLogged;

  /// No description provided for @logsTitle.
  ///
  /// In ar, this message translates to:
  /// **'السجلات'**
  String get logsTitle;

  /// No description provided for @logTabAudit.
  ///
  /// In ar, this message translates to:
  /// **'التدقيق'**
  String get logTabAudit;

  /// No description provided for @logTabHealth.
  ///
  /// In ar, this message translates to:
  /// **'الوصول الصحي'**
  String get logTabHealth;

  /// No description provided for @logsAppendOnly.
  ///
  /// In ar, this message translates to:
  /// **'⦿ إضافيّ فقط — لا تعديل ولا حذف. مدة الاحتفاظ:'**
  String get logsAppendOnly;

  /// No description provided for @retentionUnset.
  ///
  /// In ar, this message translates to:
  /// **'لم تُحدَّد بعد'**
  String get retentionUnset;

  /// No description provided for @healthLogIntro.
  ///
  /// In ar, this message translates to:
  /// **'من عرض المعلومات الصحية لأي طفل ومتى — الوعد الذي يُقطَع عند كل «عرض».'**
  String get healthLogIntro;

  /// No description provided for @logsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا سجلات بعد'**
  String get logsEmpty;

  /// No description provided for @actionLogin.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get actionLogin;

  /// No description provided for @actionCorrect.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح حضور'**
  String get actionCorrect;

  /// No description provided for @actionExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get actionExport;

  /// No description provided for @actionHideMessage.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء رسالة'**
  String get actionHideMessage;

  /// No description provided for @actionHealthView.
  ///
  /// In ar, this message translates to:
  /// **'عرض بيانات صحية'**
  String get actionHealthView;

  /// No description provided for @actionPhoneReveal.
  ///
  /// In ar, this message translates to:
  /// **'إظهار هاتف'**
  String get actionPhoneReveal;

  /// No description provided for @actionAssign.
  ///
  /// In ar, this message translates to:
  /// **'إسناد'**
  String get actionAssign;

  /// No description provided for @actionCreate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get actionCreate;

  /// No description provided for @actionPublish.
  ///
  /// In ar, this message translates to:
  /// **'نشر إعلان'**
  String get actionPublish;

  /// No description provided for @actionApprovePost.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد منشور'**
  String get actionApprovePost;

  /// No description provided for @actionHidePost.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء منشور'**
  String get actionHidePost;

  /// No description provided for @actionOversightRead.
  ///
  /// In ar, this message translates to:
  /// **'قراءة إشرافية'**
  String get actionOversightRead;

  /// No description provided for @actionDenied.
  ///
  /// In ar, this message translates to:
  /// **'محاولة وصول مرفوضة'**
  String get actionDenied;

  /// No description provided for @actionArchive.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة'**
  String get actionArchive;

  /// No description provided for @actionDismissReport.
  ///
  /// In ar, this message translates to:
  /// **'رفض بلاغ'**
  String get actionDismissReport;

  /// No description provided for @actionInvite.
  ///
  /// In ar, this message translates to:
  /// **'إعادة دعوة'**
  String get actionInvite;

  /// No description provided for @actionOther.
  ///
  /// In ar, this message translates to:
  /// **'إجراء'**
  String get actionOther;

  /// No description provided for @eduTabToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get eduTabToday;

  /// No description provided for @eduTabSessions.
  ///
  /// In ar, this message translates to:
  /// **'الجلسات'**
  String get eduTabSessions;

  /// No description provided for @eduTabGroups.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get eduTabGroups;

  /// No description provided for @eduTabMessages.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل'**
  String get eduTabMessages;

  /// No description provided for @eduTabMemories.
  ///
  /// In ar, this message translates to:
  /// **'الذكريات'**
  String get eduTabMemories;

  /// No description provided for @eduGreetingMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get eduGreetingMorning;

  /// No description provided for @eduGreetingEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get eduGreetingEvening;

  /// No description provided for @todayNextSession.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة التالية'**
  String get todayNextSession;

  /// No description provided for @todayInMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{الآن} one{بعد دقيقة} two{بعد دقيقتين} few{بعد {count} دقائق} many{بعد {count} دقيقة} other{بعد {count} دقيقة}}'**
  String todayInMinutes(int count);

  /// No description provided for @todayLive.
  ///
  /// In ar, this message translates to:
  /// **'جارية الآن'**
  String get todayLive;

  /// No description provided for @presTallyYes.
  ///
  /// In ar, this message translates to:
  /// **'سيحضر'**
  String get presTallyYes;

  /// No description provided for @presTallyLate.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get presTallyLate;

  /// No description provided for @presTallyNo.
  ///
  /// In ar, this message translates to:
  /// **'لن يحضر'**
  String get presTallyNo;

  /// No description provided for @presTallyNone.
  ///
  /// In ar, this message translates to:
  /// **'بلا رد'**
  String get presTallyNone;

  /// No description provided for @todayRecordAttendance.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الحضور'**
  String get todayRecordAttendance;

  /// No description provided for @todayAttendanceDone.
  ///
  /// In ar, this message translates to:
  /// **'سُجّل حضور {group}'**
  String todayAttendanceDone(String group);

  /// No description provided for @todayAttendanceSummary.
  ///
  /// In ar, this message translates to:
  /// **'حاضر {present} · متأخر {late} · معذور {excused} · غائب {absent}'**
  String todayAttendanceSummary(int present, int late, int excused, int absent);

  /// No description provided for @todaySessionSummaryCta.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الجلسة'**
  String get todaySessionSummaryCta;

  /// No description provided for @todayNoContent.
  ///
  /// In ar, this message translates to:
  /// **'لم تُضف محتوى جلسة {group} · {time} بعد — أنشئت تلقائيًا من الجدول.'**
  String todayNoContent(String group, String time);

  /// No description provided for @todayAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get todayAdd;

  /// No description provided for @shortcutHomework.
  ///
  /// In ar, this message translates to:
  /// **'واجب'**
  String get shortcutHomework;

  /// No description provided for @shortcutMemory.
  ///
  /// In ar, this message translates to:
  /// **'ذكرى'**
  String get shortcutMemory;

  /// No description provided for @shortcutAnnouncement.
  ///
  /// In ar, this message translates to:
  /// **'إعلان'**
  String get shortcutAnnouncement;

  /// No description provided for @todayFromManagement.
  ///
  /// In ar, this message translates to:
  /// **'من الإدارة'**
  String get todayFromManagement;

  /// No description provided for @todayAckCta.
  ///
  /// In ar, this message translates to:
  /// **'قرأتُ'**
  String get todayAckCta;

  /// No description provided for @todayAckDone.
  ///
  /// In ar, this message translates to:
  /// **'✓ أكّدت القراءة'**
  String get todayAckDone;

  /// No description provided for @todayNoSession.
  ///
  /// In ar, this message translates to:
  /// **'لا جلسة اليوم'**
  String get todayNoSession;

  /// No description provided for @todayNextOn.
  ///
  /// In ar, this message translates to:
  /// **'التالية: {date}'**
  String todayNextOn(String date);

  /// No description provided for @todayNoSessionsAtAll.
  ///
  /// In ar, this message translates to:
  /// **'لا جلسات قادمة — تأكد من جدول مجموعاتك مع الإداري.'**
  String get todayNoSessionsAtAll;

  /// No description provided for @presTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحضور'**
  String get presTitle;

  /// No description provided for @presSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'{group} · {time} · أُرسل {sent} تلقائيًا'**
  String presSubtitle(String group, String time, String sent);

  /// No description provided for @presSubtitleNotSent.
  ///
  /// In ar, this message translates to:
  /// **'{group} · {time} · لم يُرسل بعد'**
  String presSubtitleNotSent(String group, String time);

  /// No description provided for @presPlanning.
  ///
  /// In ar, this message translates to:
  /// **'للتخطيط (الأدوات، الوجبة، النقل)'**
  String get presPlanning;

  /// No description provided for @presExpectedOf.
  ///
  /// In ar, this message translates to:
  /// **'متوقَّع من {count}'**
  String presExpectedOf(int count);

  /// No description provided for @presRemind.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا أحد بلا رد} one{تذكير من لم يردّ (1)} two{تذكير من لم يردّ (2)} few{تذكير من لم يردّ ({count})} many{تذكير من لم يردّ ({count})} other{تذكير من لم يردّ ({count})}}'**
  String presRemind(int count);

  /// No description provided for @presRemindDone.
  ///
  /// In ar, this message translates to:
  /// **'✓ أُرسل التذكير'**
  String get presRemindDone;

  /// No description provided for @presRemindNote.
  ///
  /// In ar, this message translates to:
  /// **'التذكير يُرسل مرة واحدة فقط — الموعد النهائي {time}'**
  String presRemindNote(String time);

  /// No description provided for @presRemindedToast.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا أحد لتذكيره} one{أُرسل تذكير إلى وليّ واحد} two{أُرسل تذكير إلى وليَّين} few{أُرسل تذكير إلى {count} أولياء} many{أُرسل تذكير إلى {count} وليًّا} other{أُرسل تذكير إلى {count} وليّ}}'**
  String presRemindedToast(int count);

  /// No description provided for @presNotSent.
  ///
  /// In ar, this message translates to:
  /// **'لم يُرسل طلب تأكيد لهذه الجلسة.'**
  String get presNotSent;

  /// No description provided for @attTitle.
  ///
  /// In ar, this message translates to:
  /// **'حضور {group}'**
  String attTitle(String group);

  /// No description provided for @attSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'{time} · {title} · معبّأ من تأكيدات الأولياء'**
  String attSubtitle(String time, String title);

  /// No description provided for @attUnmarked.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{الكل مسجَّل} one{1 بلا تسجيل} two{2 بلا تسجيل} few{{count} بلا تسجيل} many{{count} بلا تسجيل} other{{count} بلا تسجيل}}'**
  String attUnmarked(int count);

  /// No description provided for @attMarkRest.
  ///
  /// In ar, this message translates to:
  /// **'✓ تسجيل الباقين ({count}) حاضرين'**
  String attMarkRest(int count);

  /// No description provided for @attPresYes.
  ///
  /// In ar, this message translates to:
  /// **'أكّد الولي الحضور'**
  String get attPresYes;

  /// No description provided for @attPresLate.
  ///
  /// In ar, this message translates to:
  /// **'أعلن التأخر'**
  String get attPresLate;

  /// No description provided for @attPresNo.
  ///
  /// In ar, this message translates to:
  /// **'أعلن الغياب'**
  String get attPresNo;

  /// No description provided for @attPresNone.
  ///
  /// In ar, this message translates to:
  /// **'لم يردّ الولي'**
  String get attPresNone;

  /// No description provided for @attSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الحضور'**
  String get attSave;

  /// No description provided for @attSaveAlert.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{حفظ · تنبيه وليّ واحد} two{حفظ · تنبيه وليَّين} few{حفظ · تنبيه {count} أولياء} many{حفظ · تنبيه {count} وليًّا} other{حفظ · تنبيه {count} وليّ}}'**
  String attSaveAlert(int count);

  /// No description provided for @attSaveOffline.
  ///
  /// In ar, this message translates to:
  /// **'حفظ على الهاتف'**
  String get attSaveOffline;

  /// No description provided for @attEditHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكن التعديل خلال 30 دقيقة، بعدها عبر الإداري'**
  String get attEditHint;

  /// No description provided for @attUnmarkedKind.
  ///
  /// In ar, this message translates to:
  /// **'قبل الحفظ'**
  String get attUnmarkedKind;

  /// No description provided for @attUnmarkedTitle.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{طفل واحد بلا تسجيل} two{طفلان بلا تسجيل} few{{count} أطفال بلا تسجيل} many{{count} طفلًا بلا تسجيل} other{{count} طفل بلا تسجيل}}'**
  String attUnmarkedTitle(int count);

  /// No description provided for @attUnmarkedBody.
  ///
  /// In ar, this message translates to:
  /// **'سجّل حالة كل طفل. إن كانوا غير موجودين فعلًا، اختر «غائب» — سيُبلَّغ أولياؤهم فورًا.'**
  String get attUnmarkedBody;

  /// No description provided for @attUnmarkedCta.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التسجيل'**
  String get attUnmarkedCta;

  /// No description provided for @attAlertKind.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه أمان للأولياء'**
  String get attAlertKind;

  /// No description provided for @attAlertTitle.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{سيُبلَّغ وليّ طفل واحد فورًا} two{سيُبلَّغ أولياء طفلين فورًا} few{سيُبلَّغ أولياء {count} أطفال فورًا} many{سيُبلَّغ أولياء {count} طفلًا فورًا} other{سيُبلَّغ أولياء {count} طفل فورًا}}'**
  String attAlertTitle(int count);

  /// No description provided for @attAlertBody.
  ///
  /// In ar, this message translates to:
  /// **'{names} غائب دون إشعار مسبق. يصل لأوليائهم إشعار فوري (وSMS إن لم يفتحوا التطبيق)، لأن الولي قد يظنّ أن طفله هنا.'**
  String attAlertBody(String names);

  /// No description provided for @attAlertCta.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وإرسال التنبيه'**
  String get attAlertCta;

  /// No description provided for @attAlertCancel.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة القائمة'**
  String get attAlertCancel;

  /// No description provided for @attSavedAlert.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{سُجّل الحضور · أُبلغ وليّ واحد} two{سُجّل الحضور · أُبلغ وليَّان} few{سُجّل الحضور · أُبلغ {count} أولياء} many{سُجّل الحضور · أُبلغ {count} وليًّا} other{سُجّل الحضور · أُبلغ {count} وليّ}}'**
  String attSavedAlert(int count);

  /// No description provided for @attStatusExcusedShort.
  ///
  /// In ar, this message translates to:
  /// **'معذور'**
  String get attStatusExcusedShort;

  /// No description provided for @sessTitle.
  ///
  /// In ar, this message translates to:
  /// **'الجلسات'**
  String get sessTitle;

  /// No description provided for @sessWeekRange.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع {from} – {to}'**
  String sessWeekRange(String from, String to);

  /// No description provided for @sessPrevWeek.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع السابق'**
  String get sessPrevWeek;

  /// No description provided for @sessNextWeek.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع التالي'**
  String get sessNextWeek;

  /// No description provided for @sessAllGroups.
  ///
  /// In ar, this message translates to:
  /// **'كل مجموعاتي'**
  String get sessAllGroups;

  /// No description provided for @sessStateUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'قادمة'**
  String get sessStateUpcoming;

  /// No description provided for @sessStateSoon.
  ///
  /// In ar, this message translates to:
  /// **'بعد {count} د'**
  String sessStateSoon(int count);

  /// No description provided for @sessStateLive.
  ///
  /// In ar, this message translates to:
  /// **'جارية'**
  String get sessStateLive;

  /// No description provided for @sessStateNoContent.
  ///
  /// In ar, this message translates to:
  /// **'بلا محتوى'**
  String get sessStateNoContent;

  /// No description provided for @sessStateMoved.
  ///
  /// In ar, this message translates to:
  /// **'مؤجَّلة'**
  String get sessStateMoved;

  /// No description provided for @sessMetaMaterials.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{بلا مواد} one{مادة واحدة} two{مادتان} few{{count} مواد} many{{count} مادة} other{{count} مادة}}'**
  String sessMetaMaterials(int count);

  /// No description provided for @sessMetaHomework.
  ///
  /// In ar, this message translates to:
  /// **'واجب'**
  String get sessMetaHomework;

  /// No description provided for @sessMetaGenerated.
  ///
  /// In ar, this message translates to:
  /// **'أُنشئت من الجدول'**
  String get sessMetaGenerated;

  /// No description provided for @sessMetaWith.
  ///
  /// In ar, this message translates to:
  /// **'مع {name}'**
  String sessMetaWith(String name);

  /// No description provided for @sessFooter.
  ///
  /// In ar, this message translates to:
  /// **'الجلسات تُنشأ تلقائيًا من جدول المجموعة — أضف المحتوى فقط.'**
  String get sessFooter;

  /// No description provided for @sessEmptyWeek.
  ///
  /// In ar, this message translates to:
  /// **'لا جلسات هذا الأسبوع'**
  String get sessEmptyWeek;

  /// No description provided for @sessObjectives.
  ///
  /// In ar, this message translates to:
  /// **'الأهداف'**
  String get sessObjectives;

  /// No description provided for @sessMaterials.
  ///
  /// In ar, this message translates to:
  /// **'المواد'**
  String get sessMaterials;

  /// No description provided for @sessHomework.
  ///
  /// In ar, this message translates to:
  /// **'الواجب'**
  String get sessHomework;

  /// No description provided for @sessAddHomework.
  ///
  /// In ar, this message translates to:
  /// **'+ واجب'**
  String get sessAddHomework;

  /// No description provided for @sessHomeworkMeta.
  ///
  /// In ar, this message translates to:
  /// **'{target} · آخر أجل {due} · {done}/{total} أنجز (تصريح الأولياء)'**
  String sessHomeworkMeta(String target, String due, int done, int total);

  /// No description provided for @sessWholeGroup.
  ///
  /// In ar, this message translates to:
  /// **'كل المجموعة'**
  String get sessWholeGroup;

  /// No description provided for @sessAttendanceDone.
  ///
  /// In ar, this message translates to:
  /// **'✓ الحضور'**
  String get sessAttendanceDone;

  /// No description provided for @sessSummaryDone.
  ///
  /// In ar, this message translates to:
  /// **'✓ الملخّص'**
  String get sessSummaryDone;

  /// No description provided for @sessSummaryCta.
  ///
  /// In ar, this message translates to:
  /// **'ملخّص الجلسة'**
  String get sessSummaryCta;

  /// No description provided for @sessCancelCta.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء أو تأجيل الجلسة'**
  String get sessCancelCta;

  /// No description provided for @sessCancelledBanner.
  ///
  /// In ar, this message translates to:
  /// **'✕ ألغيت هذه الجلسة · أُبلغ الأولياء والفريق'**
  String get sessCancelledBanner;

  /// No description provided for @sessMovedBanner.
  ///
  /// In ar, this message translates to:
  /// **'⏱ أُجّلت إلى {when} · أُبلغ الأولياء'**
  String sessMovedBanner(String when);

  /// No description provided for @sessNoObjectives.
  ///
  /// In ar, this message translates to:
  /// **'لا أهداف بعد — أضفها من «تعديل».'**
  String get sessNoObjectives;

  /// No description provided for @sessNoMaterials.
  ///
  /// In ar, this message translates to:
  /// **'لا مواد بعد'**
  String get sessNoMaterials;

  /// No description provided for @sessNoHomework.
  ///
  /// In ar, this message translates to:
  /// **'لا واجب مرتبط بهذه الجلسة'**
  String get sessNoHomework;

  /// No description provided for @sessEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get sessEdit;

  /// No description provided for @visBefore.
  ///
  /// In ar, this message translates to:
  /// **'قبل الجلسة'**
  String get visBefore;

  /// No description provided for @visAfter.
  ///
  /// In ar, this message translates to:
  /// **'بعد الجلسة'**
  String get visAfter;

  /// No description provided for @visStaff.
  ///
  /// In ar, this message translates to:
  /// **'للمؤطرين فقط'**
  String get visStaff;

  /// No description provided for @matKindDocument.
  ///
  /// In ar, this message translates to:
  /// **'ملف'**
  String get matKindDocument;

  /// No description provided for @matKindImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة'**
  String get matKindImage;

  /// No description provided for @matKindAudio.
  ///
  /// In ar, this message translates to:
  /// **'صوت'**
  String get matKindAudio;

  /// No description provided for @matKindVideo.
  ///
  /// In ar, this message translates to:
  /// **'فيديو'**
  String get matKindVideo;

  /// No description provided for @matKindLink.
  ///
  /// In ar, this message translates to:
  /// **'رابط'**
  String get matKindLink;

  /// No description provided for @sessContentTitle.
  ///
  /// In ar, this message translates to:
  /// **'محتوى الجلسة'**
  String get sessContentTitle;

  /// No description provided for @sessContentSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'{group} · {time} · من الجدول الأسبوعي'**
  String sessContentSubtitle(String group, String time);

  /// No description provided for @sessTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: حلقة القرآن — سورة الملك'**
  String get sessTitleHint;

  /// No description provided for @sessTheme.
  ///
  /// In ar, this message translates to:
  /// **'المحور'**
  String get sessTheme;

  /// No description provided for @themeQuran.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get themeQuran;

  /// No description provided for @themeSira.
  ///
  /// In ar, this message translates to:
  /// **'السيرة'**
  String get themeSira;

  /// No description provided for @themeAkhlaq.
  ///
  /// In ar, this message translates to:
  /// **'الأخلاق'**
  String get themeAkhlaq;

  /// No description provided for @themeHadith.
  ///
  /// In ar, this message translates to:
  /// **'الحديث'**
  String get themeHadith;

  /// No description provided for @themeSkills.
  ///
  /// In ar, this message translates to:
  /// **'المهارات'**
  String get themeSkills;

  /// No description provided for @sessObjectivesHint.
  ///
  /// In ar, this message translates to:
  /// **'هدف في كل سطر…'**
  String get sessObjectivesHint;

  /// No description provided for @sessMaterialsWho.
  ///
  /// In ar, this message translates to:
  /// **'المواد ومن يراها'**
  String get sessMaterialsWho;

  /// No description provided for @sessVideoLimit.
  ///
  /// In ar, this message translates to:
  /// **'فيديو ≤ 50 م.ب · الطويل كرابط'**
  String get sessVideoLimit;

  /// No description provided for @addFile.
  ///
  /// In ar, this message translates to:
  /// **'+ ملف'**
  String get addFile;

  /// No description provided for @addPhoto.
  ///
  /// In ar, this message translates to:
  /// **'+ صورة'**
  String get addPhoto;

  /// No description provided for @addAudio.
  ///
  /// In ar, this message translates to:
  /// **'+ صوت'**
  String get addAudio;

  /// No description provided for @addLink.
  ///
  /// In ar, this message translates to:
  /// **'+ رابط'**
  String get addLink;

  /// No description provided for @sessSaveContent.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المحتوى'**
  String get sessSaveContent;

  /// No description provided for @sessContentSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ محتوى الجلسة'**
  String get sessContentSaved;

  /// No description provided for @linkUrlHint.
  ///
  /// In ar, this message translates to:
  /// **'https://…'**
  String get linkUrlHint;

  /// No description provided for @linkTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الرابط'**
  String get linkTitleHint;

  /// No description provided for @linkAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة الرابط'**
  String get linkAdd;

  /// No description provided for @uploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر رفع الملف'**
  String get uploadFailed;

  /// No description provided for @sumTitle.
  ///
  /// In ar, this message translates to:
  /// **'ماذا فعلنا اليوم؟'**
  String get sumTitle;

  /// No description provided for @sumSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخّص يصل لأولياء {group}'**
  String sumSubtitle(String group);

  /// No description provided for @sumHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ما حفظه الأطفال وتعلّموه، وما ترجو من الأولياء مراجعته…'**
  String get sumHint;

  /// No description provided for @sumConsentNote.
  ///
  /// In ar, this message translates to:
  /// **'الصور التي تظهر فيها وجوه تمرّ عبر وسم حقوق الصورة مثل الذكريات.'**
  String get sumConsentNote;

  /// No description provided for @sumConsentBlocked.
  ///
  /// In ar, this message translates to:
  /// **'{name} «غير مسموح» — لا تُرفق صورة يظهر فيها.'**
  String sumConsentBlocked(String name);

  /// No description provided for @sumReach.
  ///
  /// In ar, this message translates to:
  /// **'يصل إلى {families} أسرة ({guardians} وليًّا) · يظهر في صفحة الجلسة لدى الأولياء'**
  String sumReach(int families, int guardians);

  /// No description provided for @sumSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال لأولياء المجموعة'**
  String get sumSend;

  /// No description provided for @sumSent.
  ///
  /// In ar, this message translates to:
  /// **'✓ أُرسل للأولياء'**
  String get sumSent;

  /// No description provided for @sumSentToast.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{أُرسل الملخّص إلى أسرة واحدة} two{أُرسل الملخّص إلى أسرتين} few{أُرسل الملخّص إلى {count} أسر} many{أُرسل الملخّص إلى {count} أسرة} other{أُرسل الملخّص إلى {count} أسرة}}'**
  String sumSentToast(int count);

  /// No description provided for @cancelSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء أو تأجيل الجلسة'**
  String get cancelSheetTitle;

  /// No description provided for @cancelModeCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelModeCancel;

  /// No description provided for @cancelModeMove.
  ///
  /// In ar, this message translates to:
  /// **'تأجيل'**
  String get cancelModeMove;

  /// No description provided for @cancelNewSlot.
  ///
  /// In ar, this message translates to:
  /// **'الموعد الجديد'**
  String get cancelNewSlot;

  /// No description provided for @cancelPickSlot.
  ///
  /// In ar, this message translates to:
  /// **'اختر الموعد الجديد'**
  String get cancelPickSlot;

  /// No description provided for @cancelReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'السبب (يراه الأولياء)…'**
  String get cancelReasonHint;

  /// No description provided for @cancelNotice.
  ///
  /// In ar, this message translates to:
  /// **'يُبلَّغ تلقائيًا {guardians} وليًّا، والمؤطرون المشاركون، والإداريون. ⦿ يُسجَّل باسمك.'**
  String cancelNotice(int guardians);

  /// No description provided for @cancelCta.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء وإبلاغ الجميع'**
  String get cancelCta;

  /// No description provided for @moveCta.
  ///
  /// In ar, this message translates to:
  /// **'تأجيل وإبلاغ الجميع'**
  String get moveCta;

  /// No description provided for @cancelledToast.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{أُلغيت الجلسة · أُبلغ شخص واحد} two{أُلغيت الجلسة · أُبلغ شخصان} few{أُلغيت الجلسة · أُبلغ {count} أشخاص} many{أُلغيت الجلسة · أُبلغ {count} شخصًا} other{أُلغيت الجلسة · أُبلغ {count} شخص}}'**
  String cancelledToast(int count);

  /// No description provided for @movedToast.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{أُجّلت الجلسة · أُبلغ شخص واحد} two{أُجّلت الجلسة · أُبلغ شخصان} few{أُجّلت الجلسة · أُبلغ {count} أشخاص} many{أُجّلت الجلسة · أُبلغ {count} شخصًا} other{أُجّلت الجلسة · أُبلغ {count} شخص}}'**
  String movedToast(int count);

  /// No description provided for @hwNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'واجب جديد'**
  String get hwNewTitle;

  /// No description provided for @hwNewSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مرتبط بجلسة {day} · {group}'**
  String hwNewSubtitle(String day, String group);

  /// No description provided for @hwInstructions.
  ///
  /// In ar, this message translates to:
  /// **'التعليمات'**
  String get hwInstructions;

  /// No description provided for @hwInstructionsHint.
  ///
  /// In ar, this message translates to:
  /// **'ما المطلوب من الطفل؟'**
  String get hwInstructionsHint;

  /// No description provided for @hwTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: مراجعة الآيات 1–10'**
  String get hwTitleHint;

  /// No description provided for @hwFor.
  ///
  /// In ar, this message translates to:
  /// **'لمن؟'**
  String get hwFor;

  /// No description provided for @hwWholeGroup.
  ///
  /// In ar, this message translates to:
  /// **'كل المجموعة ({count})'**
  String hwWholeGroup(int count);

  /// No description provided for @hwSpecific.
  ///
  /// In ar, this message translates to:
  /// **'أطفال محددون'**
  String get hwSpecific;

  /// No description provided for @hwDue.
  ///
  /// In ar, this message translates to:
  /// **'آخر أجل'**
  String get hwDue;

  /// No description provided for @hwReminderNote.
  ///
  /// In ar, this message translates to:
  /// **'تذكير تلقائي للأولياء قبل الأجل بيوم إن لم يُعلَّم «أُنجز».'**
  String get hwReminderNote;

  /// No description provided for @hwAttachment.
  ///
  /// In ar, this message translates to:
  /// **'+ مرفق (ورقة الحفظ، تسجيل صوتي…)'**
  String get hwAttachment;

  /// No description provided for @hwAttachmentAdded.
  ///
  /// In ar, this message translates to:
  /// **'✓ مرفق: {name}'**
  String hwAttachmentAdded(String name);

  /// No description provided for @hwSend.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{اختر الأطفال} one{إرسال لطفل واحد} two{إرسال لطفلين} few{إرسال لـ {count} أطفال} many{إرسال لـ {count} طفلًا} other{إرسال لـ {count} طفل}}'**
  String hwSend(int count);

  /// No description provided for @hwPickOne.
  ///
  /// In ar, this message translates to:
  /// **'اختر طفلًا واحدًا على الأقل'**
  String get hwPickOne;

  /// No description provided for @hwSentToast.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل الواجب للأولياء'**
  String get hwSentToast;

  /// No description provided for @eduGroupsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مجموعاتي'**
  String get eduGroupsTitle;

  /// No description provided for @eduGroupsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ترى أطفال مجموعاتك فقط'**
  String get eduGroupsSubtitle;

  /// No description provided for @eduGroupsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا مجموعات مسندة إليك'**
  String get eduGroupsEmpty;

  /// No description provided for @statAttendance.
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get statAttendance;

  /// No description provided for @statHomework.
  ///
  /// In ar, this message translates to:
  /// **'الواجبات'**
  String get statHomework;

  /// No description provided for @statNext.
  ///
  /// In ar, this message translates to:
  /// **'القادمة'**
  String get statNext;

  /// No description provided for @groupFlag.
  ///
  /// In ar, this message translates to:
  /// **'{name} غاب 3 مرات متتالية — تواصل رعاية'**
  String groupFlag(String name);

  /// No description provided for @eduGroupsFooter.
  ///
  /// In ar, this message translates to:
  /// **'إضافة الأطفال أو نقلهم بين المجموعات يتمّ عبر الإداري.'**
  String get eduGroupsFooter;

  /// No description provided for @grpTabHomework.
  ///
  /// In ar, this message translates to:
  /// **'الواجبات'**
  String get grpTabHomework;

  /// No description provided for @grpTabStaff.
  ///
  /// In ar, this message translates to:
  /// **'قناة الفريق'**
  String get grpTabStaff;

  /// No description provided for @rosterAttendance.
  ///
  /// In ar, this message translates to:
  /// **'حضور {present}/{expected}'**
  String rosterAttendance(int present, int expected);

  /// No description provided for @rosterNew.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get rosterNew;

  /// No description provided for @rosterCare.
  ///
  /// In ar, this message translates to:
  /// **'▲ غاب 3 مرات متتالية — للمتابعة'**
  String get rosterCare;

  /// No description provided for @hwStateOpen.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ'**
  String get hwStateOpen;

  /// No description provided for @hwStateClosed.
  ///
  /// In ar, this message translates to:
  /// **'منتهٍ'**
  String get hwStateClosed;

  /// No description provided for @hwListMeta.
  ///
  /// In ar, this message translates to:
  /// **'{target} · آخر أجل {date}'**
  String hwListMeta(String target, String date);

  /// No description provided for @hwListMetaClosed.
  ///
  /// In ar, this message translates to:
  /// **'{target} · انتهى {date}'**
  String hwListMetaClosed(String target, String date);

  /// No description provided for @hwTargetChildren.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{طفل واحد} two{طفلان} few{{count} أطفال} many{{count} طفلًا} other{{count} طفل}}'**
  String hwTargetChildren(int count);

  /// No description provided for @hwFooter.
  ///
  /// In ar, this message translates to:
  /// **'الإنجاز تصريح من الأولياء · لا ترتيب علني للأطفال'**
  String get hwFooter;

  /// No description provided for @hwEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا واجبات بعد'**
  String get hwEmpty;

  /// No description provided for @staffChannelNote.
  ///
  /// In ar, this message translates to:
  /// **'قناة المؤطرين والإداريين — لا يراها الأولياء.'**
  String get staffChannelNote;

  /// No description provided for @staffChannelOpen.
  ///
  /// In ar, this message translates to:
  /// **'فتح قناة الفريق'**
  String get staffChannelOpen;

  /// No description provided for @staffChannelMissing.
  ///
  /// In ar, this message translates to:
  /// **'لا قناة فريق لهذه المجموعة بعد'**
  String get staffChannelMissing;

  /// No description provided for @guardianMessage.
  ///
  /// In ar, this message translates to:
  /// **'مراسلة'**
  String get guardianMessage;

  /// No description provided for @guardianEmergency.
  ///
  /// In ar, this message translates to:
  /// **'طوارئ'**
  String get guardianEmergency;

  /// No description provided for @guardianEmergencyHint.
  ///
  /// In ar, this message translates to:
  /// **'الرقم لا يظهر · الاتصال عبر التطبيق'**
  String get guardianEmergencyHint;

  /// No description provided for @guardianCall.
  ///
  /// In ar, this message translates to:
  /// **'☏ اتصال'**
  String get guardianCall;

  /// No description provided for @guardianCallToast.
  ///
  /// In ar, this message translates to:
  /// **'اتصال عبر التطبيق — الرقم مخفي · ⦿ مُسجَّل'**
  String get guardianCallToast;

  /// No description provided for @guardianCallUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'لا رقم مسجَّل لهذا الولي'**
  String get guardianCallUnavailable;

  /// No description provided for @notesTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get notesTitle;

  /// No description provided for @notesPhase2.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الثانية'**
  String get notesPhase2;

  /// No description provided for @notesStaff.
  ///
  /// In ar, this message translates to:
  /// **'للفريق فقط'**
  String get notesStaff;

  /// No description provided for @notesShared.
  ///
  /// In ar, this message translates to:
  /// **'للأولياء'**
  String get notesShared;

  /// No description provided for @notesStaffBody.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات يراها المؤطرون والإداريون فقط — تُفعَّل في المرحلة الثانية.'**
  String get notesStaffBody;

  /// No description provided for @notesSharedBody.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات تصل للأولياء — تُفعَّل في المرحلة الثانية.'**
  String get notesSharedBody;

  /// No description provided for @eduChildHomeworkTile.
  ///
  /// In ar, this message translates to:
  /// **'الواجبات'**
  String get eduChildHomeworkTile;

  /// No description provided for @msgAvailability.
  ///
  /// In ar, this message translates to:
  /// **'ساعات تواجدك {window} · خارجها تصل الرسائل بصمت'**
  String msgAvailability(String window);

  /// No description provided for @msgAvailabilityUnset.
  ///
  /// In ar, this message translates to:
  /// **'لم تحدد ساعات التواجد بعد — من «المزيد»'**
  String get msgAvailabilityUnset;

  /// No description provided for @msgSectionChildrenOf.
  ///
  /// In ar, this message translates to:
  /// **'محادثات الأطفال · {group}'**
  String msgSectionChildrenOf(String group);

  /// No description provided for @msgSectionTeam.
  ///
  /// In ar, this message translates to:
  /// **'الفريق والإدارة'**
  String get msgSectionTeam;

  /// No description provided for @msgFooterEdu.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محادثة خاصة مع طفل — كل محادثة تضمّ الأولياء ومؤطري المجموعة.'**
  String get msgFooterEdu;

  /// No description provided for @quickReply1.
  ///
  /// In ar, this message translates to:
  /// **'وعليكم السلام، جزاكم الله خيرًا'**
  String get quickReply1;

  /// No description provided for @quickReply2.
  ///
  /// In ar, this message translates to:
  /// **'ما شاء الله، أحسن اليوم'**
  String get quickReply2;

  /// No description provided for @quickReply3.
  ///
  /// In ar, this message translates to:
  /// **'نراكم في الجلسة القادمة إن شاء الله'**
  String get quickReply3;

  /// No description provided for @msgComposerHintEdu.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالة…'**
  String get msgComposerHintEdu;

  /// No description provided for @eduMemSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خاصة بأولياء مجموعاتك · لا مشاركة خارجية'**
  String get eduMemSubtitle;

  /// No description provided for @memNewPost.
  ///
  /// In ar, this message translates to:
  /// **'+ منشور'**
  String get memNewPost;

  /// No description provided for @memMyPosts.
  ///
  /// In ar, this message translates to:
  /// **'منشوراتي'**
  String get memMyPosts;

  /// No description provided for @memAlbumsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الألبومات'**
  String get memAlbumsTitle;

  /// No description provided for @memStatePending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الاعتماد'**
  String get memStatePending;

  /// No description provided for @memStatePublished.
  ///
  /// In ar, this message translates to:
  /// **'منشور'**
  String get memStatePublished;

  /// No description provided for @memStateEdit.
  ///
  /// In ar, this message translates to:
  /// **'طُلب تعديل'**
  String get memStateEdit;

  /// No description provided for @memMediaCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{صورة واحدة} two{صورتان} few{{count} صور} many{{count} صورة} other{{count} صورة}}'**
  String memMediaCount(int count);

  /// No description provided for @memTaggedCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{بلا وسم} one{موسوم واحد} two{موسومان} few{{count} موسومين} many{{count} موسومًا} other{{count} موسوم}}'**
  String memTaggedCount(int count);

  /// No description provided for @memMyPostsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم تنشر بعد — أضف أول ذكرى لمجموعتك.'**
  String get memMyPostsEmpty;

  /// No description provided for @memPostsInAlbum.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا منشورات} one{منشور واحد} two{منشوران} few{{count} منشورات} many{{count} منشورًا} other{{count} منشور}}'**
  String memPostsInAlbum(int count);

  /// No description provided for @memComposeTitle.
  ///
  /// In ar, this message translates to:
  /// **'منشور جديد'**
  String get memComposeTitle;

  /// No description provided for @memComposeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يُعرض على الإداري قبل النشر'**
  String get memComposeSubtitle;

  /// No description provided for @memComposeSubtitleLive.
  ///
  /// In ar, this message translates to:
  /// **'يُنشر فورًا لأولياء المجموعة'**
  String get memComposeSubtitleLive;

  /// No description provided for @memAlbumLabel.
  ///
  /// In ar, this message translates to:
  /// **'الألبوم'**
  String get memAlbumLabel;

  /// No description provided for @memAudienceLabel.
  ///
  /// In ar, this message translates to:
  /// **'الجمهور'**
  String get memAudienceLabel;

  /// No description provided for @memAudienceOf.
  ///
  /// In ar, this message translates to:
  /// **'أولياء {group}'**
  String memAudienceOf(String group);

  /// No description provided for @memAudienceAll.
  ///
  /// In ar, this message translates to:
  /// **'أولياء الجمعية'**
  String get memAudienceAll;

  /// No description provided for @memPickAlbum.
  ///
  /// In ar, this message translates to:
  /// **'اختر ألبومًا'**
  String get memPickAlbum;

  /// No description provided for @memCaptionHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تعليقًا قصيرًا…'**
  String get memCaptionHint;

  /// No description provided for @memTagTitle.
  ///
  /// In ar, this message translates to:
  /// **'وسم الأطفال الظاهرين'**
  String get memTagTitle;

  /// No description provided for @memTagCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} موسوم'**
  String memTagCount(int count);

  /// No description provided for @memBlocked.
  ///
  /// In ar, this message translates to:
  /// **'⊘ لا يمكن وسم {name} — حقوق الصورة «غير مسموح». إن كان ظاهرًا في صورة، احذفها قبل النشر.'**
  String memBlocked(String name);

  /// No description provided for @memSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للاعتماد'**
  String get memSubmit;

  /// No description provided for @memPublish.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get memPublish;

  /// No description provided for @memSubmittedToast.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل للإداري للاعتماد'**
  String get memSubmittedToast;

  /// No description provided for @memPublishedToast.
  ///
  /// In ar, this message translates to:
  /// **'نُشر لأولياء المجموعة'**
  String get memPublishedToast;

  /// No description provided for @memNeedMedia.
  ///
  /// In ar, this message translates to:
  /// **'أضف صورة واحدة على الأقل'**
  String get memNeedMedia;

  /// No description provided for @memUploading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الرفع…'**
  String get memUploading;

  /// No description provided for @memConsentBlockedToast.
  ///
  /// In ar, this message translates to:
  /// **'أزل الأطفال الممنوعين قبل النشر'**
  String get memConsentBlockedToast;

  /// No description provided for @memRemovePhoto.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الصورة'**
  String get memRemovePhoto;

  /// No description provided for @annEduTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلان لمجموعاتي'**
  String get annEduTitle;

  /// No description provided for @annToGuardians.
  ///
  /// In ar, this message translates to:
  /// **'إلى أولياء'**
  String get annToGuardians;

  /// No description provided for @annReachGroups.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{لا أحد} one{يصل إلى وليّ واحد + المؤطرين المشاركين} two{يصل إلى وليَّين + المؤطرين المشاركين} few{يصل إلى {count} أولياء + المؤطرين المشاركين} many{يصل إلى {count} وليًّا + المؤطرين المشاركين} other{يصل إلى {count} وليّ + المؤطرين المشاركين}}'**
  String annReachGroups(int count);

  /// No description provided for @annPickGroup.
  ///
  /// In ar, this message translates to:
  /// **'اختر مجموعة واحدة على الأقل'**
  String get annPickGroup;

  /// No description provided for @annAckTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب تأكيد «قرأتُ»'**
  String get annAckTitle;

  /// No description provided for @annAckBody.
  ///
  /// In ar, this message translates to:
  /// **'ترى من أكّد القراءة ومن لم يؤكد'**
  String get annAckBody;

  /// No description provided for @annUrgentExecOnly.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات العاجلة (SMS) من صلاحية الإداريين فقط.'**
  String get annUrgentExecOnly;

  /// No description provided for @annPublishCta.
  ///
  /// In ar, this message translates to:
  /// **'نشر'**
  String get annPublishCta;

  /// No description provided for @annPublishedToast.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, zero{نُشر الإعلان} one{نُشر الإعلان إلى وليّ واحد} two{نُشر الإعلان إلى وليَّين} few{نُشر الإعلان إلى {count} أولياء} many{نُشر الإعلان إلى {count} وليًّا} other{نُشر الإعلان إلى {count} وليّ}}'**
  String annPublishedToast(int count);

  /// No description provided for @moreEduRole.
  ///
  /// In ar, this message translates to:
  /// **'مؤطر · {groups}'**
  String moreEduRole(String groups);

  /// No description provided for @availTitle.
  ///
  /// In ar, this message translates to:
  /// **'ساعات التواجد'**
  String get availTitle;

  /// No description provided for @availBody.
  ///
  /// In ar, this message translates to:
  /// **'خارجها تصل رسائل الأولياء بصمت، ويرون ملاحظة برقم الجمعية للأمور العاجلة.'**
  String get availBody;

  /// No description provided for @availSavedToast.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت ساعات التواجد'**
  String get availSavedToast;

  /// No description provided for @attReminderRow.
  ///
  /// In ar, this message translates to:
  /// **'تذكير تسجيل الحضور'**
  String get attReminderRow;

  /// No description provided for @attReminderLocked.
  ///
  /// In ar, this message translates to:
  /// **'بعد 30 دقيقة · مقفل'**
  String get attReminderLocked;

  /// No description provided for @offlineAttendanceBanner.
  ///
  /// In ar, this message translates to:
  /// **'⦸ بلا اتصال — الحضور يُحفظ على الهاتف ويُزامَن عند عودة الشبكة.'**
  String get offlineAttendanceBanner;

  /// No description provided for @notAvailableToYou.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح لك'**
  String get notAvailableToYou;
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

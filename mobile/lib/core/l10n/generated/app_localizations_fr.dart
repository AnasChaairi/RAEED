// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppL10nFr extends AppL10n {
  AppL10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'RAEED';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonBack => 'Retour';

  @override
  String get errorNetworkTitle => 'Connexion impossible';

  @override
  String get errorNetworkBody =>
      'Vérifiez votre connexion internet, puis réessayez.';

  @override
  String get errorGenericTitle => 'Une erreur est survenue';

  @override
  String get errorGenericBody =>
      'Nous n\'avons pas pu terminer l\'opération. Réessayez dans un instant.';

  @override
  String get errorForbiddenTitle => 'Non accessible';

  @override
  String get errorForbiddenBody =>
      'Vous n\'avez pas l\'autorisation de consulter ce contenu. Contactez l\'administration de l\'académie si vous pensez qu\'il s\'agit d\'une erreur.';

  @override
  String get errorSessionExpiredTitle => 'Session expirée';

  @override
  String get errorSessionExpiredBody => 'Veuillez vous reconnecter.';

  @override
  String get errorContractTitle => 'Mise à jour requise';

  @override
  String get errorContractBody =>
      'Cette version de l\'application n\'est plus compatible avec le serveur. Veuillez la mettre à jour.';

  @override
  String get offlineBannerMessage =>
      'Vous êtes hors ligne. Les dernières données enregistrées sont affichées.';

  @override
  String get offlineRefreshFailed => 'Actualisation impossible';

  @override
  String get loginTitle => 'Bienvenue sur RAEED';

  @override
  String get loginSubtitle =>
      'Saisissez votre numéro de téléphone pour recevoir un code de connexion.';

  @override
  String get loginPhoneLabel => 'Numéro de téléphone';

  @override
  String get loginPhoneHint => '+212 6XX XXX XXX';

  @override
  String get loginPhoneInvalid => 'Saisissez un numéro de téléphone valide.';

  @override
  String get loginRequestCode => 'Envoyer le code';

  @override
  String get loginNoAccountNotice =>
      'Les comptes sont créés uniquement par l\'administration de l\'académie. Si vous n\'avez pas de compte, contactez-la.';

  @override
  String get otpTitle => 'Code de connexion';

  @override
  String otpSentTo(String phone) {
    return 'Nous avons envoyé un code à six chiffres au $phone.';
  }

  @override
  String get otpCodeLabel => 'Code';

  @override
  String get otpVerify => 'Valider';

  @override
  String get otpInvalid => 'Code incorrect ou expiré.';

  @override
  String get otpRateLimited =>
      'Vous avez demandé trop de codes. Réessayez dans une heure.';

  @override
  String get otpResend => 'Renvoyer le code';

  @override
  String otpResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Renvoi possible dans $seconds secondes',
      one: 'Renvoi possible dans $seconds seconde',
    );
    return '$_temp0';
  }

  @override
  String get consentTitle => 'Confidentialité et droit à l\'image';

  @override
  String get consentIntro =>
      'Avant de continuer, nous avons besoin de votre accord sur la politique de confidentialité et du niveau de droit à l\'image pour chaque enfant.';

  @override
  String get consentPrivacyPolicyAccept =>
      'J\'accepte la politique de confidentialité';

  @override
  String get consentPrivacyPolicyRead => 'Lire la politique de confidentialité';

  @override
  String get consentImageRightsTitle => 'Droit à l\'image';

  @override
  String consentImageRightsForChild(String childName) {
    return 'Droit à l\'image pour $childName';
  }

  @override
  String get consentImageRightsAllowed => 'Autorisé';

  @override
  String get consentImageRightsAllowedHelp =>
      'Les photos de l\'enfant peuvent être publiées dans l\'application et sur les canaux officiels de l\'académie.';

  @override
  String get consentImageRightsAppOnly => 'Application uniquement';

  @override
  String get consentImageRightsAppOnlyHelp =>
      'Les photos de l\'enfant sont visibles uniquement dans l\'application et ne sont publiées nulle part ailleurs.';

  @override
  String get consentImageRightsNotAllowed => 'Non autorisé';

  @override
  String get consentImageRightsNotAllowedHelp =>
      'Aucune photo de l\'enfant ne sera publiée.';

  @override
  String get consentChangeLater =>
      'Vous pouvez modifier ce choix à tout moment dans les réglages de l\'enfant.';

  @override
  String get consentSubmit => 'Enregistrer les consentements';

  @override
  String get navHome => 'Accueil';

  @override
  String get navSchedule => 'Planning';

  @override
  String get navMessages => 'Messages';

  @override
  String get navMemories => 'Souvenirs';

  @override
  String get navMore => 'Plus';

  @override
  String get navGroups => 'Groupes';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get roleParent => 'Parent';

  @override
  String get roleEducator => 'Encadrant';

  @override
  String get roleExecutive => 'Responsable';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get roleSwitchTitle => 'Changer de rôle';

  @override
  String get notFoundTitle => 'Page introuvable';

  @override
  String get notFoundBody => 'Le lien que vous avez ouvert n\'est plus valide.';

  @override
  String get notFoundGoHome => 'Revenir à l\'accueil';
}

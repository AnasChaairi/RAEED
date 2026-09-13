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

  @override
  String get homeTitleParent => 'Mes enfants';

  @override
  String get homeTitleEducator => 'Mes groupes';

  @override
  String get homeTitleExecutive => 'Les enfants';

  @override
  String get homeEmptyTitle => 'Aucun enfant lié à votre compte';

  @override
  String get homeEmptyBody =>
      'Veuillez contacter l\'administration de l\'académie pour lier votre enfant à votre compte.';

  @override
  String childAgeYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years ans',
      one: '$years an',
    );
    return '$_temp0';
  }

  @override
  String get childNoSessionToday => 'Pas de séance aujourd\'hui';

  @override
  String childNextSession(String when) {
    return 'Prochaine séance : $when';
  }

  @override
  String get statusAwaitingAnswer => 'Confirmation de présence attendue';

  @override
  String get statusPresenceConfirmed => 'Présence confirmée';

  @override
  String get statusPresenceDeclined => 'Absence annoncée';

  @override
  String get statusPresenceLate => 'Arrivera en retard';

  @override
  String get statusPresent => 'Présent';

  @override
  String get statusLate => 'En retard';

  @override
  String get statusAbsent => 'Absent';

  @override
  String get statusExcused => 'Absence excusée';

  @override
  String get statusUnknown => '—';

  @override
  String get absenceAlertTitle => 'Absence sans justification';

  @override
  String get healthAlertBadgeLabel => 'Alerte santé — appuyez pour consulter';

  @override
  String get announcementsStripTitle => 'Annonces';

  @override
  String get announcementUrgent => 'Urgent';

  @override
  String get announcementsEmpty => 'Aucune annonce pour le moment';

  @override
  String get childProfileTitle => 'Fiche de l\'enfant';

  @override
  String get childProfileGroupLabel => 'Groupe';

  @override
  String get childProfileHealthTitle => 'Informations de santé';

  @override
  String get childProfileNoHealthInfo =>
      'Aucune information de santé enregistrée.';

  @override
  String get childHealthAllergies => 'Allergies';

  @override
  String get childHealthConditions => 'Pathologies';

  @override
  String get childHealthMedications => 'Traitements';

  @override
  String get childHealthDiet => 'Notes alimentaires';

  @override
  String get childHealthOther => 'Autres';

  @override
  String get childProfileComingSoon => 'Cette section sera bientôt disponible.';

  @override
  String get pullToRefresh => 'Tirez pour actualiser';

  @override
  String get childTabSchedule => 'Planning';

  @override
  String get childTabAttendance => 'Présence';

  @override
  String get childTabHomework => 'Devoirs';

  @override
  String get childTabMaterials => 'Ressources';

  @override
  String get attendanceTitle => 'Saisie des présences';

  @override
  String get attendancePresent => 'Présent';

  @override
  String get attendanceLate => 'En retard';

  @override
  String get attendanceAbsent => 'Absent';

  @override
  String get attendanceExcused => 'Excusé';

  @override
  String get attendanceNotMarked => 'Non saisi';

  @override
  String attendanceSummaryConfirmed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count confirmés',
      one: '$count confirmé',
    );
    return '$_temp0';
  }

  @override
  String attendanceSummaryAbsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count absents',
      one: '$count absent',
    );
    return '$_temp0';
  }

  @override
  String attendanceSummaryNoAnswer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sans réponse',
      one: '$count sans réponse',
    );
    return '$_temp0';
  }

  @override
  String attendanceMarkedOf(int marked, int total) {
    return '$marked sur $total enregistrés';
  }

  @override
  String get attendanceMarkRemainingPresent => 'Marquer le reste présent';

  @override
  String get attendanceSubmit => 'Envoyer';

  @override
  String get attendanceSubmitted => 'Présences envoyées';

  @override
  String get attendanceEmptyGroup =>
      'Aucun enfant dans ce groupe pour l\'instant';

  @override
  String get attendanceOfflineSaved =>
      'Enregistré sur cet appareil, sera synchronisé';

  @override
  String attendancePendingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saisies en attente',
      one: '$count saisie en attente',
    );
    return '$_temp0';
  }

  @override
  String get attendanceConflictTitle => 'Conflit de saisie';

  @override
  String attendanceConflictBody(String attempted, String server) {
    return 'Vous avez saisi $attempted, mais $server a été enregistré avant depuis un autre appareil.';
  }

  @override
  String get attendanceConflictKeepMine => 'Garder ma saisie';

  @override
  String get attendanceConflictKeepServer => 'Garder l\'enregistrement';

  @override
  String get attendanceUnknownChild =>
      'Cet enfant n\'est plus dans ce groupe ; la saisie n\'a pas été enregistrée.';

  @override
  String get presenceTitle => 'Confirmation de présence';

  @override
  String presenceQuestion(String childName, String when) {
    return '$childName sera-t-il présent à la séance de $when ?';
  }

  @override
  String get presenceYes => 'Oui';

  @override
  String get presenceNo => 'Non';

  @override
  String get presenceLate => 'En retard';

  @override
  String get presenceReasonPrompt => 'Motif (facultatif)';

  @override
  String get presenceReasonIllness => 'Maladie';

  @override
  String get presenceReasonTravel => 'Voyage';

  @override
  String get presenceReasonExam => 'Examen';

  @override
  String get presenceReasonOther => 'Autre motif';

  @override
  String get presenceOtherNoteLabel => 'Précisez le motif';

  @override
  String get presenceAnswered => 'Merci, votre réponse est enregistrée';

  @override
  String get presenceNoneOutstanding => 'Aucune confirmation en attente';

  @override
  String get brandTagline => 'Vertueux pour lui-même, bienfaisant pour autrui';

  @override
  String get otpEnterCode => 'Saisissez le code';

  @override
  String consentStepOf(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get consentChoose => 'Choisir';

  @override
  String get homeGreeting => 'Assalamu alaykum';

  @override
  String get homeTodaySessions => 'Séances du jour';

  @override
  String get homeNotifications => 'Notifications';

  @override
  String homeNotificationsWithUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications, $count non lues',
      one: 'Notifications, $count non lue',
    );
    return '$_temp0';
  }

  @override
  String get homeNeedsYourReply => 'Votre réponse est attendue';
}

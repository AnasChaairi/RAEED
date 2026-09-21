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

  @override
  String get execTabDashboard => 'Tableau';

  @override
  String get execTabAnnouncements => 'Annonces';

  @override
  String get execTabMessages => 'Messages';

  @override
  String get execTabMemories => 'Souvenirs';

  @override
  String get execTabGroups => 'Groupes';

  @override
  String get execNavLabel => 'Navigation';

  @override
  String get execMore => 'Plus';

  @override
  String get execScopeAllBranches => 'Toutes les antennes';

  @override
  String get execScopeRestricted => 'Votre antenne seulement (restreint)';

  @override
  String execStaleOffline(String time) {
    return 'Hors ligne — dernière version affichée ($time).';
  }

  @override
  String execStaleRefreshFailed(String time) {
    return 'Actualisation impossible — version de $time affichée.';
  }

  @override
  String get recordedActionMarker =>
      'Cette action est enregistrée à votre nom, avec l\'heure et l\'appareil.';

  @override
  String get recordedShort => 'enregistré';

  @override
  String dashSessionsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances aujourd\'hui',
      one: '1 séance aujourd\'hui',
      zero: 'Aucune séance aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String dashSessionsBreakdown(int live, int upcoming) {
    return '$live en cours · $upcoming à venir';
  }

  @override
  String get dashNeedsAttention => 'Requiert votre attention';

  @override
  String get dashNoAlertsTitle =>
      'Rien ne requiert votre attention aujourd\'hui';

  @override
  String get dashNoAlertsBody =>
      'Aucune alerte ni demande en attente pour l\'instant.';

  @override
  String get severityDanger => 'Urgent';

  @override
  String get severityWarning => 'Attention';

  @override
  String get severityInfo => 'Info';

  @override
  String get statChildren => 'Enfants';

  @override
  String get statFamilies => 'Familles';

  @override
  String get statGroups => 'Groupes';

  @override
  String get statEducators => 'Éducateurs';

  @override
  String get dashWeeklyAttendance => 'Présence de la semaine';

  @override
  String get dashTooLittleData => 'Pas encore assez de données';

  @override
  String get dashTodaySessions => 'Séances du jour';

  @override
  String get dashNoSessionsToday => 'Aucune séance aujourd\'hui';

  @override
  String get sessionAttendanceRecorded => 'Enregistrée';

  @override
  String get sessionAttendanceNotRecorded => 'Non enregistrée';

  @override
  String get sessionAttendanceLive => 'En cours';

  @override
  String get sessionAttendanceUpcoming => 'À venir';

  @override
  String get annNew => 'Nouvelle annonce';

  @override
  String get annStatePublished => 'Publiée';

  @override
  String get annStateScheduled => 'Programmée';

  @override
  String get annStateDraft => 'Brouillon';

  @override
  String get annStateExpired => 'Expirée';

  @override
  String annReadBy(int percent) {
    return 'Lue par $percent %';
  }

  @override
  String get annPinned => 'Épinglée';

  @override
  String get annEmptyTitle => 'Aucune annonce pour l\'instant';

  @override
  String get annEmptyBody =>
      'Créez la première annonce pour les parents ou les éducateurs.';

  @override
  String annMetaPublished(String when) {
    return 'Publiée $when';
  }

  @override
  String annMetaScheduled(String when) {
    return 'Programmée $when';
  }

  @override
  String annMetaExpires(String when) {
    return 'Expire $when';
  }

  @override
  String get annFieldTitle => 'Titre';

  @override
  String get annFieldBody => 'Texte';

  @override
  String get annTitleHint => 'Titre de l\'annonce';

  @override
  String get annBodyHint => 'Texte de l\'annonce';

  @override
  String get annFieldAudience => 'Destinataires';

  @override
  String get annChange => 'Modifier';

  @override
  String get annPublishTiming => 'Publication';

  @override
  String get annPublishNow => 'Maintenant';

  @override
  String get annExpires => 'Expire';

  @override
  String get annNoExpiry => 'Sans expiration';

  @override
  String get annUrgentTitle => 'Priorité urgente';

  @override
  String get annUrgentBody =>
      'Notification immédiate + SMS à qui n\'ouvre pas l\'application. Urgences uniquement.';

  @override
  String get annSend => 'Publier l\'annonce';

  @override
  String annSendUrgent(int reach) {
    return 'Envoi urgent · $reach';
  }

  @override
  String get annAudienceSheetTitle => 'Qui reçoit l\'annonce ?';

  @override
  String get audAll => 'Tout le monde';

  @override
  String get audParents => 'Parents seulement';

  @override
  String get audEducators => 'Éducateurs seulement';

  @override
  String get audCategories => 'Catégories choisies';

  @override
  String get audCategoriesHeading => 'Catégories';

  @override
  String audPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
      zero: 'personne',
    );
    return '$_temp0';
  }

  @override
  String get audDone => 'OK';

  @override
  String get audSummaryAll =>
      'Tous les parents et éducateurs de votre périmètre.';

  @override
  String get audSummaryParents => 'Tous les parents des enfants inscrits.';

  @override
  String get audSummaryEducators => 'Les éducateurs, sans les parents.';

  @override
  String audSummaryCategories(String names) {
    return 'Parents des enfants : $names.';
  }

  @override
  String get audSummaryNone =>
      'Aucune catégorie choisie — personne ne le recevra.';

  @override
  String get annUrgentConfirmKind => 'Large portée — canal critique';

  @override
  String annUrgentConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoi urgent à $count personnes ?',
      one: 'Envoi urgent à 1 personne ?',
      zero: 'Envoi urgent à personne ?',
    );
    return '$_temp0';
  }

  @override
  String get annUrgentConfirmBody =>
      'Notification immédiate à tous, puis SMS à qui n\'ouvre pas l\'application sous 10 minutes, aux frais de l\'association. Urgences uniquement.';

  @override
  String get annUrgentConfirmLog =>
      'L\'envoi urgent est enregistré à votre nom, avec les destinataires et le coût.';

  @override
  String get annUrgentConfirmCta => 'Oui, envoyer en urgence';

  @override
  String annPublished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Annonce publiée à $count personnes',
      one: 'Annonce publiée à 1 personne',
      zero: 'Annonce publiée',
    );
    return '$_temp0';
  }

  @override
  String annPublishedUrgent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Annonce urgente envoyée à $count personnes',
      one: 'Annonce urgente envoyée à 1 personne',
      zero: 'Annonce urgente envoyée',
    );
    return '$_temp0';
  }

  @override
  String get annUrgentTag => 'Urgent';

  @override
  String get msgOversightSubtitle =>
      'Supervision — la lecture des conversations dont vous n\'êtes pas membre est enregistrée.';

  @override
  String get msgSectionChildren => 'Conversations des enfants';

  @override
  String get msgSectionStaff => 'Canaux des éducateurs';

  @override
  String get msgSectionExecutives => 'Responsables';

  @override
  String get msgEmptyTitle => 'Aucune conversation pour l\'instant';

  @override
  String get msgEmptyBody =>
      'Une conversation est créée pour chaque enfant à son inscription.';

  @override
  String get msgOversightNotice =>
      'Vous n\'êtes pas membre ici — votre lecture est une supervision enregistrée et connue des membres.';

  @override
  String msgReportedBy(String name, String reason) {
    return 'Signalé par $name : $reason';
  }

  @override
  String get msgHide => 'Masquer';

  @override
  String get msgDismissReport => 'Rejeter le signalement';

  @override
  String msgHiddenStub(String name, String time) {
    return 'Masqué · par $name $time · visible des responsables seulement';
  }

  @override
  String get msgComposerHint => 'Écrire en tant que responsable…';

  @override
  String get msgSend => 'Envoyer';

  @override
  String get msgVoiceNote => 'Message vocal';

  @override
  String get msgHideConfirmKind => 'Masquage — réversible';

  @override
  String msgHideConfirmTitle(String name) {
    return 'Masquer le message de $name ?';
  }

  @override
  String get msgHideConfirmBody =>
      'Il disparaît pour les membres et reste visible des responsables, marqué « masqué ». Aucune suppression. L\'expéditeur sera informé du motif.';

  @override
  String get msgHideConfirmLog =>
      'Le masquage est enregistré à votre nom et clôt le signalement.';

  @override
  String get msgHideConfirmCta => 'Masquer le message';

  @override
  String get msgHiddenToast => 'Message masqué';

  @override
  String get msgReportDismissedToast => 'Signalement rejeté';

  @override
  String get msgThreadEmpty => 'Aucun message pour l\'instant';

  @override
  String get memTitle => 'Modération des souvenirs';

  @override
  String memQueueLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publications en attente',
      one: '1 publication en attente',
      zero: 'Aucune publication en attente',
    );
    return '$_temp0';
  }

  @override
  String get memModeApproveFirst => 'Approbation avant publication';

  @override
  String get memModePublishThenReview => 'Publication puis modération';

  @override
  String get memModeUnset => 'Mode de modération pas encore défini';

  @override
  String get memBlockedBadge =>
      'Bloqué — droits à l\'image modifiés après publication';

  @override
  String memBlockedBody(String name) {
    return '$name est passé à « non autorisé ». Retirez la photo ou laissez la publication masquée.';
  }

  @override
  String memCounter(int index, int count) {
    return '$index / $count';
  }

  @override
  String get imageRightsAllowed => 'Autorisé';

  @override
  String get imageRightsAppOnly => 'Dans l\'application seulement';

  @override
  String get imageRightsNotAllowed => 'Non autorisé';

  @override
  String imageRightsLabel(String level) {
    return 'Droits à l\'image : $level';
  }

  @override
  String get memHide => 'Masquer';

  @override
  String get memEdit => 'Modifier';

  @override
  String get memApprove => 'Approuver';

  @override
  String get memKeep => 'Conserver';

  @override
  String get memReapprove => 'Réapprouver';

  @override
  String get memHideHint =>
      'Masquer n\'est pas supprimer — la publication reste visible des responsables.';

  @override
  String get memAllReviewedTitle => 'Vous avez tout passé en revue';

  @override
  String get memAllReviewedBody => 'Aucune publication en attente.';

  @override
  String get memWall => 'Le mur';

  @override
  String memAlbumPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publications',
      one: '1 publication',
      zero: 'aucune publication',
    );
    return '$_temp0';
  }

  @override
  String get memNoAlbums => 'Aucun album cette saison';

  @override
  String get memApprovedToast => 'Publication approuvée';

  @override
  String get memHiddenToast => 'Publication masquée (non supprimée)';

  @override
  String grpCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes',
      one: '1 groupe',
      zero: 'aucun groupe',
    );
    return '$_temp0';
  }

  @override
  String get grpEmptyTitle => 'Aucun groupe cette saison';

  @override
  String get grpEmptyBody =>
      'Les groupes se créent depuis le tableau de bord web.';

  @override
  String get grpOverCapacity => 'Au-delà de la capacité';

  @override
  String get grpTabSessions => 'Séances';

  @override
  String get grpTabRoster => 'Liste';

  @override
  String get grpSessionsEmpty => 'Aucune séance pour l\'instant';

  @override
  String get grpRosterEmpty => 'Aucun enfant dans ce groupe';

  @override
  String get sessionEnded => 'Terminée';

  @override
  String get sessionCancelled => 'Annulée';

  @override
  String get sessionToday => 'Aujourd\'hui';

  @override
  String reviewTitle(String group) {
    return 'Présence — $group';
  }

  @override
  String reviewRecordedBy(String name, String time) {
    return 'Enregistrée par $name $time';
  }

  @override
  String get reviewCorrect => 'Corriger';

  @override
  String get reviewGuardianNoAnswer => 'Sans réponse';

  @override
  String get reviewGuardianConfirmed => 'Le parent a confirmé';

  @override
  String get reviewGuardianDeclared => 'Le parent a déclaré l\'absence';

  @override
  String get reviewGuardianLate => 'Le parent a annoncé un retard';

  @override
  String reviewTrailOriginal(String status, String name, String time) {
    return 'Enregistré $status — $name · $time';
  }

  @override
  String reviewTrailCorrected(String status, String name, String time) {
    return 'Corrigé en $status — $name · $time';
  }

  @override
  String reviewTrailRefers(String id) {
    return 'Réfère à #$id';
  }

  @override
  String get reviewTrailNotified => 'Parents prévenus';

  @override
  String corrTitle(String name) {
    return 'Corriger la présence de $name';
  }

  @override
  String get corrBody =>
      'Un nouvel enregistrement référence l\'original — rien n\'est effacé. Visible des parents et de l\'éducateur.';

  @override
  String get corrNoteHint => 'Note (facultative)';

  @override
  String get corrSave => 'Enregistrer la correction';

  @override
  String get corrSavedToast => 'Correction enregistrée';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notifFilterAll => 'Tout';

  @override
  String get notifFilterCritical => 'Critique';

  @override
  String get notifFilterRequests => 'Demandes';

  @override
  String get notifFilterMemories => 'Souvenirs';

  @override
  String get notifEmptyTitle => 'Rien de nouveau';

  @override
  String get notifEmptyBody => 'Vous êtes à jour.';

  @override
  String get timeJustNow => 'à l\'instant';

  @override
  String timeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count min',
      one: 'il y a 1 min',
      zero: 'à l\'instant',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count h',
      one: 'il y a 1 h',
      zero: 'à l\'instant',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'hier',
      zero: 'aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get moreCurrentRole => 'Rôle actuel';

  @override
  String moreRolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vous avez $count rôles',
      one: 'vous avez 1 rôle',
      zero: 'aucun rôle',
    );
    return '$_temp0';
  }

  @override
  String get roleHintExecutive =>
      'Tableau de suivi et supervision de tous les groupes';

  @override
  String get roleHintAdmin =>
      'Tout ce que voit un responsable, plus la structure et les utilisateurs';

  @override
  String get roleHintEducator => 'Présence et devoirs de vos groupes';

  @override
  String get roleHintParent => 'Le suivi de vos enfants';

  @override
  String get moreDarkMode => 'Mode sombre';

  @override
  String get moreLanguage => 'Langue';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get moreCriticalChannel => 'Notifications du canal critique';

  @override
  String get moreCriticalChannelLocked =>
      'Verrouillé : les alertes d\'absence, les annonces urgentes et les changements de séance sous 24 h arrivent toujours.';

  @override
  String moreVersion(String version) {
    return 'Version $version';
  }

  @override
  String get moreTagline => 'صالح في نفسه، مصلح لغيره';

  @override
  String get dialogCancel => 'Annuler';
}

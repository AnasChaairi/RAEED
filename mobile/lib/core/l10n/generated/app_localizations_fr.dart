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
  String get errorLastGuardian =>
      'Impossible de retirer ce tuteur : un enfant n\'en aurait plus aucun. Ajoutez d\'abord un autre tuteur.';

  @override
  String get errorPhoneTaken =>
      'Ce numéro est déjà utilisé par un autre compte.';

  @override
  String get errorGuardianAlreadyLinked =>
      'Ce compte est déjà tuteur de ces enfants.';

  @override
  String get errorNoActiveSeason =>
      'Aucune saison active. Ouvrez-en une dans « Structure », puis créez le groupe.';

  @override
  String get errorNoBranch =>
      'Aucune antenne pour l\'instant. Ajoutez-en une dans « Structure », puis créez le groupe.';

  @override
  String get openStructure => 'Structure';

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
  String get loginPhoneLabel => 'Numéro de téléphone';

  @override
  String get loginPhoneHint => '6XX XXX XXX';

  @override
  String get loginPhoneInvalid => 'Saisissez un numéro de téléphone valide.';

  @override
  String get loginNoAccountNotice =>
      'Les comptes sont créés uniquement par l\'administration de l\'académie. Si vous n\'avez pas de compte, contactez-la.';

  @override
  String get loginSubtitle =>
      'Saisissez votre numéro de téléphone et votre mot de passe.';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginPasswordRule => '6 lettres ou chiffres';

  @override
  String get loginPasswordInvalid =>
      'Le mot de passe fait exactement 6 lettres ou chiffres.';

  @override
  String get loginPasswordShow => 'Afficher le mot de passe';

  @override
  String get loginPasswordHide => 'Masquer le mot de passe';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginInvalidCredentials =>
      'Numéro de téléphone ou mot de passe incorrect.';

  @override
  String get loginRateLimited =>
      'Trop de tentatives. Réessayez dans 15 minutes.';

  @override
  String get morePassword => 'Changer le mot de passe';

  @override
  String get pwdTitle => 'Changer le mot de passe';

  @override
  String get pwdIntro =>
      'Le mot de passe fait 6 lettres ou chiffres. Saisissez l\'actuel puis le nouveau deux fois.';

  @override
  String get pwdCurrent => 'Mot de passe actuel';

  @override
  String get pwdNew => 'Nouveau mot de passe';

  @override
  String get pwdConfirm => 'Confirmer le nouveau mot de passe';

  @override
  String get pwdMismatch => 'Les deux mots de passe ne correspondent pas.';

  @override
  String get pwdWrongCurrent => 'Le mot de passe actuel est incorrect.';

  @override
  String get pwdSave => 'Enregistrer';

  @override
  String get pwdSavedToast => 'Mot de passe modifié';

  @override
  String get handoverTitle => 'Mots de passe provisoires';

  @override
  String get handoverIntro =>
      'Remettez-les au parent en personne. Ils ne s\'affichent qu\'une fois et ne sont pas envoyés.';

  @override
  String get handoverExisting =>
      'Compte déjà existant — son mot de passe n\'a pas changé.';

  @override
  String get handoverDone => 'Remis';

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
  String get statusScheduled => 'Séance aujourd\'hui';

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

  @override
  String get moreChildren => 'Enfants';

  @override
  String get moreChildrenHint => 'Profils et consentements';

  @override
  String get moreManage => 'Familles et groupes';

  @override
  String get moreManageHint =>
      'Nouveau groupe · nouvelle famille · affectation';

  @override
  String get moreReports => 'Rapports et export';

  @override
  String get moreReportsHint => 'Présence · éducateurs · engagement';

  @override
  String get moreStructure => 'Structure';

  @override
  String get moreStructureHint => 'Saisons · catégories · antennes';

  @override
  String get moreLogs => 'Journaux';

  @override
  String get moreLogsHint => 'Audit · accès aux données de santé';

  @override
  String get adminTag => 'Admin';

  @override
  String get moreAdminHint =>
      'Seul l’administrateur ouvre « Structure » et « Journaux ». Toute autre tentative est refusée et consignée.';

  @override
  String get moreSignOut => 'Se déconnecter';

  @override
  String childrenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enfants',
      one: '1 enfant',
      zero: 'aucun enfant',
    );
    return '$_temp0';
  }

  @override
  String get childrenSearchHint => 'Rechercher un enfant';

  @override
  String get filterAll => 'Tout';

  @override
  String get childrenEmptyTitle => 'Aucun enfant ne correspond';

  @override
  String get childrenEmptyBody => 'Essayez une autre recherche ou catégorie.';

  @override
  String attendanceShort(String ratio) {
    return 'présence $ratio';
  }

  @override
  String get imageRightsLegend => 'Droits à l\'image :';

  @override
  String get childSeasonAttendance => 'Présence de la saison';

  @override
  String get childImageRightsTile => 'Droits à l\'image';

  @override
  String get healthSectionTitle => 'Informations de santé';

  @override
  String get healthEveryViewLogged => 'Chaque consultation est enregistrée';

  @override
  String get healthCollapsedBody =>
      'Il y a une alerte de santé. Le contenu est replié à dessein : il s\'affiche à votre demande et la consultation est inscrite au journal d\'accès.';

  @override
  String get healthNoneBody =>
      'Aucune alerte de santé enregistrée pour cet enfant.';

  @override
  String get healthShowButton => 'Afficher les informations de santé';

  @override
  String get healthConfirmTitle => 'Cette consultation sera enregistrée';

  @override
  String healthConfirmBody(String actor, String child) {
    return 'Il sera inscrit que $actor a consulté les données de santé de $child maintenant. Ne l\'ouvrez pas sans raison.';
  }

  @override
  String get healthContinue => 'Continuer';

  @override
  String get healthBack => 'Annuler';

  @override
  String get healthAlertTitle => 'Alerte de santé';

  @override
  String healthRecordedAt(String time) {
    return 'enregistré à $time';
  }

  @override
  String get healthFieldsPending =>
      'Les champs détaillés seront fixés après la déclaration CNDP.';

  @override
  String get healthCollapse => 'Replier';

  @override
  String get healthAllergies => 'Allergies';

  @override
  String get healthConditions => 'Conditions';

  @override
  String get healthMedications => 'Médicaments';

  @override
  String get healthDietary => 'Notes alimentaires';

  @override
  String get healthSpecialNeeds => 'Besoins particuliers';

  @override
  String get guardiansTitle => 'Parents';

  @override
  String get relMother => 'la mère';

  @override
  String get relFather => 'le père';

  @override
  String get relGuardian => 'parent';

  @override
  String get guardianAccountActive => 'Compte actif';

  @override
  String get guardianAccountPending => 'Pas encore connecté';

  @override
  String guardianLastSeen(String when) {
    return 'dernière connexion $when';
  }

  @override
  String get guardianReveal => 'Afficher';

  @override
  String get guardianRevealLogged =>
      'Chaque affichage est enregistré à votre nom, avec l\'heure.';

  @override
  String get guardianRevealToast =>
      'Affichage du numéro enregistré à votre nom';

  @override
  String get consentsTitle => 'Consentements';

  @override
  String get consentPrivacyLabel => 'Politique de confidentialité';

  @override
  String consentVersionAt(int version, String when) {
    return 'v$version · $when';
  }

  @override
  String get consentImageRightsChangeable =>
      'Modifiable par le parent à tout moment';

  @override
  String get consentApproved => 'Accepté';

  @override
  String get consentMissing => 'Pas encore accepté';

  @override
  String get childGroupsTitle => 'Groupes';

  @override
  String get groupMainTag => 'principal';

  @override
  String openChildThread(String name) {
    return 'Ouvrir la conversation de $name (supervision · enregistrée)';
  }

  @override
  String get manageTitle => 'Familles et groupes';

  @override
  String familiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count familles',
      one: '1 famille',
      zero: 'aucune famille',
    );
    return '$_temp0';
  }

  @override
  String get manageTabUnassigned => 'Sans groupe';

  @override
  String get manageTabFamilies => 'Familles';

  @override
  String get manageTabGroups => 'Groupes';

  @override
  String get unassignedHint =>
      'Inscrits sans groupe principal. Cochez des enfants puis « Affecter ».';

  @override
  String get unassignedEmpty => 'Tous les enfants sont dans un groupe.';

  @override
  String assignCta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Affecter $count enfants à un groupe…',
      one: 'Affecter 1 enfant à un groupe…',
    );
    return '$_temp0';
  }

  @override
  String assignSheetTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Affecter $count enfants à un groupe',
      one: 'Affecter 1 enfant à un groupe',
    );
    return '$_temp0';
  }

  @override
  String assignWarn(int after, int capacity, String group) {
    return '$group passera à $after sur $capacity — marqué « au-delà de la capacité ».';
  }

  @override
  String get assignLogged =>
      'L\'affectation est enregistrée à votre nom et les parents prévenus.';

  @override
  String assignTo(String group) {
    return 'Affecter à $group';
  }

  @override
  String get assignPick => 'Choisir un groupe';

  @override
  String get assignOverKind => 'Au-delà de la capacité';

  @override
  String assignOverTitle(String group) {
    return 'Affecter à $group au-delà de la capacité ?';
  }

  @override
  String get assignOverLog =>
      'L\'affectation et le dépassement sont enregistrés à votre nom.';

  @override
  String get assignOverCta => 'Oui, affecter';

  @override
  String assignedToast(int count, String group) {
    return '$count affecté(s) à $group';
  }

  @override
  String get familyStatusActive => 'Active';

  @override
  String get familyStatusPartial => 'Partiellement';

  @override
  String get familyStatusPending => 'Invitation en attente';

  @override
  String get familyResend => 'Renvoyer l\'invitation';

  @override
  String get familyResentToast => 'Invitation renvoyée';

  @override
  String get familyAddChild => '+ enfant';

  @override
  String get familyNoGroup => 'sans groupe';

  @override
  String get familiesEmpty => 'Aucune famille pour l\'instant';

  @override
  String get newFamilyCta => '+ Nouvelle famille';

  @override
  String familyDetailSubtitle(int guardians, int children) {
    String _temp0 = intl.Intl.pluralLogic(
      guardians,
      locale: localeName,
      other: '$guardians tuteurs',
      one: '1 tuteur',
    );
    String _temp1 = intl.Intl.pluralLogic(
      children,
      locale: localeName,
      other: '$children enfants',
      one: '1 enfant',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get familyGuardiansSection => 'Tuteurs';

  @override
  String get familyChildrenSection => 'Enfants';

  @override
  String get familyAddGuardian => '+ Autre tuteur';

  @override
  String get familyEditGuardian => 'Modifier le tuteur';

  @override
  String get familyUnlinkGuardian => 'Retirer de la famille';

  @override
  String familyUnlinkConfirmTitle(String name) {
    return 'Retirer $name de la famille ?';
  }

  @override
  String get familyUnlinkConfirmBody =>
      'Les enfants gardent leurs autres tuteurs, et le compte reste, sans enfant. Le dernier tuteur d\'un enfant ne peut pas être retiré.';

  @override
  String get familyUnlinkRecorded => '⦿ Le retrait est enregistré à votre nom.';

  @override
  String get familyUnlinkCta => 'Retirer';

  @override
  String get familyUnlinkDone => 'Tuteur retiré de la famille.';

  @override
  String get familyGuardianUpdated => 'Enregistré.';

  @override
  String get familyGuardianLinkedExisting =>
      'Un compte existant a été lié aux enfants. Son mot de passe est inchangé.';

  @override
  String get familyGuardianLinked => 'Tuteur lié aux enfants.';

  @override
  String get familyPhoneUnchangedHint =>
      'Laisser vide pour garder le numéro actuel';

  @override
  String get familyPhoneChangeWarning =>
      'Changer le numéro déconnecte le tuteur sur tous ses appareils. Il se reconnecte avec le nouveau numéro et le même mot de passe.';

  @override
  String get familyEditChild => 'Modifier l\'enfant';

  @override
  String get familyChildAdded => 'Enfant ajouté à la famille.';

  @override
  String get familyChildUpdated => 'Enregistré.';

  @override
  String get familyEditRecorded =>
      '⦿ La modification est enregistrée à votre nom.';

  @override
  String get familyNotFoundTitle => 'Cette famille n\'est plus disponible';

  @override
  String get familyNotFoundBody =>
      'Ses tuteurs ont peut-être changé depuis un autre appareil. Revenez à la liste des familles.';

  @override
  String get familyBackToList => 'Vers les familles';

  @override
  String get saveAction => 'Enregistrer';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get newGroupCta => '+ Nouveau groupe';

  @override
  String get groupAssignHere => '+ Affecter des enfants';

  @override
  String get newGroupTitle => 'Nouveau groupe';

  @override
  String get fieldName => 'Nom';

  @override
  String get groupNameHint => 'Ex. : الأشبال 3';

  @override
  String get fieldCategory => 'Catégorie';

  @override
  String get fieldCapacity => 'Capacité';

  @override
  String get fieldSchedule => 'Horaire';

  @override
  String get fieldEducators => 'Éducateurs';

  @override
  String educatorLoad(int count) {
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
  String get fieldChildrenOptional =>
      'Enfants (facultatif) — parmi « sans groupe »';

  @override
  String get checklistNameOk => '✓ Nom';

  @override
  String get checklistNameMissing => '○ Nom requis';

  @override
  String get checklistCategoryMissing => '○ Catégorie requise';

  @override
  String get checklistEducatorOk => '✓ Éducateur';

  @override
  String get checklistEducatorMissing => '○ Au moins un éducateur';

  @override
  String checklistChildren(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '✓ $count enfants',
      one: '✓ 1 enfant',
      zero: '○ Sans enfants (accepté)',
    );
    return '$_temp0';
  }

  @override
  String get checklistLogged => '⦿ enregistré à votre nom';

  @override
  String createGroupCta(String name) {
    return 'Créer « $name »';
  }

  @override
  String groupCreatedToast(String name) {
    return '« $name » créé';
  }

  @override
  String get theGroup => 'le groupe';

  @override
  String get weekdaySun => 'dimanche';

  @override
  String get weekdayMon => 'lundi';

  @override
  String get weekdayTue => 'mardi';

  @override
  String get weekdayWed => 'mercredi';

  @override
  String get weekdayThu => 'jeudi';

  @override
  String get weekdayFri => 'vendredi';

  @override
  String get weekdaySat => 'samedi';

  @override
  String get scheduleEditTitle => 'Horaire hebdomadaire';

  @override
  String get scheduleAddSlot => '+ Créneau hebdomadaire';

  @override
  String get scheduleEmptyHint =>
      'Pas d\'horaire : sans horaire, aucune séance n\'est créée pour ce groupe.';

  @override
  String get scheduleRecorded =>
      '⦿ La modification est enregistrée à votre nom et les séances des prochaines semaines sont créées aussitôt.';

  @override
  String get scheduleSavedToast => 'Horaire enregistré';

  @override
  String get newFamilyTitle => 'Nouvelle famille';

  @override
  String get reviewStepTitle => 'Vérification';

  @override
  String stepOfThree(int step) {
    return 'Étape $step sur 3';
  }

  @override
  String get guardianNameHint => 'Nom du parent';

  @override
  String get guardianPhoneHint => '6XX XXX XXX';

  @override
  String get addGuardian => '+ Autre parent';

  @override
  String childN(int n) {
    return 'Enfant $n';
  }

  @override
  String get remove => 'Retirer';

  @override
  String get childNameHint => 'Nom de l\'enfant';

  @override
  String get dobLabel => 'Date de naissance';

  @override
  String get dobPick => 'Choisir la date';

  @override
  String get mainGroupLabel => 'Groupe principal';

  @override
  String get groupLater => 'Plus tard';

  @override
  String get groupFull => 'complet';

  @override
  String get healthNotHere =>
      'Les informations de santé sont saisies par le parent depuis son compte — pas ici.';

  @override
  String get addChild => '+ Autre enfant';

  @override
  String get whatHappens => 'Ce qui va se passer';

  @override
  String willInvite(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '• Invitation SMS à $count parents, qui acceptent la confidentialité et les droits à l\'image avant de voir quoi que ce soit.',
      one: '• Invitation SMS à 1 parent, qui accepte la confidentialité et les droits à l\'image avant de voir quoi que ce soit.',
    );
    return '$_temp0';
  }

  @override
  String get willShow =>
      '• Les enfants apparaissent au parent avec groupe, horaire et éducateur.';

  @override
  String get willLog => '• ⦿ La création est enregistrée à votre nom.';

  @override
  String unassignedWarn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '▲ $count enfants sans groupe — aucun éducateur ne les verra avant l\'affectation.',
      one: '▲ 1 enfant sans groupe — aucun éducateur ne le verra avant l\'affectation.',
    );
    return '$_temp0';
  }

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String createAndInvite(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Créer et envoyer $count invitations',
      one: 'Créer et envoyer 1 invitation',
      zero: 'Créer',
    );
    return '$_temp0';
  }

  @override
  String familyCreatedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Famille créée · $count invitations',
      one: 'Famille créée · 1 invitation',
      zero: 'Famille créée',
    );
    return '$_temp0';
  }

  @override
  String get reportsTitle => 'Rapports';

  @override
  String get repTabAttendance => 'Présence';

  @override
  String get repTabEducators => 'Éducateurs';

  @override
  String get repTabEngagement => 'Engagement';

  @override
  String get repTabExport => 'Export';

  @override
  String get repByEducator => 'Taux de présence par éducateur';

  @override
  String get repByCategory => 'Par catégorie';

  @override
  String get repRawNote => 'Le taux avec le nombre brut';

  @override
  String repPlanned(int delivered, int planned) {
    return 'planifiées/réalisées $delivered/$planned';
  }

  @override
  String repOnTime(int ontime, int planned) {
    return 'à l\'heure $ontime sur $planned';
  }

  @override
  String get repReplyUnknown => 'réponse —';

  @override
  String get repActivated => 'Comptes parents activés';

  @override
  String get repPresenceAnswers => 'Réponses aux confirmations de présence';

  @override
  String get repHomework => 'Devoirs faits';

  @override
  String get selfReported => 'auto-déclaré';

  @override
  String get repNotYet => 'Pas encore disponible';

  @override
  String get repNoData => 'Pas encore de données';

  @override
  String get exportIntro =>
      'Export de la liste des enfants. Les champs de santé sont désactivés par défaut.';

  @override
  String get exportName => 'Nom complet';

  @override
  String get exportDob => 'Date de naissance';

  @override
  String get exportGroup => 'Catégorie et groupe';

  @override
  String get exportGuardian => 'Nom du parent';

  @override
  String get exportPhone => 'Téléphone du parent';

  @override
  String get exportConsent => 'Droits à l\'image';

  @override
  String get exportAllergies => 'Allergies';

  @override
  String get exportMedications => 'Médicaments';

  @override
  String get healthTag => 'santé';

  @override
  String get exportLogged =>
      'L\'export est enregistré à votre nom avec les champs choisis.';

  @override
  String get exportContainsHealth =>
      'Contient des données de santé — pour le destinataire concerné seulement.';

  @override
  String exportCta(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Créer le fichier · $count champs',
      one: 'Créer le fichier · 1 champ',
    );
    return '$_temp0';
  }

  @override
  String get exportBusy => 'Préparation du fichier…';

  @override
  String get exportReady => 'Fichier prêt';

  @override
  String exportRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes',
      one: '1 ligne',
      zero: 'aucune ligne',
    );
    return '$_temp0';
  }

  @override
  String get exportShare => 'Partager le fichier';

  @override
  String get exportLoggedToast => 'Export enregistré à votre nom';

  @override
  String get structureTitle => 'Structure';

  @override
  String get strTabSeasons => 'Saisons';

  @override
  String get strTabCategories => 'Catégories';

  @override
  String get strTabBranches => 'Antennes';

  @override
  String get seasonActive => 'active';

  @override
  String get seasonArchived => 'archivée';

  @override
  String get seasonArchive => 'Archiver';

  @override
  String get seasonsNote => 'Les saisons s\'archivent et ne se suppriment pas.';

  @override
  String get archiveKind => 'Archivage — réversible';

  @override
  String archiveTitle(String label) {
    return 'Archiver la saison $label ?';
  }

  @override
  String get archiveBody =>
      'Les groupes et inscriptions passent en lecture seule. Rien n\'est supprimé.';

  @override
  String get archiveLog => 'L\'archivage est enregistré à votre nom.';

  @override
  String get archiveCta => 'Archiver la saison';

  @override
  String get archivedToast => 'Saison archivée';

  @override
  String get catsOpenDecision =>
      'Les tranches d\'âge et le genre relèvent du conseil et ne sont pas encore décidés. Les champs sont vides à dessein.';

  @override
  String get catAgeGenderUnset => 'âge/genre : non défini';

  @override
  String catAgeRange(int min, int max) {
    return '$min–$max ans';
  }

  @override
  String get genderBoys => 'garçons';

  @override
  String get genderGirls => 'filles';

  @override
  String get genderMixed => 'mixte';

  @override
  String get branchesNote =>
      'Une seule antenne aujourd\'hui. À la deuxième, le sélecteur d\'antenne apparaît pour les responsables.';

  @override
  String get newBranch => '+ Nouvelle antenne';

  @override
  String get branchNameHint => 'Nom de l\'antenne';

  @override
  String get branchAddressHint => 'Adresse';

  @override
  String get branchCreatedToast => 'Antenne créée';

  @override
  String get newCategory => '+ Nouvelle catégorie';

  @override
  String get categoryNameHint => 'Nom de la catégorie';

  @override
  String get categoryCreatedToast => 'Catégorie créée';

  @override
  String get newSeason => '+ Nouvelle saison';

  @override
  String get seasonLabelHint => 'Libellé de la saison, ex. 2026-2027';

  @override
  String get seasonStartPick => 'Date de début';

  @override
  String get seasonEndPick => 'Date de fin';

  @override
  String get seasonCreatedToast => 'Saison ouverte';

  @override
  String get adminOnlyTitle => 'Section réservée aux administrateurs';

  @override
  String adminOnlyBody(String role) {
    return 'Votre rôle : $role. Demandez-la au président de l\'association.';
  }

  @override
  String get adminOnlyLogged =>
      '⦿ La tentative d\'accès est enregistrée — c\'est normal.';

  @override
  String get logsTitle => 'Journaux';

  @override
  String get logTabAudit => 'Audit';

  @override
  String get logTabHealth => 'Accès santé';

  @override
  String get logsAppendOnly =>
      '⦿ En ajout seul — ni modification ni suppression. Durée de conservation :';

  @override
  String get retentionUnset => 'pas encore définie';

  @override
  String get healthLogIntro =>
      'Qui a consulté les informations de santé de quel enfant et quand — la promesse faite à chaque « Afficher ».';

  @override
  String get logsEmpty => 'Aucune entrée pour l\'instant';

  @override
  String get actionLogin => 'connexion';

  @override
  String get actionCorrect => 'correction de présence';

  @override
  String get actionExport => 'export';

  @override
  String get actionHideMessage => 'message masqué';

  @override
  String get actionHealthView => 'données de santé consultées';

  @override
  String get actionPhoneReveal => 'numéro affiché';

  @override
  String get actionAssign => 'affectation';

  @override
  String get actionCreate => 'création';

  @override
  String get actionUpdate => 'Modification';

  @override
  String get actionLink => 'Tuteur lié';

  @override
  String get actionUnlink => 'Tuteur retiré';

  @override
  String get actionEmergencyCall => 'Appel d\'urgence';

  @override
  String get actionPublish => 'annonce publiée';

  @override
  String get actionApprovePost => 'publication approuvée';

  @override
  String get actionHidePost => 'publication masquée';

  @override
  String get actionOversightRead => 'lecture de supervision';

  @override
  String get actionDenied => 'accès refusé';

  @override
  String get actionArchive => 'archivage';

  @override
  String get actionDismissReport => 'signalement rejeté';

  @override
  String get actionInvite => 'invitation renvoyée';

  @override
  String get actionOther => 'action';

  @override
  String get eduTabToday => 'Aujourd’hui';

  @override
  String get eduTabSessions => 'Séances';

  @override
  String get eduTabGroups => 'Groupes';

  @override
  String get eduTabMessages => 'Messages';

  @override
  String get eduTabMemories => 'Souvenirs';

  @override
  String get eduGreetingMorning => 'Bonjour';

  @override
  String get eduGreetingEvening => 'Bonsoir';

  @override
  String get todayNextSession => 'Prochaine séance';

  @override
  String todayInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count min',
      one: 'dans 1 min',
      zero: 'maintenant',
    );
    return '$_temp0';
  }

  @override
  String get todayLive => 'En cours';

  @override
  String get presTallyYes => 'Vient';

  @override
  String get presTallyLate => 'En retard';

  @override
  String get presTallyNo => 'Absent';

  @override
  String get presTallyNone => 'Sans réponse';

  @override
  String get todayRecordAttendance => 'Faire l’appel';

  @override
  String todayAttendanceDone(String group) {
    return 'Appel fait — $group';
  }

  @override
  String todayAttendanceSummary(
    int present,
    int late,
    int excused,
    int absent,
  ) {
    return 'Présents $present · retard $late · excusés $excused · absents $absent';
  }

  @override
  String get todaySessionSummaryCta => 'Résumé';

  @override
  String todayNoContent(String group, String time) {
    return 'Pas encore de contenu pour la séance $group · $time — créée depuis le planning.';
  }

  @override
  String get todayAdd => 'Ajouter';

  @override
  String get shortcutHomework => 'Devoir';

  @override
  String get shortcutMemory => 'Souvenir';

  @override
  String get shortcutAnnouncement => 'Annonce';

  @override
  String get todayFromManagement => 'De la direction';

  @override
  String get todayAckCta => 'J’ai lu';

  @override
  String get todayAckDone => '✓ Lecture confirmée';

  @override
  String get todayNoSession => 'Pas de séance aujourd’hui';

  @override
  String todayNextOn(String date) {
    return 'Prochaine : $date';
  }

  @override
  String get todayNoSessionsAtAll =>
      'Aucune séance à venir — vérifiez le planning avec la direction.';

  @override
  String get presTitle => 'Confirmations';

  @override
  String presSubtitle(String group, String time, String sent) {
    return '$group · $time · envoyé $sent';
  }

  @override
  String presSubtitleNotSent(String group, String time) {
    return '$group · $time · pas encore envoyé';
  }

  @override
  String get presPlanning => 'Pour préparer (matériel, goûter, transport)';

  @override
  String presExpectedOf(int count) {
    return 'attendus sur $count';
  }

  @override
  String presRemind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rappeler les sans réponse ($count)',
      zero: 'Tout le monde a répondu',
    );
    return '$_temp0';
  }

  @override
  String get presRemindDone => '✓ Rappel envoyé';

  @override
  String presRemindNote(String time) {
    return 'Le rappel n’est envoyé qu’une fois — délai $time';
  }

  @override
  String presRemindedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rappel envoyé à $count parents',
      one: 'Rappel envoyé à 1 parent',
      zero: 'Personne à rappeler',
    );
    return '$_temp0';
  }

  @override
  String get presNotSent =>
      'Aucune demande de confirmation n’a été envoyée pour cette séance.';

  @override
  String attTitle(String group) {
    return 'Appel — $group';
  }

  @override
  String attSubtitle(String time, String title) {
    return '$time · $title · prérempli avec les réponses des parents';
  }

  @override
  String attUnmarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sans statut',
      zero: 'Tous marqués',
    );
    return '$_temp0';
  }

  @override
  String attMarkRest(int count) {
    return '✓ Marquer les autres ($count) présents';
  }

  @override
  String get attPresYes => 'Le parent a confirmé';

  @override
  String get attPresLate => 'Retard annoncé';

  @override
  String get attPresNo => 'Absence annoncée';

  @override
  String get attPresNone => 'Pas de réponse du parent';

  @override
  String get attSave => 'Enregistrer l’appel';

  @override
  String attSaveAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enregistrer · alerter $count parents',
      one: 'Enregistrer · alerter 1 parent',
    );
    return '$_temp0';
  }

  @override
  String get attSaveOffline => 'Enregistrer sur le téléphone';

  @override
  String get attEditHint =>
      'Modifiable pendant 30 minutes, ensuite via un responsable';

  @override
  String get attUnmarkedKind => 'Avant d’enregistrer';

  @override
  String attUnmarkedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enfants sans statut',
      one: '1 enfant sans statut',
    );
    return '$_temp0';
  }

  @override
  String get attUnmarkedBody =>
      'Donnez un statut à chaque enfant. S’ils sont vraiment absents, choisissez « absent » — leurs parents seront alertés immédiatement.';

  @override
  String get attUnmarkedCta => 'Continuer l’appel';

  @override
  String get attAlertKind => 'Alerte de sécurité aux parents';

  @override
  String attAlertTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les parents de $count enfants seront alertés',
      one: 'Les parents d’1 enfant seront alertés',
    );
    return '$_temp0';
  }

  @override
  String attAlertBody(String names) {
    return '$names : absence sans préavis. Les parents reçoivent une notification immédiate (et un SMS s’ils n’ouvrent pas l’application), car ils peuvent croire leur enfant ici.';
  }

  @override
  String get attAlertCta => 'Enregistrer et alerter';

  @override
  String get attAlertCancel => 'Revoir la liste';

  @override
  String attSavedAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Appel enregistré · $count parents alertés',
      one: 'Appel enregistré · 1 parent alerté',
    );
    return '$_temp0';
  }

  @override
  String get attStatusExcusedShort => 'Excusé';

  @override
  String get sessTitle => 'Séances';

  @override
  String sessWeekRange(String from, String to) {
    return 'Semaine du $from au $to';
  }

  @override
  String get sessPrevWeek => 'Semaine précédente';

  @override
  String get sessNextWeek => 'Semaine suivante';

  @override
  String get sessAllGroups => 'Tous mes groupes';

  @override
  String get sessStateUpcoming => 'À venir';

  @override
  String sessStateSoon(int count) {
    return 'dans $count min';
  }

  @override
  String get sessStateLive => 'En cours';

  @override
  String get sessStateNoContent => 'Sans contenu';

  @override
  String get sessStateMoved => 'Reportée';

  @override
  String sessMetaMaterials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count supports',
      one: '1 support',
      zero: 'aucun support',
    );
    return '$_temp0';
  }

  @override
  String get sessMetaHomework => 'devoir';

  @override
  String get sessMetaGenerated => 'créée depuis le planning';

  @override
  String sessMetaWith(String name) {
    return 'avec $name';
  }

  @override
  String get sessFooter =>
      'Les séances viennent de l\'horaire du groupe — ajoutez le contenu, ou créez une activité avec +.';

  @override
  String get sessEmptyWeek => 'Pas de séance cette semaine';

  @override
  String get activityNewTitle => 'Nouvelle activité';

  @override
  String get activityNewSubtitle =>
      'Séance, sport ou atelier pour un de vos groupes';

  @override
  String get activityGroup => 'Groupe';

  @override
  String get activityKind => 'Type';

  @override
  String get activityKindSession => 'Séance';

  @override
  String get activityKindSport => 'Sport';

  @override
  String get activityKindWorkshop => 'Atelier';

  @override
  String get activitySlot => 'Créneau';

  @override
  String get activityPickDay => 'Choisir le jour';

  @override
  String get activityTitleHint => 'ex. Match amical, Atelier calligraphie';

  @override
  String get activityPlace => 'Lieu';

  @override
  String get activityPlaceHint => 'Salle, terrain…';

  @override
  String get activityContent => 'Contenu';

  @override
  String get activityContentHint =>
      'Ce qui se passera — visible par les parents.';

  @override
  String get activityNotice =>
      'Les parents du groupe sont prévenus aussitôt et l\'activité apparaît dans l\'horaire de leurs enfants. ⦿ Enregistré à votre nom.';

  @override
  String get activityCreateCta => 'Créer et prévenir les parents';

  @override
  String get activityCreatedToast => 'Activité créée, parents prévenus';

  @override
  String get shortcutActivity => 'Activité';

  @override
  String get childScheduleEmpty => 'Rien à venir pour ce groupe.';

  @override
  String get childScheduleNoGroup =>
      'L\'enfant n\'est pas encore dans un groupe.';

  @override
  String get childScheduleCancelled => 'annulée';

  @override
  String get sessObjectives => 'Objectifs';

  @override
  String get sessMaterials => 'Supports';

  @override
  String get sessHomework => 'Devoir';

  @override
  String get sessAddHomework => '+ devoir';

  @override
  String sessHomeworkMeta(String target, String due, int done, int total) {
    return '$target · pour le $due · $done/$total fait (déclaré par les parents)';
  }

  @override
  String get sessWholeGroup => 'Tout le groupe';

  @override
  String get sessAttendanceDone => '✓ Appel fait';

  @override
  String get sessSummaryDone => '✓ Résumé';

  @override
  String get sessSummaryCta => 'Résumé de la séance';

  @override
  String get sessCancelCta => 'Annuler ou reporter la séance';

  @override
  String get sessCancelledBanner =>
      '✕ Séance annulée · parents et équipe prévenus';

  @override
  String sessMovedBanner(String when) {
    return '⏱ Reportée au $when · parents prévenus';
  }

  @override
  String get sessNoObjectives =>
      'Pas encore d’objectifs — ajoutez-les via « modifier ».';

  @override
  String get sessNoMaterials => 'Pas encore de supports';

  @override
  String get sessNoHomework => 'Aucun devoir lié à cette séance';

  @override
  String get sessEdit => 'Modifier';

  @override
  String get visBefore => 'Avant la séance';

  @override
  String get visAfter => 'Après la séance';

  @override
  String get visStaff => 'Éducateurs seulement';

  @override
  String get matKindDocument => 'Fichier';

  @override
  String get matKindImage => 'Photo';

  @override
  String get matKindAudio => 'Audio';

  @override
  String get matKindVideo => 'Vidéo';

  @override
  String get matKindLink => 'Lien';

  @override
  String get sessContentTitle => 'Contenu de la séance';

  @override
  String sessContentSubtitle(String group, String time) {
    return '$group · $time · depuis le planning';
  }

  @override
  String get sessTitleHint => 'ex. : Cercle de Coran — sourate Al-Mulk';

  @override
  String get sessTheme => 'Thème';

  @override
  String get themeQuran => 'Coran';

  @override
  String get themeSira => 'Sîra';

  @override
  String get themeAkhlaq => 'Éthique';

  @override
  String get themeHadith => 'Hadith';

  @override
  String get themeSkills => 'Compétences';

  @override
  String get sessObjectivesHint => 'Un objectif par ligne…';

  @override
  String get sessMaterialsWho => 'Supports et visibilité';

  @override
  String get sessVideoLimit => 'Vidéo ≤ 50 Mo · les longues en lien';

  @override
  String get addFile => '+ fichier';

  @override
  String get addPhoto => '+ photo';

  @override
  String get addAudio => '+ audio';

  @override
  String get addLink => '+ lien';

  @override
  String get sessSaveContent => 'Enregistrer le contenu';

  @override
  String get sessContentSaved => 'Contenu enregistré';

  @override
  String get linkUrlHint => 'https://…';

  @override
  String get linkTitleHint => 'Titre du lien';

  @override
  String get linkAdd => 'Ajouter le lien';

  @override
  String get uploadFailed => 'Échec de l’envoi du fichier';

  @override
  String get sumTitle => 'Qu’avons-nous fait aujourd’hui ?';

  @override
  String sumSubtitle(String group) {
    return 'Résumé envoyé aux parents de $group';
  }

  @override
  String get sumHint =>
      'Ce que les enfants ont appris, et ce que les parents peuvent réviser…';

  @override
  String get sumConsentNote =>
      'Les photos avec des visages passent par le droit à l’image, comme les souvenirs.';

  @override
  String sumConsentBlocked(String name) {
    return '$name : « non autorisé » — n’ajoutez aucune photo où il apparaît.';
  }

  @override
  String sumReach(int families, int guardians) {
    return 'Atteint $families familles ($guardians parents) · visible sur la page de la séance';
  }

  @override
  String get sumSend => 'Envoyer aux parents du groupe';

  @override
  String get sumSent => '✓ Envoyé aux parents';

  @override
  String sumSentToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Résumé envoyé à $count familles',
      one: 'Résumé envoyé à 1 famille',
    );
    return '$_temp0';
  }

  @override
  String get cancelSheetTitle => 'Annuler ou reporter la séance';

  @override
  String get cancelModeCancel => 'Annuler';

  @override
  String get cancelModeMove => 'Reporter';

  @override
  String get cancelNewSlot => 'Nouveau créneau';

  @override
  String get cancelPickSlot => 'Choisir le créneau';

  @override
  String get cancelReasonHint => 'Motif (visible par les parents)…';

  @override
  String cancelNotice(int guardians) {
    return '$guardians parents, les co-éducateurs et la direction sont prévenus. ⦿ Enregistré à votre nom.';
  }

  @override
  String get cancelCta => 'Annuler et prévenir tout le monde';

  @override
  String get moveCta => 'Reporter et prévenir tout le monde';

  @override
  String cancelledToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Séance annulée · $count personnes prévenues',
      one: 'Séance annulée · 1 personne prévenue',
    );
    return '$_temp0';
  }

  @override
  String movedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Séance reportée · $count personnes prévenues',
      one: 'Séance reportée · 1 personne prévenue',
    );
    return '$_temp0';
  }

  @override
  String get hwNewTitle => 'Nouveau devoir';

  @override
  String hwNewSubtitle(String day, String group) {
    return 'Lié à la séance de $day · $group';
  }

  @override
  String get hwInstructions => 'Consignes';

  @override
  String get hwInstructionsHint => 'Ce que l’enfant doit faire';

  @override
  String get hwTitleHint => 'ex. : réviser les versets 1–10';

  @override
  String get hwFor => 'Pour qui ?';

  @override
  String hwWholeGroup(int count) {
    return 'Tout le groupe ($count)';
  }

  @override
  String get hwSpecific => 'Enfants précis';

  @override
  String get hwDue => 'Pour le';

  @override
  String get hwReminderNote =>
      'Rappel automatique aux parents la veille si « fait » n’est pas coché.';

  @override
  String get hwAttachment => '+ pièce jointe (feuille, audio…)';

  @override
  String hwAttachmentAdded(String name) {
    return '✓ Joint : $name';
  }

  @override
  String hwSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoyer à $count enfants',
      one: 'Envoyer à 1 enfant',
      zero: 'Choisir les enfants',
    );
    return '$_temp0';
  }

  @override
  String get hwPickOne => 'Choisissez au moins un enfant';

  @override
  String get hwSentToast => 'Devoir envoyé aux parents';

  @override
  String get eduGroupsTitle => 'Mes groupes';

  @override
  String get eduGroupsSubtitle =>
      'Vous voyez seulement les enfants de vos groupes';

  @override
  String get eduGroupsEmpty => 'Aucun groupe ne vous est attribué';

  @override
  String get statAttendance => 'Présence';

  @override
  String get statHomework => 'Devoirs';

  @override
  String get statNext => 'Prochaine';

  @override
  String groupFlag(String name) {
    return '$name : 3 absences de suite — prendre des nouvelles';
  }

  @override
  String get eduGroupsFooter =>
      'Ajouter ou déplacer des enfants se fait via la direction.';

  @override
  String get grpTabHomework => 'Devoirs';

  @override
  String get grpTabStaff => 'Canal équipe';

  @override
  String rosterAttendance(int present, int expected) {
    return 'présence $present/$expected';
  }

  @override
  String get rosterNew => 'nouveau';

  @override
  String get rosterCare => '▲ 3 absences de suite — à suivre';

  @override
  String get hwStateOpen => 'En cours';

  @override
  String get hwStateClosed => 'Terminé';

  @override
  String hwListMeta(String target, String date) {
    return '$target · pour le $date';
  }

  @override
  String hwListMetaClosed(String target, String date) {
    return '$target · terminé le $date';
  }

  @override
  String hwTargetChildren(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enfants',
      one: '1 enfant',
    );
    return '$_temp0';
  }

  @override
  String get hwFooter =>
      'Fait = déclaré par les parents · aucun classement des enfants';

  @override
  String get hwEmpty => 'Pas encore de devoirs';

  @override
  String get staffChannelNote =>
      'Canal des éducateurs et de la direction — invisible aux parents.';

  @override
  String get staffChannelOpen => 'Ouvrir le canal équipe';

  @override
  String get staffChannelMissing => 'Pas encore de canal équipe pour ce groupe';

  @override
  String get guardianMessage => 'Écrire';

  @override
  String get guardianEmergency => 'urgence';

  @override
  String get guardianEmergencyHint => 'Numéro masqué · appel via l’application';

  @override
  String get guardianCall => '☏ Appeler';

  @override
  String get guardianCallToast =>
      'Appel via l’application — numéro masqué · ⦿ enregistré';

  @override
  String get guardianCallUnavailable => 'Aucun numéro pour ce parent';

  @override
  String get notesTitle => 'Notes';

  @override
  String get notesPhase2 => 'Phase 2';

  @override
  String get notesStaff => 'Équipe seulement';

  @override
  String get notesShared => 'Aux parents';

  @override
  String get notesStaffBody =>
      'Notes visibles par l’équipe seulement — arrivent en phase 2.';

  @override
  String get notesSharedBody =>
      'Notes envoyées aux parents — arrivent en phase 2.';

  @override
  String get eduChildHomeworkTile => 'Devoirs';

  @override
  String msgAvailability(String window) {
    return 'Disponible $window · en dehors, les messages arrivent en silence';
  }

  @override
  String get msgAvailabilityUnset =>
      'Heures de disponibilité non définies — via « Plus »';

  @override
  String msgSectionChildrenOf(String group) {
    return 'Enfants · $group';
  }

  @override
  String get msgSectionTeam => 'Équipe et direction';

  @override
  String get msgFooterEdu =>
      'Pas de conversation privée avec un enfant — chaque fil réunit les parents et les éducateurs du groupe.';

  @override
  String get quickReply1 => 'Bonjour, merci beaucoup';

  @override
  String get quickReply2 => 'Très bien aujourd’hui, bravo';

  @override
  String get quickReply3 => 'À la prochaine séance, inchallah';

  @override
  String get msgComposerHintEdu => 'Écrire un message…';

  @override
  String get eduMemSubtitle =>
      'Réservé aux parents de vos groupes · aucun partage externe';

  @override
  String get memNewPost => '+ publication';

  @override
  String get memMyPosts => 'Mes publications';

  @override
  String get memAlbumsTitle => 'Albums';

  @override
  String get memStatePending => 'En attente d’approbation';

  @override
  String get memStatePublished => 'Publié';

  @override
  String get memStateEdit => 'Modification demandée';

  @override
  String memMediaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String memTaggedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tagués',
      one: '1 tagué',
      zero: 'aucun tag',
    );
    return '$_temp0';
  }

  @override
  String get memMyPostsEmpty =>
      'Rien de publié — ajoutez le premier souvenir de votre groupe.';

  @override
  String memPostsInAlbum(int count) {
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
  String get memComposeTitle => 'Nouvelle publication';

  @override
  String get memComposeSubtitle => 'Soumis à la direction avant publication';

  @override
  String get memComposeSubtitleLive =>
      'Publié immédiatement aux parents du groupe';

  @override
  String get memAlbumLabel => 'Album';

  @override
  String get memAudienceLabel => 'Public';

  @override
  String memAudienceOf(String group) {
    return 'Parents de $group';
  }

  @override
  String get memAudienceAll => 'Tous les parents';

  @override
  String get memPickAlbum => 'Choisir un album';

  @override
  String get memCaptionHint => 'Une courte légende…';

  @override
  String get memTagTitle => 'Taguer les enfants visibles';

  @override
  String memTagCount(int count) {
    return '$count tagué(s)';
  }

  @override
  String memBlocked(String name) {
    return '⊘ Impossible de taguer $name — droit à l’image « non autorisé ». S’il apparaît sur une photo, retirez-la avant de publier.';
  }

  @override
  String get memSubmit => 'Envoyer pour approbation';

  @override
  String get memPublish => 'Publier';

  @override
  String get memSubmittedToast => 'Envoyé à la direction pour approbation';

  @override
  String get memPublishedToast => 'Publié aux parents du groupe';

  @override
  String get memNeedMedia => 'Ajoutez au moins une photo';

  @override
  String get memUploading => 'Envoi…';

  @override
  String get memConsentBlockedToast =>
      'Retirez les enfants non autorisés avant de publier';

  @override
  String get memRemovePhoto => 'Retirer la photo';

  @override
  String get annEduTitle => 'Annonce à mes groupes';

  @override
  String get annToGuardians => 'Aux parents de';

  @override
  String annReachGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Atteint $count parents + les co-éducateurs',
      one: 'Atteint 1 parent + les co-éducateurs',
      zero: 'Personne',
    );
    return '$_temp0';
  }

  @override
  String get annPickGroup => 'Choisissez au moins un groupe';

  @override
  String get annAckTitle => 'Demander « j’ai lu »';

  @override
  String get annAckBody => 'Vous voyez qui a confirmé et qui non';

  @override
  String get annUrgentExecOnly =>
      'Les annonces urgentes (SMS) sont réservées à la direction.';

  @override
  String get annPublishCta => 'Publier';

  @override
  String annPublishedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Annonce publiée à $count parents',
      one: 'Annonce publiée à 1 parent',
      zero: 'Annonce publiée',
    );
    return '$_temp0';
  }

  @override
  String moreEduRole(String groups) {
    return 'Éducateur · $groups';
  }

  @override
  String get availTitle => 'Heures de disponibilité';

  @override
  String get availBody =>
      'En dehors, les messages des parents arrivent en silence, avec le numéro de l’association pour les urgences.';

  @override
  String get availSavedToast => 'Disponibilité enregistrée';

  @override
  String get attReminderRow => 'Rappel d’appel';

  @override
  String get attReminderLocked => 'après 30 min · verrouillé';

  @override
  String get offlineAttendanceBanner =>
      '⦸ Hors ligne — l’appel est gardé sur le téléphone et synchronisé au retour du réseau.';

  @override
  String get notAvailableToYou => 'Non disponible pour vous';
}

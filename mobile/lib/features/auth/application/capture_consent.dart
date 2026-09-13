import '../../../core/session/session_controller.dart';
import '../domain/consent.dart';
import '../domain/consent_repository.dart';

/// Records the consents `ACC-06` blocks on, then unlocks the app.
///
/// Two rules live here rather than in the screen, because a screen is the
/// easiest place for a safeguarding rule to be lost in a redesign:
///
/// * **Every displayed child is submitted**, at the level shown. A child the
///   guardian never touched is sent at [ImageRightsLevel.mostRestrictive] —
///   explicitly, as a `consent_record` row — because "answered: not allowed"
///   and "never asked" must be distinguishable in an append-only log that
///   `AUD-02` and the Memories Wall's re-check job both read.
/// * **The session is unlocked only after the server has accepted the write.**
///   Calling `onConsentCompleted()` optimistically would let a guardian into
///   the app while `consent_record` still says they consented to nothing, and
///   the Memories Wall would be making publish decisions against that gap.
class CaptureConsent {
  const CaptureConsent({
    required ConsentRepository repository,
    required SessionController session,
  }) : _repository = repository,
       _session = session;

  final ConsentRepository _repository;
  final SessionController _session;

  /// Submits [submission] for the children in [requirement].
  ///
  /// Throws `StateError` if the privacy policy was not accepted — the submit
  /// button is disabled until it is, and sending an unaccepted policy would
  /// write a row claiming otherwise.
  Future<void> call({
    required ConsentRequirement requirement,
    required ConsentSubmission submission,
  }) async {
    if (!submission.isComplete) {
      throw StateError(
        'The privacy policy must be accepted before consent can be recorded '
        '(ACC-06).',
      );
    }

    await _repository.submit(
      ConsentSubmission(
        privacyPolicyAccepted: true,
        imageRights: {
          for (final child in requirement.children)
            child.id:
                submission.imageRights[child.id] ??
                ImageRightsLevel.mostRestrictive,
        },
      ),
    );

    _session.onConsentCompleted();
  }
}

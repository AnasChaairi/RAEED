import 'consent.dart';

/// Reads and records the consents `ACC-06` blocks on.
///
/// Both calls are audit-logged server-side — `specs/04-api/conventions.md`
/// requires an `audit_log_entry` on every write to `consent_record` — so the
/// client's job is only to present the choice accurately and send exactly what
/// the guardian chose.
abstract interface class ConsentRepository {
  /// Loads what is still outstanding for the signed-in user.
  Future<ConsentRequirement> loadRequirement();

  /// Records the privacy-policy acceptance and the per-child image-rights
  /// levels.
  ///
  /// Writes are append-only server-side: this creates new `consent_record`
  /// rows rather than updating the previous ones, so the full history survives
  /// for `AUD-02` and for the Memories Wall's re-check-on-downgrade job.
  Future<void> submit(ConsentSubmission submission);
}

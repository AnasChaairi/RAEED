import '../../../core/network/api_envelope.dart';
import 'announcement_draft.dart';

/// Reads and publishes announcements for the executive.
///
/// Publishing is `POST /announcements` (`specs/04-api/openapi.yaml`);
/// executives may target any audience, which the server checks against the
/// caller's roles (`ANN-03`), not the client.
abstract interface class ExecutiveAnnouncementsRepository {
  Future<Paginated<ExecutiveAnnouncement>> fetchAnnouncements({String? cursor});

  /// How many people each audience reaches right now.
  ///
  /// Proposed as `GET /announcements/reach`; not yet in the contract.
  Future<AudienceReach> fetchReach();

  /// Publishes [draft] and returns the new announcement's id.
  Future<String> publish(AnnouncementDraft draft);
}

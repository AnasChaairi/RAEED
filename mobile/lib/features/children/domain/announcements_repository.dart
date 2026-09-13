import '../../../core/network/api_envelope.dart';
import 'announcement.dart';

/// Reads the announcements the caller may see.
///
/// Read-only on purpose: publishing is Epic E's composer, and a repository
/// that cannot write is a repository no screen can accidentally publish from.
abstract interface class AnnouncementsRepository {
  /// One page of visible announcements, newest first as the server orders them.
  Future<Paginated<Announcement>> fetchAnnouncements({String? cursor});
}

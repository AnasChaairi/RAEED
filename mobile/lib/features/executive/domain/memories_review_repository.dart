import 'memories_review.dart';

/// The Memories Wall moderation queue.
///
/// Proposed paths (Epic F), not yet in `specs/04-api/openapi.yaml`.
abstract interface class MemoriesReviewRepository {
  Future<ReviewQueue> fetchQueue();

  Future<List<MemoriesAlbum>> fetchAlbums();

  /// Publishes a pending post, or re-publishes a blocked one after the
  /// offending media was removed. The server re-checks every tag's consent
  /// at this moment (`WAL-06`), so a stale client cannot approve past it.
  Future<void> approve(String postId);

  /// Hides a post. Never a deletion.
  Future<void> hide(String postId);
}

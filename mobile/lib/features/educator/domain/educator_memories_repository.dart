import 'memory_post.dart';

/// The educator's own posts and uploads (EDU-M-08).
abstract interface class EducatorMemoriesRepository {
  Future<List<MyPost>> fetchMyPosts();

  /// Refused with `memories.consent_blocked` naming any `not_allowed` child.
  Future<MyPost> createPost(PostDraft draft);

  /// Uploads a file from the device; the key is what posts and materials store.
  Future<MediaUpload> upload(String filePath, {String? contentType});
}

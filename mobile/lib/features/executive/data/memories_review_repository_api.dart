import '../../../core/network/api_client.dart';
import '../domain/memories_review.dart';
import '../domain/memories_review_repository.dart';
import 'memories_review_dto.dart';

/// [MemoriesReviewRepository] against the proposed Epic F paths.
class ApiMemoriesReviewRepository implements MemoriesReviewRepository {
  const ApiMemoriesReviewRepository(this._client);

  final ApiClient _client;

  @override
  Future<ReviewQueue> fetchQueue() async =>
      reviewQueueFromJson(await _client.getObject('/memories/review-queue'));

  @override
  Future<List<MemoriesAlbum>> fetchAlbums() async {
    final page = await _client.getList<MemoriesAlbum>(
      '/memories/albums',
      memoriesAlbumFromJson,
    );
    return page.items;
  }

  @override
  Future<void> approve(String postId) =>
      _client.post('/memories/posts/$postId/approve');

  @override
  Future<void> hide(String postId) =>
      _client.post('/memories/posts/$postId/hide');
}

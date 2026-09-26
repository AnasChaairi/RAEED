import '../../../core/network/api_client.dart';
import '../domain/educator_memories_repository.dart';
import '../domain/memory_post.dart';
import 'educator_dto.dart';

class ApiEducatorMemoriesRepository implements EducatorMemoriesRepository {
  const ApiEducatorMemoriesRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<MyPost>> fetchMyPosts() async {
    final page = await _client.getList<MyPost>(
      '/memories/posts',
      myPostFromJson,
      query: const {'mine': 'true'},
    );
    return page.items;
  }

  @override
  Future<MyPost> createPost(PostDraft draft) async => myPostFromJson(
    await _client.post(
      '/memories/posts',
      body: {
        'album_id': draft.albumId,
        'caption': draft.caption.trim().isEmpty ? null : draft.caption.trim(),
        'media': [
          for (final upload in draft.media)
            {
              'storage_key': upload.storageKey,
              'media_kind': upload.kind == MediaKind.video ? 'video' : 'photo',
            },
        ],
        'tagged_child_ids': draft.taggedChildIds.toList(),
      },
    ),
  );

  @override
  Future<MediaUpload> upload(String filePath, {String? contentType}) async =>
      mediaUploadFromJson(
        await _client.postFile(
          '/media',
          filePath: filePath,
          contentType: contentType,
        ),
      );
}

/// The educator's Memories Wall (EDU-M-08).
library;

import 'package:meta/meta.dart';

enum PostState { pending, published, editRequested }

@immutable
class MyPost {
  const MyPost({
    required this.id,
    required this.albumTitle,
    required this.mediaCount,
    required this.tagCount,
    required this.createdAt,
    required this.state,
    this.albumGroupName,
    this.caption,
    this.thumbnailUrl,
  });

  final String id;
  final String albumTitle;
  final String? albumGroupName;
  final String? caption;
  final int mediaCount;
  final String? thumbnailUrl;
  final int tagCount;
  final DateTime createdAt;
  final PostState state;
}

enum MediaKind { image, audio, video, document }

/// What `POST /media` returns.
@immutable
class MediaUpload {
  const MediaUpload({
    required this.storageKey,
    required this.url,
    required this.kind,
    required this.name,
    required this.sizeBytes,
  });

  final String storageKey;
  final String url;
  final MediaKind kind;
  final String name;
  final int sizeBytes;
}

@immutable
class PostDraft {
  const PostDraft({
    this.albumId,
    this.caption = '',
    this.media = const [],
    this.taggedChildIds = const {},
  });

  final String? albumId;
  final String caption;
  final List<MediaUpload> media;
  final Set<String> taggedChildIds;

  bool get isComplete => albumId != null && media.isNotEmpty;

  PostDraft copyWith({
    String? albumId,
    String? caption,
    List<MediaUpload>? media,
    Set<String>? taggedChildIds,
  }) => PostDraft(
    albumId: albumId ?? this.albumId,
    caption: caption ?? this.caption,
    media: media ?? this.media,
    taggedChildIds: taggedChildIds ?? this.taggedChildIds,
  );
}

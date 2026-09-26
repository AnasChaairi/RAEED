import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { randomUUID } from 'node:crypto';
import { createReadStream, promises as fs } from 'node:fs';
import { extname, join, resolve } from 'node:path';
import { Readable } from 'node:stream';
import { DataSource } from 'typeorm';

import { AuthenticatedUser } from '../../common/abilities/authenticated-user';
import { loadConfig } from '../../common/config/env';
import { ApiError } from '../../common/http/api-error';

/** What multer hands a controller; typed here so no external types are needed. */
export interface UploadedFileLike {
  readonly originalname: string;
  readonly mimetype: string;
  readonly size: number;
  readonly buffer: Buffer;
}

export type MediaKind = 'image' | 'audio' | 'video' | 'document';

export interface MediaView {
  storage_key: string;
  url: string;
  kind: MediaKind;
  name: string;
  size_bytes: number;
  content_type: string;
}

/** 50 MB, the design's own ceiling ("video ≤ 50 MB · long ones as a link"). */
export const MAX_UPLOAD_BYTES = 50 * 1024 * 1024;

const KIND_BY_PREFIX: Array<[string, MediaKind]> = [
  ['image/', 'image'],
  ['audio/', 'audio'],
  ['video/', 'video'],
];
const DOCUMENT_TYPES = new Set([
  'application/pdf',
  'text/plain',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
]);

/**
 * The local-disk `StorageProvider` (`specs/07-backend-spec.md`).
 *
 * Files live under `STORAGE_LOCAL_ROOT`, named by a random key with the
 * original extension, and are served back only to signed-in users. The
 * key is what the rest of the schema stores (`material.storage_key`,
 * `post.media_json`); the OVH driver will map the same keys to object
 * storage without any caller changing.
 */
@Injectable()
export class MediaService {
  private readonly root = resolve(loadConfig().storage.localRoot);

  constructor(@InjectDataSource() private readonly dataSource: DataSource) {}

  async store(user: AuthenticatedUser, file: UploadedFileLike): Promise<MediaView> {
    const kind = this.kindOf(file.mimetype);
    if (!kind) {
      throw ApiError.validationFailed({ file: 'unsupported content type' });
    }
    if (file.size > MAX_UPLOAD_BYTES) {
      throw ApiError.validationFailed({ file: 'larger than 50 MB' });
    }

    const key = `${user.id.slice(0, 8)}/${randomUUID()}${this.safeExtension(file.originalname)}`;
    const path = join(this.root, key);
    await fs.mkdir(join(this.root, key.split('/')[0]), { recursive: true });
    await fs.writeFile(path, file.buffer);

    // Every upload is attributable: the file is a child's photo more often
    // than not, and the retention purge needs to know who put it there.
    await this.dataSource.query(
      `insert into audit_log_entry (actor_user_id, action, resource_type, resource_id, device_meta)
       values ($1, 'media.upload', 'media', null, $2::jsonb)`,
      [
        user.id,
        JSON.stringify({ storage_key: key, kind, size_bytes: file.size, content_type: file.mimetype }),
      ],
    );

    return {
      storage_key: key,
      url: MediaService.urlFor(key),
      kind,
      name: file.originalname,
      size_bytes: file.size,
      content_type: file.mimetype,
    };
  }

  /** Opens the stored file, refusing any key that would leave the root. */
  async open(key: string): Promise<{ stream: Readable; contentType: string }> {
    const path = resolve(this.root, key);
    if (!path.startsWith(this.root + '/') || key.includes('..')) {
      throw ApiError.scopeForbidden('No such file.');
    }
    try {
      await fs.access(path);
    } catch {
      throw ApiError.scopeForbidden('No such file.');
    }
    return { stream: createReadStream(path), contentType: contentTypeOf(path) };
  }

  static urlFor(key: string): string {
    return `/api/v1/media/${key}`;
  }

  private kindOf(mimetype: string): MediaKind | null {
    for (const [prefix, kind] of KIND_BY_PREFIX) {
      if (mimetype.startsWith(prefix)) return kind;
    }
    return DOCUMENT_TYPES.has(mimetype) ? 'document' : null;
  }

  private safeExtension(name: string): string {
    const ext = extname(name).toLowerCase();
    return /^\.[a-z0-9]{1,5}$/.test(ext) ? ext : '';
  }
}

function contentTypeOf(path: string): string {
  switch (extname(path).toLowerCase()) {
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.png':
      return 'image/png';
    case '.webp':
      return 'image/webp';
    case '.gif':
      return 'image/gif';
    case '.mp4':
      return 'video/mp4';
    case '.m4a':
      return 'audio/mp4';
    case '.mp3':
      return 'audio/mpeg';
    case '.aac':
      return 'audio/aac';
    case '.ogg':
      return 'audio/ogg';
    case '.pdf':
      return 'application/pdf';
    case '.txt':
      return 'text/plain';
    default:
      return 'application/octet-stream';
  }
}

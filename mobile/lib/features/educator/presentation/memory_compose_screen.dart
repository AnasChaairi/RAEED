import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/error/api_error_code.dart';
import '../../../core/error/raeed_exception.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../executive/domain/executive_group.dart';
import '../../executive/domain/memories_review.dart';
import '../../executive/presentation/executive_providers.dart';
import '../../executive/presentation/widgets/executive_card.dart';
import '../../executive/presentation/widgets/image_rights_dot.dart';
import '../domain/educator_group.dart';
import '../domain/memory_post.dart';
import 'educator_providers.dart';
import 'widgets/media_thumbnail.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-08 — a new post: photos, album, caption, and the tags checked
/// against each child's image rights before the server checks them again.
class MemoryComposeScreen extends ConsumerStatefulWidget {
  const MemoryComposeScreen({this.picker, super.key});

  final Future<String?> Function(ImageSource source)? picker;

  @override
  ConsumerState<MemoryComposeScreen> createState() =>
      _MemoryComposeScreenState();
}

class _MemoryComposeScreenState extends ConsumerState<MemoryComposeScreen> {
  PostDraft _draft = const PostDraft();
  String? _blockedName;
  bool _uploading = false;
  bool _sending = false;

  MemoriesAlbum? _album(List<MemoriesAlbum> albums) =>
      albums.where((album) => album.id == _draft.albumId).firstOrNull;

  Future<void> _addPhoto() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final path = widget.picker != null
        ? await widget.picker!(ImageSource.gallery)
        : (await ImagePicker().pickImage(
            source: ImageSource.gallery,
            maxWidth: 1600,
            imageQuality: 85,
          ))?.path;
    if (path == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      final upload = await ref
          .read(educatorMemoriesRepositoryProvider)
          .upload(path);
      if (mounted) {
        setState(
          () => _draft = _draft.copyWith(media: [..._draft.media, upload]),
        );
      }
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(presentFailure(error, l10n).body)),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _toggle(RosterChild child) {
    if (!child.canBeTagged) {
      setState(() => _blockedName = child.fullName);
      return;
    }
    setState(() {
      final next = Set<String>.of(_draft.taggedChildIds);
      if (!next.remove(child.id)) next.add(child.id);
      _draft = _draft.copyWith(taggedChildIds: next);
      _blockedName = null;
    });
  }

  Future<void> _submit(bool publishesAtOnce) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    if (_draft.media.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.memNeedMedia)));
      return;
    }
    if (!_draft.isComplete || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(educatorMemoriesRepositoryProvider).createPost(_draft);
      ref.invalidate(myPostsProvider);
      ref.invalidate(memoriesAlbumsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            publishesAtOnce ? l10n.memPublishedToast : l10n.memSubmittedToast,
          ),
        ),
      );
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(AppRoutes.homeTabPath('memories'));
      }
    } catch (error) {
      if (!mounted) return;
      if (error is ApiException &&
          error.code == ApiErrorCode.memoriesConsentBlocked) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.memConsentBlockedToast)),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(presentFailure(error, l10n).body)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final albums =
        ref.watch(memoriesAlbumsProvider).value ?? const <MemoriesAlbum>[];
    final groups =
        ref.watch(executiveGroupsProvider).value ?? const <ExecutiveGroup>[];
    final album = _album(albums);
    final group = album == null
        ? null
        : groups.where((g) => g.name == album.groupName).firstOrNull;
    final roster = group == null
        ? null
        : ref.watch(educatorRosterProvider(group.id)).value;
    final publishesAtOnce =
        album?.moderationMode == ModerationMode.publishThenModerate;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            EducatorPageHeader(
              title: l10n.memComposeTitle,
              subtitle: publishesAtOnce
                  ? l10n.memComposeSubtitleLive
                  : l10n.memComposeSubtitle,
              fallbackRoute: AppRoutes.homeTabPath('memories'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(RaeedSpacing.lg),
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final upload in _draft.media)
                        MediaThumbnail(
                          url: upload.url,
                          size: 78,
                          onRemove: () => setState(
                            () => _draft = _draft.copyWith(
                              media: _draft.media
                                  .where((m) => m != upload)
                                  .toList(),
                            ),
                          ),
                        ),
                      Semantics(
                        button: true,
                        label: l10n.addPhoto,
                        child: Material(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              RaeedRadius.md + 2,
                            ),
                            side: BorderSide(color: palette.border, width: 1.5),
                          ),
                          child: InkWell(
                            onTap: _uploading ? null : _addPhoto,
                            borderRadius: BorderRadius.circular(
                              RaeedRadius.md + 2,
                            ),
                            child: SizedBox(
                              width: 78,
                              height: 78,
                              child: Center(
                                child: _uploading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        Icons.add_rounded,
                                        color: palette.primary,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  Row(
                    children: [
                      Expanded(
                        child: ExecutiveCard(
                          radius: RaeedRadius.lg,
                          padding: const EdgeInsets.symmetric(
                            horizontal: RaeedSpacing.md,
                            vertical: RaeedSpacing.xs,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _draft.albumId,
                              isExpanded: true,
                              isDense: true,
                              hint: Text(
                                l10n.memPickAlbum,
                                style: context.type.caption.copyWith(
                                  color: palette.inkDim,
                                ),
                              ),
                              items: [
                                for (final candidate in albums)
                                  DropdownMenuItem(
                                    value: candidate.id,
                                    child: Text(
                                      candidate.title,
                                      style: context.type.label.copyWith(
                                        color: palette.ink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                              onChanged: (id) => setState(
                                () => _draft = _draft.copyWith(
                                  albumId: id,
                                  taggedChildIds: {},
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: RaeedSpacing.sm),
                      Expanded(
                        child: ExecutiveCard(
                          radius: RaeedRadius.lg,
                          padding: const EdgeInsets.symmetric(
                            horizontal: RaeedSpacing.md,
                            vertical: RaeedSpacing.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.memAudienceLabel,
                                style: context.type.caption.copyWith(
                                  color: palette.inkDim,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                album == null
                                    ? '—'
                                    : album.groupName == null
                                    ? l10n.memAudienceAll
                                    : l10n.memAudienceOf(album.groupName!),
                                style: context.type.label.copyWith(
                                  color: palette.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  TextField(
                    onChanged: (value) => setState(
                      () => _draft = _draft.copyWith(caption: value),
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.memCaptionHint,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  Row(
                    children: [
                      Expanded(child: FieldLabel(l10n.memTagTitle)),
                      Text(
                        l10n.memTagCount(_draft.taggedChildIds.length),
                        style: context.type
                            .tabular(context.type.caption)
                            .copyWith(
                              color: palette.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  if (_blockedName != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: RaeedSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: RaeedSpacing.md,
                        vertical: RaeedSpacing.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: palette.dangerSoft,
                        borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
                      ),
                      child: Text(
                        l10n.memBlocked(_blockedName!),
                        style: context.type.caption.copyWith(
                          color: palette.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (roster == null)
                    Text(
                      l10n.memPickAlbum,
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                      ),
                    )
                  else
                    for (final child in roster) ...[
                      _TagRow(
                        child: child,
                        selected: _draft.taggedChildIds.contains(child.id),
                        onTap: () => _toggle(child),
                      ),
                      const SizedBox(height: 6),
                    ],
                ],
              ),
            ),
            BottomActionBar(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _sending || _uploading
                    ? null
                    : () => _submit(publishesAtOnce),
                child: Text(publishesAtOnce ? l10n.memPublish : l10n.memSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final RosterChild child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final blocked = !child.canBeTagged;
    final color = ImageRightsDot.color(context, child.imageRights);
    return Semantics(
      button: true,
      selected: selected,
      label: child.fullName,
      child: Opacity(
        opacity: blocked ? 0.75 : 1,
        child: Material(
          color: selected ? palette.primarySoft : palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
            side: BorderSide(
              color: selected
                  ? palette.primary
                  : blocked
                  ? palette.danger
                  : palette.border,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: RaeedTouchTarget.minPx,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RaeedSpacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: selected ? palette.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: selected ? palette.primary : palette.inkDim,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: palette.primaryOn,
                            )
                          : null,
                    ),
                    const SizedBox(width: RaeedSpacing.sm + 2),
                    Expanded(
                      child: ExcludeSemantics(
                        child: Text(
                          child.fullName,
                          style: context.type.label.copyWith(
                            color: palette.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    ExcludeSemantics(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageRightsDot(level: child.imageRights, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            ImageRightsDot.label(l10n, child.imageRights),
                            style: context.type.caption.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

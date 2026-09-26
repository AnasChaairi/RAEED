import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';
import '../domain/educator_group.dart';
import '../domain/memory_post.dart';
import 'educator_providers.dart';
import 'widgets/media_thumbnail.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-04 — "what we did today", sent once to the group's guardians.
class SessionSummaryScreen extends ConsumerStatefulWidget {
  const SessionSummaryScreen({required this.sessionId, this.picker, super.key});

  final String sessionId;
  final Future<String?> Function(ImageSource source)? picker;

  @override
  ConsumerState<SessionSummaryScreen> createState() =>
      _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends ConsumerState<SessionSummaryScreen> {
  final _body = TextEditingController();
  final List<MediaUpload> _photos = [];
  bool _sending = false;
  bool _sent = false;
  bool _uploading = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

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
      if (mounted) setState(() => _photos.add(upload));
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

  Future<void> _send() async {
    if (_sent || _sending || _body.text.trim().isEmpty) return;
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      final result = await ref
          .read(sessionsRepositoryProvider)
          .sendSummary(
            widget.sessionId,
            body: _body.text,
            mediaKeys: _photos.map((photo) => photo.storageKey).toList(),
          );
      ref.invalidate(sessionDetailProvider(widget.sessionId));
      ref.invalidate(todayControllerProvider);
      if (!mounted) return;
      setState(() => _sent = true);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sumSentToast(result.familyCount))),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final detail = ref.watch(sessionDetailProvider(widget.sessionId));
    final roster = detail.value == null
        ? null
        : ref.watch(educatorRosterProvider(detail.value!.item.group.id)).value;
    final blocked =
        roster
            ?.where((child) => child.imageRights == ImageRightsLevel.notAllowed)
            .toList() ??
        const <RosterChild>[];
    final alreadySent = detail.value?.summarySentAt != null;
    final done = _sent || alreadySent;
    if (alreadySent && _body.text.isEmpty && detail.value?.summary != null) {
      _body.text = detail.value!.summary!;
    }

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            EducatorPageHeader(
              title: l10n.sumTitle,
              subtitle: detail.value == null
                  ? null
                  : l10n.sumSubtitle(detail.value!.item.group.name),
              fallbackRoute: AppRoutes.sessionPath(widget.sessionId),
            ),
            Expanded(
              child: detail.when(
                loading: () => const SkeletonCardList(count: 2, height: 120),
                error: (error, _) => RaeedErrorView(
                  error: error,
                  onRetry: () =>
                      ref.invalidate(sessionDetailProvider(widget.sessionId)),
                ),
                data: (data) => ListView(
                  padding: const EdgeInsets.all(RaeedSpacing.lg),
                  children: [
                    TextField(
                      controller: _body,
                      readOnly: done,
                      minLines: 5,
                      maxLines: 12,
                      decoration: InputDecoration(hintText: l10n.sumHint),
                    ),
                    const SizedBox(height: RaeedSpacing.sm + 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final photo in _photos)
                          MediaThumbnail(url: photo.url, size: 96),
                        if (!done)
                          _AddPhotoTile(
                            onTap: _uploading ? null : _addPhoto,
                            uploading: _uploading,
                          ),
                      ],
                    ),
                    const SizedBox(height: RaeedSpacing.sm + 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RaeedSpacing.md,
                        vertical: RaeedSpacing.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: palette.accentSoft,
                        borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: l10n.sumConsentNote),
                            for (final child in blocked)
                              TextSpan(
                                text:
                                    ' ${l10n.sumConsentBlocked(child.fullName)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                        style: context.type.caption.copyWith(
                          color: palette.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.sm),
                    Text(
                      l10n.sumReach(data.familyCount, data.guardianCount),
                      style: context.type
                          .tabular(context.type.caption)
                          .copyWith(color: palette.inkDim),
                    ),
                  ],
                ),
              ),
            ),
            BottomActionBar(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: done ? palette.successSoft : null,
                  foregroundColor: done ? palette.success : null,
                ),
                onPressed: done || _sending ? null : _send,
                child: Text(done ? l10n.sumSent : l10n.sumSend),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap, required this.uploading});

  final VoidCallback? onTap;
  final bool uploading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return Semantics(
      button: true,
      label: l10n.addPhoto,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
          side: BorderSide(color: palette.border, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
          child: SizedBox(
            width: 96,
            height: 96,
            child: Center(
              child: uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.addPhoto,
                      style: context.type.caption.copyWith(
                        color: palette.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

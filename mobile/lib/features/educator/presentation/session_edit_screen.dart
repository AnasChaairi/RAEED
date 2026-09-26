import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../../executive/presentation/announcements_tab.dart' show FilterPill;
import '../../executive/presentation/relative_time.dart';
import '../../executive/presentation/widgets/executive_card.dart';
import '../../executive/presentation/widgets/executive_skeletons.dart';
import '../domain/educator_session.dart';
import '../domain/memory_post.dart';
import 'educator_providers.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-04 — the content of a generated session: title, theme, objectives,
/// materials with who may see each.
class SessionEditScreen extends ConsumerStatefulWidget {
  const SessionEditScreen({required this.sessionId, this.picker, super.key});

  final String sessionId;

  /// Injectable so tests never open the system picker.
  final Future<String?> Function(ImageSource source)? picker;

  @override
  ConsumerState<SessionEditScreen> createState() => _SessionEditScreenState();
}

class _SessionEditScreenState extends ConsumerState<SessionEditScreen> {
  SessionContentDraft? _draft;
  List<SessionMaterial> _materials = const [];
  bool _saving = false;
  bool _uploading = false;

  static const List<String> _themes = [
    'quran',
    'sira',
    'akhlaq',
    'hadith',
    'skills',
  ];

  static String themeLabel(AppL10n l10n, String theme) => switch (theme) {
    'quran' => l10n.themeQuran,
    'sira' => l10n.themeSira,
    'akhlaq' => l10n.themeAkhlaq,
    'hadith' => l10n.themeHadith,
    'skills' => l10n.themeSkills,
    _ => theme,
  };

  void _seed(SessionDetail detail) {
    if (_draft != null) return;
    _draft = SessionContentDraft.fromDetail(detail);
    _materials = detail.materials;
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(sessionsRepositoryProvider)
          .updateContent(widget.sessionId, draft);
      ref.invalidate(sessionDetailProvider(widget.sessionId));
      ref.invalidate(weekSessionsProvider);
      ref.invalidate(todayControllerProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.sessContentSaved)));
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(AppRoutes.sessionPath(widget.sessionId));
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<String?> _pickFile(ImageSource source) async {
    if (widget.picker != null) return widget.picker!(source);
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    return file?.path;
  }

  Future<void> _addUpload(MaterialKind kind) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final path = await _pickFile(ImageSource.gallery);
    if (path == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      final upload = await ref
          .read(educatorMemoriesRepositoryProvider)
          .upload(path);
      final material = await ref
          .read(sessionsRepositoryProvider)
          .addMaterial(
            widget.sessionId,
            kind: switch (upload.kind) {
              MediaKind.image => MaterialKind.image,
              MediaKind.audio => MaterialKind.audio,
              MediaKind.video => MaterialKind.video,
              MediaKind.document => MaterialKind.document,
            },
            storageKey: upload.storageKey,
            title: upload.name,
            sizeBytes: upload.sizeBytes,
          );
      if (!mounted) return;
      setState(() {
        _materials = [..._materials, material];
        _draft = _draft!.copyWith(
          visibility: {..._draft!.visibility, material.id: material.visibility},
        );
      });
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _addLink() async {
    final l10n = AppL10n.of(context);
    final url = TextEditingController();
    final title = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addLink),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: url,
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(hintText: l10n.linkUrlHint),
            ),
            const SizedBox(height: RaeedSpacing.sm),
            TextField(
              controller: title,
              decoration: InputDecoration(hintText: l10n.linkTitleHint),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.linkAdd),
          ),
        ],
      ),
    );
    if (ok != true || url.text.trim().isEmpty || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final material = await ref
          .read(sessionsRepositoryProvider)
          .addMaterial(
            widget.sessionId,
            kind: MaterialKind.link,
            storageKey: url.text.trim(),
            title: title.text.trim().isEmpty ? null : title.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _materials = [..._materials, material];
        _draft = _draft!.copyWith(
          visibility: {..._draft!.visibility, material.id: material.visibility},
        );
      });
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }

  Future<void> _remove(SessionMaterial material) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(sessionsRepositoryProvider).removeMaterial(material.id);
      if (!mounted) return;
      setState(
        () =>
            _materials = _materials.where((m) => m.id != material.id).toList(),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final detail = ref.watch(sessionDetailProvider(widget.sessionId));

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: detail.when(
          loading: () => Column(
            children: [
              EducatorPageHeader(title: l10n.sessContentTitle),
              const Expanded(child: SkeletonCardList(count: 3, height: 80)),
            ],
          ),
          error: (error, _) => Column(
            children: [
              EducatorPageHeader(title: l10n.sessContentTitle),
              Expanded(
                child: RaeedErrorView(
                  error: error,
                  onRetry: () =>
                      ref.invalidate(sessionDetailProvider(widget.sessionId)),
                ),
              ),
            ],
          ),
          data: (data) {
            _seed(data);
            final draft = _draft!;
            return Column(
              children: [
                EducatorPageHeader(
                  title: l10n.sessContentTitle,
                  subtitle: l10n.sessContentSubtitle(
                    data.item.group.name,
                    '${dayAndMonth(locale, data.item.startsAt)} ${clockTime(locale, data.item.startsAt)}',
                  ),
                  fallbackRoute: AppRoutes.sessionPath(widget.sessionId),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(RaeedSpacing.lg),
                    children: [
                      FieldLabel(l10n.annFieldTitle),
                      TextFormField(
                        initialValue: draft.title,
                        onChanged: (value) => setState(
                          () => _draft = draft.copyWith(title: value),
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.sessTitleHint,
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: RaeedSpacing.md),
                      FieldLabel(l10n.sessTheme),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final theme in _themes)
                            FilterPill(
                              label: themeLabel(l10n, theme),
                              selected:
                                  draft.theme == theme ||
                                  draft.theme == themeLabel(l10n, theme),
                              onTap: () => setState(
                                () => _draft = draft.copyWith(
                                  theme: themeLabel(l10n, theme),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: RaeedSpacing.md),
                      FieldLabel(l10n.sessObjectives),
                      TextFormField(
                        initialValue: draft.objectives,
                        onChanged: (value) => setState(
                          () => _draft = draft.copyWith(objectives: value),
                        ),
                        minLines: 3,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: l10n.sessObjectivesHint,
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: RaeedSpacing.md),
                      Row(
                        children: [
                          Expanded(child: FieldLabel(l10n.sessMaterialsWho)),
                          Text(
                            l10n.sessVideoLimit,
                            style: context.type.caption.copyWith(
                              color: palette.inkDim,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                      for (final material in _materials) ...[
                        ExecutiveCard(
                          radius: RaeedRadius.lg,
                          padding: const EdgeInsets.symmetric(
                            horizontal: RaeedSpacing.md,
                            vertical: RaeedSpacing.sm + 2,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  MaterialKindTile(
                                    kind: material.kind,
                                    size: 32,
                                  ),
                                  const SizedBox(width: RaeedSpacing.sm + 2),
                                  Expanded(
                                    child: Text(
                                      material.title ??
                                          material.storageKey.split('/').last,
                                      style: context.type.label.copyWith(
                                        color: palette.ink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: l10n.remove,
                                    onPressed: () => _remove(material),
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: palette.inkDim,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: RaeedSpacing.sm),
                              SegmentedChoice<MaterialVisibility>(
                                values: MaterialVisibility.values,
                                selected:
                                    draft.visibility[material.id] ??
                                    material.visibility,
                                labelOf: (visibility) =>
                                    visibilityLabel(l10n, visibility),
                                onSelect: (visibility) => setState(
                                  () => _draft = draft.copyWith(
                                    visibility: {
                                      ...draft.visibility,
                                      material.id: visibility,
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: RaeedSpacing.sm),
                      ],
                      Row(
                        children: [
                          _AddButton(
                            label: l10n.addFile,
                            onTap: _uploading
                                ? null
                                : () => _addUpload(MaterialKind.document),
                          ),
                          const SizedBox(width: 6),
                          _AddButton(
                            label: l10n.addPhoto,
                            onTap: _uploading
                                ? null
                                : () => _addUpload(MaterialKind.image),
                          ),
                          const SizedBox(width: 6),
                          _AddButton(
                            label: l10n.addAudio,
                            onTap: _uploading
                                ? null
                                : () => _addUpload(MaterialKind.audio),
                          ),
                          const SizedBox(width: 6),
                          _AddButton(label: l10n.addLink, onTap: _addLink),
                        ],
                      ),
                      if (_uploading)
                        Padding(
                          padding: const EdgeInsets.only(top: RaeedSpacing.sm),
                          child: Text(
                            l10n.memUploading,
                            style: context.type.caption.copyWith(
                              color: palette.inkDim,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                BottomActionBar(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.sessSaveContent),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, RaeedTouchTarget.minPx),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          side: BorderSide(color: palette.border, width: 1.5),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: context.type.caption.copyWith(
            color: palette.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

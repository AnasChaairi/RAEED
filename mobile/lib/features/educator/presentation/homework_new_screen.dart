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
import '../../executive/presentation/widgets/executive_skeletons.dart';
import '../domain/educator_group.dart';
import '../domain/educator_session.dart';
import 'educator_providers.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-05 — new homework for the whole group or named children.
class HomeworkNewScreen extends ConsumerStatefulWidget {
  const HomeworkNewScreen({
    required this.sessionId,
    this.now,
    this.picker,
    super.key,
  });

  final String sessionId;
  final DateTime? now;
  final Future<String?> Function(ImageSource source)? picker;

  @override
  ConsumerState<HomeworkNewScreen> createState() => _HomeworkNewScreenState();
}

class _HomeworkNewScreenState extends ConsumerState<HomeworkNewScreen> {
  HomeworkDraft _draft = const HomeworkDraft();
  String? _attachmentName;
  bool _sending = false;

  /// The next three days, evenings, as the due-date chips.
  List<DateTime> get _dueOptions {
    final now = widget.now ?? DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 18);
    return [
      for (var i = 0; i < 3; i++)
        tomorrow.add(Duration(days: i * 2 + (i == 0 ? 0 : 1))),
    ];
  }

  Future<void> _send(int enrolled) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    if (!_draft.isWholeGroup && (_draft.targetChildIds?.isEmpty ?? true)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.hwPickOne)));
      return;
    }
    if (!_draft.isComplete || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(sessionsRepositoryProvider)
          .createHomework(widget.sessionId, _draft);
      ref.invalidate(sessionDetailProvider(widget.sessionId));
      messenger.showSnackBar(SnackBar(content: Text(l10n.hwSentToast)));
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
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _attach() async {
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
    try {
      final upload = await ref
          .read(educatorMemoriesRepositoryProvider)
          .upload(path);
      if (!mounted) return;
      setState(() {
        _draft = _draft.copyWith(attachmentKey: upload.storageKey);
        _attachmentName = upload.name;
      });
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(presentFailure(error, l10n).body)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final detail = ref.watch(sessionDetailProvider(widget.sessionId));
    final roster = detail.value == null
        ? null
        : ref.watch(educatorRosterProvider(detail.value!.item.group.id)).value;
    final enrolled = detail.value?.enrolledCount ?? roster?.length ?? 0;
    final targetCount = _draft.isWholeGroup
        ? enrolled
        : _draft.targetChildIds!.length;

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            EducatorPageHeader(
              title: l10n.hwNewTitle,
              subtitle: detail.value == null
                  ? null
                  : l10n.hwNewSubtitle(
                      dayAndMonth(locale, detail.value!.item.startsAt),
                      detail.value!.item.group.name,
                    ),
              fallbackRoute: AppRoutes.sessionPath(widget.sessionId),
            ),
            Expanded(
              child: detail.when(
                loading: () => const SkeletonCardList(count: 3, height: 70),
                error: (error, _) => RaeedErrorView(
                  error: error,
                  onRetry: () =>
                      ref.invalidate(sessionDetailProvider(widget.sessionId)),
                ),
                data: (data) => ListView(
                  padding: const EdgeInsets.all(RaeedSpacing.lg),
                  children: [
                    FieldLabel(l10n.annFieldTitle),
                    TextField(
                      onChanged: (value) => setState(
                        () => _draft = _draft.copyWith(title: value),
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.hwTitleHint,
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.md),
                    FieldLabel(l10n.hwInstructions),
                    TextField(
                      onChanged: (value) => setState(
                        () => _draft = _draft.copyWith(instructions: value),
                      ),
                      minLines: 2,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: l10n.hwInstructionsHint,
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.md),
                    FieldLabel(l10n.hwFor),
                    SegmentedChoice<bool>(
                      values: const [true, false],
                      selected: _draft.isWholeGroup,
                      labelOf: (whole) =>
                          whole ? l10n.hwWholeGroup(enrolled) : l10n.hwSpecific,
                      onSelect: (whole) => setState(
                        () => _draft = whole
                            ? _draft.copyWith(wholeGroup: true)
                            : _draft.copyWith(
                                targetChildIds: _draft.targetChildIds ?? {},
                              ),
                      ),
                    ),
                    if (!_draft.isWholeGroup) ...[
                      const SizedBox(height: RaeedSpacing.sm),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final child in roster ?? const <RosterChild>[])
                            FilterPill(
                              label: child.fullName.split(' ').first,
                              selected: _draft.targetChildIds!.contains(
                                child.id,
                              ),
                              onTap: () => setState(() {
                                final next = Set<String>.of(
                                  _draft.targetChildIds!,
                                );
                                if (!next.remove(child.id)) next.add(child.id);
                                _draft = _draft.copyWith(targetChildIds: next);
                              }),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: RaeedSpacing.md),
                    FieldLabel(l10n.hwDue),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final due in _dueOptions)
                          FilterPill(
                            label: dayAndMonth(locale, due),
                            selected: _draft.dueAt == due,
                            onTap: () => setState(
                              () => _draft = _draft.copyWith(dueAt: due),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.hwReminderNote,
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.md),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          RaeedTouchTarget.minPx,
                        ),
                        side: BorderSide(color: palette.border, width: 1.5),
                      ),
                      onPressed: _attach,
                      child: Text(
                        _attachmentName == null
                            ? l10n.hwAttachment
                            : l10n.hwAttachmentAdded(_attachmentName!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomActionBar(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: detail.value == null || _sending
                    ? null
                    : () => _send(enrolled),
                child: Text(l10n.hwSend(targetCount)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

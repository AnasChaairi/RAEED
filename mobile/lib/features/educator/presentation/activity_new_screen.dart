import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../executive/presentation/announcements_tab.dart' show FilterPill;
import '../../executive/presentation/executive_providers.dart';
import '../../executive/presentation/relative_time.dart';
import '../domain/educator_session.dart';
import 'educator_providers.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-03 — an activity the educator adds by hand (`/sessions/new`).
///
/// A sport outing, a workshop or an extra حصة for one of the educator's
/// groups, at a slot they choose. The server tells the group's guardians and
/// the activity lands on the child's schedule; the screen only collects.
class ActivityNewScreen extends ConsumerStatefulWidget {
  const ActivityNewScreen({this.initialGroupId, this.now, super.key});

  final String? initialGroupId;
  final DateTime? now;

  @override
  ConsumerState<ActivityNewScreen> createState() => _ActivityNewScreenState();
}

class _ActivityNewScreenState extends ConsumerState<ActivityNewScreen> {
  late ActivityDraft _draft = ActivityDraft(groupId: widget.initialGroupId);
  bool _saving = false;

  void _update(ActivityDraft next) => setState(() => _draft = next);

  static String kindLabel(AppL10n l10n, SessionKind kind) => switch (kind) {
    SessionKind.session => l10n.activityKindSession,
    SessionKind.sport => l10n.activityKindSport,
    SessionKind.workshop => l10n.activityKindWorkshop,
  };

  Future<void> _pickDay() async {
    final now = widget.now ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.day ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) _update(_draft.copyWith(day: picked));
  }

  Future<void> _pickTime({required bool start}) async {
    final current = start ? _draft.startsAt : _draft.endsAt;
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 0,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      ),
    );
    if (picked == null) return;
    final text =
        '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
    _update(
      start ? _draft.copyWith(startsAt: text) : _draft.copyWith(endsAt: text),
    );
  }

  Future<void> _create() async {
    if (!_draft.isComplete || _saving) return;
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    try {
      final detail = await ref
          .read(sessionsRepositoryProvider)
          .createActivity(_draft);
      ref.invalidate(weekSessionsProvider);
      ref.invalidate(todayControllerProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.activityCreatedToast} · ⦿')),
      );
      router.go(AppRoutes.sessionPath(detail.item.id));
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final groups = ref.watch(executiveGroupsProvider).value ?? const [];

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            EducatorPageHeader(
              title: l10n.activityNewTitle,
              subtitle: l10n.activityNewSubtitle,
              fallbackRoute: AppRoutes.homeTabPath(EducatorTab.sessions.slug),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(RaeedSpacing.lg),
                children: [
                  FieldLabel(l10n.activityGroup),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final group in groups)
                        FilterPill(
                          label: group.name,
                          selected: _draft.groupId == group.id,
                          onTap: () =>
                              _update(_draft.copyWith(groupId: group.id)),
                        ),
                    ],
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  FieldLabel(l10n.activityKind),
                  SegmentedChoice<SessionKind>(
                    values: SessionKind.values,
                    selected: _draft.kind,
                    labelOf: (kind) => kindLabel(l10n, kind),
                    onSelect: (kind) => _update(_draft.copyWith(kind: kind)),
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  FieldLabel(l10n.activitySlot),
                  OutlinedButton.icon(
                    key: const Key('activity-day'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        RaeedTouchTarget.minPx,
                      ),
                      foregroundColor: palette.ink,
                    ),
                    onPressed: _pickDay,
                    icon: const Icon(Icons.event_outlined, size: 18),
                    label: Text(
                      _draft.day == null
                          ? l10n.activityPickDay
                          : fullDate(locale, _draft.day!),
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('activity-start'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, RaeedTouchTarget.minPx),
                            foregroundColor: palette.ink,
                          ),
                          onPressed: () => _pickTime(start: true),
                          child: Text(
                            _draft.startsAt,
                            textDirection: TextDirection.ltr,
                            style: context.type.tabular(context.type.label),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RaeedSpacing.sm,
                        ),
                        child: Text(
                          '–',
                          style: context.type.caption.copyWith(
                            color: palette.inkDim,
                          ),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('activity-end'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, RaeedTouchTarget.minPx),
                            foregroundColor:
                                _draft.endsAt.compareTo(_draft.startsAt) > 0
                                ? palette.ink
                                : palette.danger,
                          ),
                          onPressed: () => _pickTime(start: false),
                          child: Text(
                            _draft.endsAt,
                            textDirection: TextDirection.ltr,
                            style: context.type.tabular(context.type.label),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  FieldLabel(l10n.annFieldTitle),
                  TextField(
                    key: const Key('activity-title'),
                    onChanged: (v) => _update(_draft.copyWith(title: v)),
                    decoration: InputDecoration(
                      hintText: l10n.activityTitleHint,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  FieldLabel(l10n.activityPlace),
                  TextField(
                    key: const Key('activity-place'),
                    onChanged: (v) => _update(_draft.copyWith(place: v)),
                    decoration: InputDecoration(
                      hintText: l10n.activityPlaceHint,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  FieldLabel(l10n.activityContent),
                  TextField(
                    key: const Key('activity-objectives'),
                    onChanged: (v) => _update(_draft.copyWith(objectives: v)),
                    minLines: 2,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: l10n.activityContentHint,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.sm),
                  Text(
                    l10n.activityNotice,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                ],
              ),
            ),
            BottomActionBar(
              child: FilledButton(
                key: const Key('activity-create'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _draft.isComplete && !_saving ? _create : null,
                child: Text(l10n.activityCreateCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

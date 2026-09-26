import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../../../shared/errors/failure_presenter.dart';
import '../../../executive/presentation/relative_time.dart';
import '../../domain/educator_session.dart';
import '../educator_providers.dart';
import 'session_widgets.dart';

/// Cancel or reschedule, with everyone it concerns named before the confirm.
class CancelSessionSheet extends ConsumerStatefulWidget {
  const CancelSessionSheet({required this.detail, super.key});

  final SessionDetail detail;

  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    SessionDetail detail,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CancelSessionSheet(detail: detail),
  );

  @override
  ConsumerState<CancelSessionSheet> createState() => _CancelSessionSheetState();
}

class _CancelSessionSheetState extends ConsumerState<CancelSessionSheet> {
  CancelDraft _draft = const CancelDraft();
  bool _busy = false;

  Future<void> _pickSlot() async {
    final item = widget.detail.item;
    final date = await showDatePicker(
      context: context,
      initialDate: item.startsAt.toLocal().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 120)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(item.startsAt.toLocal()),
    );
    if (time == null) return;
    final starts = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final length = item.endsAt.difference(item.startsAt);
    setState(
      () => _draft = _draft.copyWith(
        startsAt: starts,
        endsAt: starts.add(length),
      ),
    );
  }

  Future<void> _confirm() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(sessionsRepositoryProvider)
          .changeSession(widget.detail.id, _draft);
      ref.invalidate(sessionDetailProvider(widget.detail.id));
      ref.invalidate(weekSessionsProvider);
      ref.invalidate(todayControllerProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _draft.mode == CancelMode.cancel
                ? l10n.cancelledToast(result.notifiedCount)
                : l10n.movedToast(result.notifiedCount),
          ),
        ),
      );
      navigator.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
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
    final isMove = _draft.mode == CancelMode.reschedule;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RaeedRadius.xl2),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        RaeedSpacing.xl,
        RaeedSpacing.md,
        RaeedSpacing.xl,
        RaeedSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: RaeedSpacing.md),
            Text(
              l10n.cancelSheetTitle,
              style: context.type.h3.copyWith(color: palette.ink),
            ),
            const SizedBox(height: RaeedSpacing.sm + 2),
            SegmentedChoice<CancelMode>(
              values: CancelMode.values,
              selected: _draft.mode,
              labelOf: (mode) => mode == CancelMode.cancel
                  ? l10n.cancelModeCancel
                  : l10n.cancelModeMove,
              selectedColor: isMove ? palette.primary : palette.danger,
              onSelect: (mode) =>
                  setState(() => _draft = _draft.copyWith(mode: mode)),
            ),
            if (isMove) ...[
              const SizedBox(height: RaeedSpacing.sm + 2),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: palette.ink,
                ),
                onPressed: _pickSlot,
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(
                  _draft.startsAt == null
                      ? l10n.cancelPickSlot
                      : '${dayAndMonth(locale, _draft.startsAt!)} · ${clockTime(locale, _draft.startsAt!)}',
                ),
              ),
            ],
            const SizedBox(height: RaeedSpacing.sm + 2),
            TextField(
              onChanged: (value) =>
                  setState(() => _draft = _draft.copyWith(reason: value)),
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.cancelReasonHint,
                isDense: true,
              ),
            ),
            const SizedBox(height: RaeedSpacing.sm + 2),
            Text(
              l10n.cancelNotice(widget.detail.guardianCount),
              style: context.type.caption.copyWith(color: palette.inkDim),
            ),
            const SizedBox(height: RaeedSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: isMove
                          ? palette.primary
                          : palette.danger,
                      foregroundColor: isMove
                          ? palette.primaryOn
                          : palette.surface,
                    ),
                    onPressed: _draft.isComplete && !_busy ? _confirm : null,
                    child: Text(isMove ? l10n.moveCta : l10n.cancelCta),
                  ),
                ),
                const SizedBox(width: RaeedSpacing.sm),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    foregroundColor: palette.ink,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonBack),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

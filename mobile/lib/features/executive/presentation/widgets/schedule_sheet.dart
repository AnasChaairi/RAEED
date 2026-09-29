import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../domain/executive_group.dart';
import 'sheet_frame.dart';

/// Edit a group's weekly schedule: one row per slot — weekday, start, end.
///
/// Pops with the slots to save, or null when cancelled; the page owns the
/// request, so the sessions list it shows is refreshed from what the server
/// generated rather than guessed at here.
class ScheduleSheet extends StatefulWidget {
  const ScheduleSheet({required this.initial, super.key});

  final List<ScheduleSlot> initial;

  static Future<List<ScheduleSlot>?> show(
    BuildContext context, {
    required List<ScheduleSlot> initial,
  }) => showModalBottomSheet<List<ScheduleSlot>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ScheduleSheet(initial: initial),
  );

  /// What a new row starts as: Friday afternoon, the usual slot.
  static const defaultSlot = ScheduleSlot(
    weekday: 5,
    startsAt: '16:00',
    endsAt: '18:00',
  );

  @override
  State<ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<ScheduleSheet> {
  late List<ScheduleSlot> _slots = List.of(widget.initial);

  bool get _canSave =>
      _slots.every((slot) => slot.isWellFormed) &&
      !_sameAs(widget.initial, _slots);

  static bool _sameAs(List<ScheduleSlot> a, List<ScheduleSlot> b) =>
      a.length == b.length &&
      [for (var i = 0; i < a.length; i++) a[i] == b[i]].every((e) => e);

  void _set(int index, ScheduleSlot slot) =>
      setState(() => _slots = [..._slots]..[index] = slot);

  Future<void> _pickTime(int index, {required bool start}) async {
    final slot = _slots[index];
    final current = _parse(start ? slot.startsAt : slot.endsAt);
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    final text = _format(picked);
    _set(
      index,
      start ? slot.copyWith(startsAt: text) : slot.copyWith(endsAt: text),
    );
  }

  static TimeOfDay _parse(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 0,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  static String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final weekdays = [
      l10n.weekdaySun,
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
    ];

    return SheetFrame(
      title: l10n.scheduleEditTitle,
      recordedText: l10n.scheduleRecorded,
      canSave: _canSave,
      saving: false,
      onSave: () => Navigator.of(context).pop(_slots),
      children: [
        if (_slots.isEmpty)
          Text(
            l10n.scheduleEmptyHint,
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
        for (final (index, slot) in _slots.indexed) ...[
          if (index > 0) const SizedBox(height: RaeedSpacing.sm),
          Row(
            key: Key('slot-$index'),
            children: [
              Expanded(
                flex: 5,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: slot.weekday,
                    isDense: true,
                    isExpanded: true,
                    items: [
                      for (var d = 0; d < 7; d++)
                        DropdownMenuItem(value: d, child: Text(weekdays[d])),
                    ],
                    onChanged: (v) => v == null
                        ? null
                        : _set(index, slot.copyWith(weekday: v)),
                  ),
                ),
              ),
              const SizedBox(width: RaeedSpacing.sm),
              _TimeButton(
                key: Key('slot-$index-start'),
                text: slot.startsAt,
                onTap: () => _pickTime(index, start: true),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '–',
                  style: context.type.caption.copyWith(color: palette.inkDim),
                ),
              ),
              _TimeButton(
                key: Key('slot-$index-end'),
                text: slot.endsAt,
                danger: !slot.isWellFormed,
                onTap: () => _pickTime(index, start: false),
              ),
              IconButton(
                key: Key('slot-$index-remove'),
                tooltip: l10n.remove,
                onPressed: () =>
                    setState(() => _slots = [..._slots]..removeAt(index)),
                icon: Icon(
                  Icons.close_rounded,
                  color: palette.inkDim,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: RaeedSpacing.sm),
        OutlinedButton(
          key: const Key('slot-add'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
          onPressed: _slots.length >= 7
              ? null
              : () => setState(
                  () => _slots = [..._slots, ScheduleSheet.defaultSlot],
                ),
          child: Text(l10n.scheduleAddSlot),
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.text,
    required this.onTap,
    this.danger = false,
    super.key,
  });

  final String text;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.sm),
        foregroundColor: danger ? palette.danger : palette.ink,
      ),
      onPressed: onTap,
      child: Text(
        text,
        textDirection: TextDirection.ltr,
        style: context.type.tabular(context.type.label),
      ),
    );
  }
}

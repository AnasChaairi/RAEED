import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../domain/attendance_review.dart';
import '../attendance_review_screen.dart';
import 'recorded_marker.dart';
import 'tone_chip.dart';

/// The correction sheet: pick the status that should have stood, add a
/// note, and save — as a new record that points at the original.
class CorrectionSheet extends StatefulWidget {
  const CorrectionSheet({required this.row, this.clock, super.key});

  final AttendanceReviewRow row;

  /// The moment of the save, injected by tests.
  final DateTime Function()? clock;

  /// Resolves to the draft to apply, or null when cancelled.
  static Future<AttendanceCorrectionDraft?> show(
    BuildContext context, {
    required AttendanceReviewRow row,
    DateTime Function()? clock,
  }) => showModalBottomSheet<AttendanceCorrectionDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CorrectionSheet(row: row, clock: clock),
  );

  @override
  State<CorrectionSheet> createState() => _CorrectionSheetState();
}

class _CorrectionSheetState extends State<CorrectionSheet> {
  late AttendanceStatus _status =
      widget.row.currentStatus ?? AttendanceStatus.present;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(
    AttendanceCorrectionDraft(
      childId: widget.row.childId,
      status: _status,
      correctedAt: (widget.clock ?? DateTime.now)().toUtc(),
      correctedFromId: widget.row.current?.id,
      note: _note.text,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RaeedRadius.xl2),
        ),
        boxShadow: context.elevationSm,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            RaeedSpacing.xl,
            RaeedSpacing.md,
            RaeedSpacing.xl,
            RaeedSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                l10n.corrTitle(widget.row.childName),
                style: context.type.h3.copyWith(color: palette.ink),
              ),
              Text(
                l10n.corrBody,
                style: context.type.caption.copyWith(color: palette.inkDim),
              ),
              const SizedBox(height: RaeedSpacing.md + 2),
              Wrap(
                spacing: RaeedSpacing.sm,
                runSpacing: RaeedSpacing.sm,
                children: [
                  for (final status in AttendanceStatus.values)
                    _StatusChoice(
                      status: status,
                      selected: _status == status,
                      onTap: () => setState(() => _status = status),
                    ),
                ],
              ),
              const SizedBox(height: RaeedSpacing.md),
              TextField(
                controller: _note,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(hintText: l10n.corrNoteHint),
              ),
              const SizedBox(height: RaeedSpacing.sm + 2),
              const RecordedMarker(),
              const SizedBox(height: RaeedSpacing.md + 2),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: Text(l10n.corrSave),
                    ),
                  ),
                  const SizedBox(width: RaeedSpacing.sm),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        0,
                        RaeedTouchTarget.primaryActionsPx,
                      ),
                      foregroundColor: palette.ink,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.dialogCancel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChoice extends StatelessWidget {
  const _StatusChoice({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final AttendanceStatus status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final tone = switch (status) {
      AttendanceStatus.present => ChipTone.success,
      AttendanceStatus.absent => ChipTone.danger,
      AttendanceStatus.late => ChipTone.warning,
      AttendanceStatus.excused => ChipTone.info,
    };
    final colors = ToneChip.colorsFor(context, tone);
    final label = ReviewRow.statusLabel(l10n, status);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? colors.background : palette.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? colors.foreground : palette.border,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: RaeedTouchTarget.minPx,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.md + 2,
              ),
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    style: context.type.label.copyWith(
                      color: selected ? colors.foreground : palette.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

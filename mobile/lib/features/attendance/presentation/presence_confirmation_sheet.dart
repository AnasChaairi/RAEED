import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../domain/presence_answer.dart';
import 'attendance_providers.dart';

/// Presence confirmation, from the parent's side (`RAEED-16`).
///
/// The screen spec is a single sentence and the whole design is in it: "Push →
/// one-tap Yes/No/Late with an optional reason chip set (illness/travel/exam/
/// other) → done, no typing required unless 'other'."
///
/// So: three large buttons, the reason chips appear only after "no" or "late"
/// (they are meaningless after "yes"), the reason is genuinely optional, and
/// the keyboard never appears unless the parent picks "other". A parent
/// answering this is usually doing it one-handed, at a bus stop, in the two
/// minutes before they lose signal — every extra tap is a confirmation that
/// does not get answered.
///
/// The answer is queued locally first, so it survives that lost signal.
class PresenceConfirmationSheet extends ConsumerStatefulWidget {
  const PresenceConfirmationSheet({required this.confirmation, super.key});

  /// The confirmation being answered.
  final PendingPresenceConfirmation confirmation;

  /// Opens this as a modal bottom sheet.
  static Future<void> show(
    BuildContext context,
    PendingPresenceConfirmation confirmation,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => PresenceConfirmationSheet(confirmation: confirmation),
  );

  @override
  ConsumerState<PresenceConfirmationSheet> createState() =>
      _PresenceConfirmationSheetState();
}

class _PresenceConfirmationSheetState
    extends ConsumerState<PresenceConfirmationSheet> {
  PresenceAnswerValue? _answer;
  AbsenceReason? _reason;
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// "Yes" is final on tap: there is no reason to collect, so asking the
  /// parent to then press a submit button would be a tap for nothing.
  Future<void> _choose(PresenceAnswerValue answer) async {
    setState(() {
      _answer = answer;
      if (answer == PresenceAnswerValue.yes) _reason = null;
    });
    if (answer == PresenceAnswerValue.yes) await _submit();
  }

  Future<void> _submit() async {
    final answer = _answer;
    if (answer == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    final navigator = Navigator.of(context);

    try {
      await ref.read(submitPresenceAnswerProvider)(
        PresenceAnswerDraft(
          confirmationId: widget.confirmation.confirmationId,
          childId: widget.confirmation.childId,
          answer: answer,
          reason: _reason,
          note:
              _reason == AbsenceReason.other && _noteController.text.isNotEmpty
              ? _noteController.text
              : null,
        ),
      );
      if (!mounted) return;
      navigator.pop();
      // Confirmed unconditionally: the answer is queued on the device, so it
      // is recorded whether or not it has reached the server yet. Telling the
      // parent it failed because they are offline would invite them to answer
      // again.
      messenger.showSnackBar(SnackBar(content: Text(l10n.presenceAnswered)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final needsReason =
        _answer == PresenceAnswerValue.no ||
        _answer == PresenceAnswerValue.late;

    return Padding(
      padding: EdgeInsets.only(
        left: RaeedSpacing.xl2,
        right: RaeedSpacing.xl2,
        top: RaeedSpacing.xl2,
        // Lifts the sheet above the keyboard when "other" opens it.
        bottom: RaeedSpacing.xl2 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.presenceTitle,
              style: context.type.h3.copyWith(color: palette.ink),
            ),
            const SizedBox(height: RaeedSpacing.sm),
            Text(
              l10n.presenceQuestion(
                widget.confirmation.childName,
                widget.confirmation.groupName ?? '',
              ),
              style: context.type.body.copyWith(color: palette.inkDim),
            ),
            const SizedBox(height: RaeedSpacing.xl2),
            Row(
              children: [
                for (final answer in PresenceAnswerValue.values) ...[
                  Expanded(
                    child: _AnswerButton(
                      label: _answerLabel(l10n, answer),
                      isSelected: _answer == answer,
                      onPressed: _isSubmitting ? null : () => _choose(answer),
                    ),
                  ),
                  if (answer != PresenceAnswerValue.values.last)
                    const SizedBox(width: RaeedSpacing.sm),
                ],
              ],
            ),
            if (needsReason) ...[
              const SizedBox(height: RaeedSpacing.xl2),
              Text(
                l10n.presenceReasonPrompt,
                style: context.type.label.copyWith(color: palette.inkDim),
              ),
              const SizedBox(height: RaeedSpacing.sm),
              Wrap(
                spacing: RaeedSpacing.sm,
                runSpacing: RaeedSpacing.sm,
                children: [
                  for (final reason in AbsenceReason.values)
                    ChoiceChip(
                      label: Text(_reasonLabel(l10n, reason)),
                      selected: _reason == reason,
                      onSelected: _isSubmitting
                          ? null
                          : (selected) => setState(
                              () => _reason = selected ? reason : null,
                            ),
                    ),
                ],
              ),
              // The only place a keyboard appears in this flow.
              if (_reason == AbsenceReason.other) ...[
                const SizedBox(height: RaeedSpacing.lg),
                TextField(
                  controller: _noteController,
                  enabled: !_isSubmitting,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.presenceOtherNoteLabel,
                  ),
                ),
              ],
              const SizedBox(height: RaeedSpacing.xl2),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(l10n.commonConfirm),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _answerLabel(AppL10n l10n, PresenceAnswerValue answer) =>
      switch (answer) {
        PresenceAnswerValue.yes => l10n.presenceYes,
        PresenceAnswerValue.no => l10n.presenceNo,
        PresenceAnswerValue.late => l10n.presenceLate,
      };

  String _reasonLabel(AppL10n l10n, AbsenceReason reason) => switch (reason) {
    AbsenceReason.illness => l10n.presenceReasonIllness,
    AbsenceReason.travel => l10n.presenceReasonTravel,
    AbsenceReason.exam => l10n.presenceReasonExam,
    AbsenceReason.other => l10n.presenceReasonOther,
  };
}

/// One of the three answer buttons, sized for a one-handed tap.
class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      height: RaeedTouchTarget.primaryActionsPx,
      child: isSelected
          ? FilledButton(onPressed: onPressed, child: Text(label))
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.ink,
                side: BorderSide(color: palette.border),
              ),
              child: Text(label),
            ),
    );
  }
}

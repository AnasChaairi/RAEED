import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../../attendance/domain/presence_answer.dart';
import '../../../attendance/presentation/attendance_providers.dart';
import '../../../attendance/presentation/presence_confirmation_sheet.dart';

/// The design's "يحتاج ردّك" prompt, above the child cards.
///
/// `specs/06-mobile-app-spec.md` requires an unanswered confirmation to surface
/// on Home "so it survives a missed push". A pill on the child's own card
/// already says *that* an answer is owed; this card is what lets the parent
/// give it — the answer is three taps away on the card and one on "نعم", which
/// is the difference between a confirmation that gets answered at a bus stop
/// and one that does not.
///
/// "نعم" submits straight from here, exactly as it does in the sheet: there is
/// no reason to collect, so a second screen would be a tap for nothing. "لا"
/// and "سيتأخر" open the sheet with that answer already chosen, because those
/// two are the ones with an optional reason behind them.
class PresencePromptCard extends ConsumerWidget {
  const PresencePromptCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref
        .watch(unansweredConfirmationsProvider)
        .maybeWhen(
          data: (list) => list,
          orElse: () => const <PendingPresenceConfirmation>[],
        );
    if (pending.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: RaeedSpacing.lg,
        start: RaeedSpacing.lg,
        end: RaeedSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final confirmation in pending)
            Padding(
              padding: const EdgeInsets.only(bottom: RaeedSpacing.sm),
              child: _PromptTile(confirmation: confirmation),
            ),
        ],
      ),
    );
  }
}

class _PromptTile extends ConsumerStatefulWidget {
  const _PromptTile({required this.confirmation});

  final PendingPresenceConfirmation confirmation;

  @override
  ConsumerState<_PromptTile> createState() => _PromptTileState();
}

class _PromptTileState extends ConsumerState<_PromptTile> {
  bool _isSubmitting = false;

  Future<void> _answerYes() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);

    try {
      await ref.read(submitPresenceAnswerProvider)(
        PresenceAnswerDraft(
          confirmationId: widget.confirmation.confirmationId,
          childId: widget.confirmation.childId,
          answer: PresenceAnswerValue.yes,
        ),
      );
      // Confirmed unconditionally: the answer is queued on the device, so it is
      // recorded whether or not it has reached the server yet.
      messenger.showSnackBar(SnackBar(content: Text(l10n.presenceAnswered)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _openSheet(PresenceAnswerValue answer) =>
      PresenceConfirmationSheet.show(
        context,
        widget.confirmation,
        initialAnswer: answer,
      );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final confirmation = widget.confirmation;

    return Container(
      padding: const EdgeInsets.all(RaeedSpacing.lg),
      decoration: BoxDecoration(
        // The gold family, not the blue: this is the one thing on Home that is
        // asking the parent for something rather than telling them something.
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(RaeedRadius.xl2),
        border: Border.all(color: palette.accentDecorative),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.pending_actions_outlined,
                size: 16,
                color: palette.accent,
              ),
              const SizedBox(width: RaeedSpacing.xs),
              Flexible(
                child: Text(
                  l10n.homeNeedsYourReply,
                  style: context.type.label.copyWith(color: palette.accent),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: RaeedSpacing.sm),
          Text(
            l10n.presenceQuestion(
              confirmation.childName,
              confirmation.groupName ?? _timeOfDay(confirmation.sessionStartsAt),
            ),
            style: context.type.body.copyWith(color: palette.ink),
          ),
          const SizedBox(height: RaeedSpacing.lg),
          // Wraps rather than squeezing: three Arabic labels and a 48px touch
          // target do not share one 360px line at large text sizes, and a
          // second row is better than three unreadable buttons.
          Wrap(
            spacing: RaeedSpacing.sm,
            runSpacing: RaeedSpacing.sm,
            children: [
              FilledButton(
                onPressed: _isSubmitting ? null : _answerYes,
                child: Text(l10n.presenceYes),
              ),
              OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _openSheet(PresenceAnswerValue.no),
                child: Text(l10n.presenceNo),
              ),
              OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _openSheet(PresenceAnswerValue.late),
                child: Text(l10n.presenceLate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Western digits throughout, as the style guide pins for Morocco.
  String _timeOfDay(DateTime at) {
    final local = at.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

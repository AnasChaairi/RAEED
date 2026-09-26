import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/authorization/raeed_role.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../domain/conversation.dart';
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/executive_confirm_sheet.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';

/// EXEC-M-03 — one conversation, read with executive oversight.
///
/// The oversight notice renders in the header, before any message, when
/// the executive is not a member (`MSG-08`). Hiding a reported message is
/// reversible and recorded; nothing on this screen deletes.
class ConversationScreen extends ConsumerWidget {
  const ConversationScreen({required this.conversationId, this.now, super.key});

  final String conversationId;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final thread = ref.watch(conversationControllerProvider(conversationId));

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: thread.when(
          loading: () => Column(
            children: [
              _Header(
                title: '',
                members: const [],
                showOversight: false,
                onBack: () => _back(context),
              ),
              const Expanded(child: SkeletonCardList(count: 3, height: 72)),
            ],
          ),
          error: (error, _) => Column(
            children: [
              _Header(
                title: '',
                members: const [],
                showOversight: false,
                onBack: () => _back(context),
              ),
              Expanded(
                child: RaeedErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(
                    conversationControllerProvider(conversationId),
                  ),
                ),
              ),
            ],
          ),
          data: (state) => _Thread(
            conversationId: conversationId,
            state: state,
            now: now ?? DateTime.now(),
            onBack: () => _back(context),
          ),
        ),
      ),
    );
  }

  static void _back(BuildContext context) => context.canPop()
      ? context.pop()
      : context.go(AppRoutes.dashboardTabPath(ExecutiveTab.messages.slug));
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.members,
    required this.showOversight,
    required this.onBack,
  });

  final String title;
  final List<String> members;
  final bool showOversight;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.sm,
        RaeedSpacing.xs,
        RaeedSpacing.md + 2,
        RaeedSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              BackButton(onPressed: onBack),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.type.h3.copyWith(color: palette.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (members.isNotEmpty)
                      Text(
                        members.join(' · '),
                        style: context.type.caption.copyWith(
                          color: palette.inkDim,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (showOversight)
            Container(
              margin: const EdgeInsetsDirectional.only(
                top: 6,
                start: RaeedSpacing.sm,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.md,
                vertical: RaeedSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(RaeedRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.radio_button_checked,
                    size: 14,
                    color: palette.inkDim,
                  ),
                  const SizedBox(width: RaeedSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.msgOversightNotice,
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Thread extends ConsumerStatefulWidget {
  const _Thread({
    required this.conversationId,
    required this.state,
    required this.now,
    required this.onBack,
  });

  final String conversationId;
  final ConversationState state;
  final DateTime now;
  final VoidCallback onBack;

  @override
  ConsumerState<_Thread> createState() => _ThreadState();
}

class _ThreadState extends ConsumerState<_Thread> {
  final _composer = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _hide(ChatMessage message) async {
    final l10n = AppL10n.of(context);
    final confirmed = await ExecutiveConfirmSheet.show(
      context,
      weight: ConfirmWeight.reversible,
      kind: l10n.msgHideConfirmKind,
      title: l10n.msgHideConfirmTitle(message.senderName),
      body: l10n.msgHideConfirmBody,
      recordedText: l10n.msgHideConfirmLog,
      confirmLabel: l10n.msgHideConfirmCta,
    );
    if (!confirmed || !mounted) return;
    final byName = ref.read(sessionControllerProvider).user?.displayName ?? '';
    await _run(
      () => ref
          .read(conversationControllerProvider(widget.conversationId).notifier)
          .hide(message, byName: byName),
      success: '${l10n.msgHiddenToast} · ${l10n.recordedShort}',
    );
  }

  Future<void> _dismiss(ChatMessage message) => _run(
    () => ref
        .read(conversationControllerProvider(widget.conversationId).notifier)
        .dismissReport(message),
    success: AppL10n.of(context).msgReportDismissedToast,
  );

  Future<void> _send() async {
    final body = _composer.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    await _run(
      () => ref
          .read(conversationControllerProvider(widget.conversationId).notifier)
          .send(body),
      success: null,
      onSuccess: _composer.clear,
    );
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _run(
    Future<void> Function() action, {
    required String? success,
    VoidCallback? onSuccess,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppL10n.of(context);
    try {
      await action();
      onSuccess?.call();
      if (success != null) {
        messenger.showSnackBar(SnackBar(content: Text(success)));
      }
    } catch (error) {
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
    final state = widget.state;
    final userId = ref.watch(
      sessionControllerProvider.select((s) => s.user?.id ?? ''),
    );

    return Column(
      children: [
        _Header(
          title: state.detail.title,
          members: state.detail.memberNames,
          showOversight: !state.detail.isMember,
          onBack: widget.onBack,
        ),
        Expanded(
          child: state.messages.isEmpty
              ? ExecutiveEmptyState(
                  kind: EmptyStateKind.dataProblem,
                  title: l10n.msgThreadEmpty,
                  body: '',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    RaeedSpacing.md + 2,
                    RaeedSpacing.md + 2,
                    RaeedSpacing.md + 2,
                    RaeedSpacing.md,
                  ),
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RaeedSpacing.md - 1,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: palette.surfaceAlt,
                          borderRadius: BorderRadius.circular(RaeedRadius.pill),
                        ),
                        child: Text(
                          dayAndMonth(locale, state.messages.first.sentAt),
                          style: context.type
                              .tabular(context.type.caption)
                              .copyWith(color: palette.inkDim),
                        ),
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.sm + 2),
                    for (final message in state.messages)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: RaeedSpacing.sm + 2,
                        ),
                        child: MessageBubble(
                          message: message,
                          isMine: message.isFrom(userId),
                          now: widget.now,
                          onHide: () => _hide(message),
                          onDismissReport: () => _dismiss(message),
                        ),
                      ),
                  ],
                ),
        ),
        // A member's thread offers the three replies most conversations
        // start with; an overseer's does not, since they rarely write.
        if (state.detail.isMember)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.md + 2,
                vertical: 5,
              ),
              children: [
                for (final reply in [
                  l10n.quickReply1,
                  l10n.quickReply2,
                  l10n.quickReply3,
                ]) ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(
                        horizontal: RaeedSpacing.md,
                      ),
                      foregroundColor: palette.ink,
                      side: BorderSide(color: palette.border),
                    ),
                    onPressed: _sending
                        ? null
                        : () {
                            _composer.text = reply;
                            _send();
                          },
                    child: Text(reply, style: context.type.caption),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: palette.surface,
            border: Border(top: BorderSide(color: palette.border)),
          ),
          padding: const EdgeInsets.fromLTRB(
            RaeedSpacing.md + 2,
            RaeedSpacing.sm + 2,
            RaeedSpacing.md + 2,
            RaeedSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _composer,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: state.detail.isMember
                        ? l10n.msgComposerHintEdu
                        : l10n.msgComposerHint,
                    filled: true,
                    fillColor: palette.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RaeedRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RaeedRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: RaeedSpacing.md + 2,
                      vertical: RaeedSpacing.sm + 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: RaeedSpacing.sm),
              Semantics(
                button: true,
                label: l10n.msgSend,
                child: Material(
                  color: palette.primary,
                  borderRadius: BorderRadius.circular(RaeedRadius.lg),
                  child: InkWell(
                    onTap: _sending ? null : _send,
                    borderRadius: BorderRadius.circular(RaeedRadius.lg),
                    child: SizedBox(
                      width: RaeedTouchTarget.minPx,
                      height: RaeedTouchTarget.minPx,
                      child: Icon(
                        Icons.send_rounded,
                        color: palette.primaryOn,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One message: text or voice note, with the report actions and the hidden
/// stub. Voice notes render their duration and waveform; playback is a
/// later ticket.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.isMine,
    required this.now,
    this.onHide,
    this.onDismissReport,
    super.key,
  });

  final ChatMessage message;
  final bool isMine;
  final DateTime now;
  final VoidCallback? onHide;
  final VoidCallback? onDismissReport;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final hidden = message.hidden;

    if (hidden != null) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.86,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: RaeedSpacing.md + 1,
            vertical: RaeedSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: palette.surface,
            border: Border.all(color: palette.border, width: 1.5),
            borderRadius: _radius(isMine: false),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.visibility_off_outlined,
                    size: 13,
                    color: palette.inkDim,
                  ),
                  const SizedBox(width: RaeedSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.msgHiddenStub(
                        hidden.hiddenByName,
                        relativeTime(l10n, locale, hidden.hiddenAt, now: now),
                      ),
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (message.body != null)
                Text(
                  '${message.senderName}: ${message.body}',
                  style: context.type.bodySmall.copyWith(color: palette.inkDim),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      );
    }

    final senderLine = message.senderRole == null
        ? message.senderName
        : '${message.senderName} · ${_roleLabel(l10n, message.senderRole!)}';
    final report = message.report;

    return Align(
      alignment: isMine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.sizeOf(context).width * (report == null ? 0.8 : 0.86),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: RaeedSpacing.md + 1,
          vertical: RaeedSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isMine ? palette.primarySoft : palette.surface,
          border: isMine ? null : Border.all(color: palette.border),
          borderRadius: _radius(isMine: isMine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderLine,
              style: context.type.caption.copyWith(
                color: isMine ? palette.primary : palette.info,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message.kind == MessageKind.voice)
              _VoiceRow(seconds: message.durationSeconds ?? 0)
            else
              Text(
                message.body ?? '',
                style: context.type.bodySmall.copyWith(color: palette.ink),
              ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                clockTime(locale, message.sentAt),
                style: context.type
                    .tabular(context.type.caption)
                    .copyWith(color: palette.inkDim, fontSize: 10),
              ),
            ),
            if (report != null) ...[
              const SizedBox(height: RaeedSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.flag_rounded, size: 13, color: palette.danger),
                  const SizedBox(width: RaeedSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.msgReportedBy(report.reporterName, report.reason),
                      style: context.type.caption.copyWith(
                        color: palette.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RaeedSpacing.sm),
              Row(
                children: [
                  _SmallAction(
                    label: l10n.msgHide,
                    color: palette.danger,
                    onTap: onHide,
                  ),
                  const SizedBox(width: 6),
                  _SmallAction(
                    label: l10n.msgDismissReport,
                    color: palette.ink,
                    onTap: onDismissReport,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static BorderRadius _radius({required bool isMine}) =>
      BorderRadiusDirectional.only(
        topStart: const Radius.circular(RaeedRadius.lg + 2),
        topEnd: const Radius.circular(RaeedRadius.lg + 2),
        bottomStart: Radius.circular(isMine ? RaeedRadius.lg + 2 : 5),
        bottomEnd: Radius.circular(isMine ? 5 : RaeedRadius.lg + 2),
      ).resolve(TextDirection.ltr);

  static String _roleLabel(AppL10n l10n, RaeedRole role) => switch (role) {
    RaeedRole.parent => l10n.roleParent,
    RaeedRole.educator => l10n.roleEducator,
    RaeedRole.executive => l10n.roleExecutive,
    RaeedRole.admin => l10n.roleAdmin,
  };
}

class _VoiceRow extends StatelessWidget {
  const _VoiceRow({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    const heights = [8.0, 16.0, 22.0, 12.0, 18.0, 9.0, 17.0, 11.0];
    return Semantics(
      label: '${l10n.msgVoiceNote} ${duration(seconds)}',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: palette.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: palette.primaryOn,
                size: 20,
              ),
            ),
            const SizedBox(width: RaeedSpacing.sm + 2),
            SizedBox(
              height: 22,
              child: Row(
                children: [
                  for (var i = 0; i < heights.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        width: 3,
                        height: heights[i],
                        decoration: BoxDecoration(
                          color: i < 5 ? palette.primary : palette.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: RaeedSpacing.sm + 2),
            Text(
              duration(seconds),
              style: context.type
                  .tabular(context.type.caption)
                  .copyWith(color: palette.inkDim),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: palette.bg,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.md),
        textStyle: context.type.caption.copyWith(fontWeight: FontWeight.w600),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

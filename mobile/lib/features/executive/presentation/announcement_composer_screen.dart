import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../application/audience_reach.dart';
import '../domain/announcement_draft.dart';
import 'audience_label.dart';
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/audience_sheet.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_confirm_sheet.dart';

/// EXEC-M-02 — the announcement composer (`/announcements/compose`).
///
/// Urgent is a different thing from important: it pages every recipient and
/// falls back to SMS at the association's cost, so it sits behind the
/// high-reach confirm that names the number of people it will reach. A
/// normal announcement publishes on one tap.
class AnnouncementComposerScreen extends ConsumerStatefulWidget {
  const AnnouncementComposerScreen({super.key});

  @override
  ConsumerState<AnnouncementComposerScreen> createState() =>
      _AnnouncementComposerScreenState();
}

class _AnnouncementComposerScreenState
    extends ConsumerState<AnnouncementComposerScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  AnnouncementAudience _audience = const AnnouncementAudience.parents();
  bool _urgent = false;
  DateTime? _expireAt;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _title.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  AnnouncementDraft get _draft => AnnouncementDraft(
    title: _title.text,
    body: _body.text,
    audience: _audience,
    priority: _urgent
        ? AnnouncementPriority.urgent
        : AnnouncementPriority.normal,
    expireAt: _expireAt,
  );

  Future<void> _pickAudience() async {
    final chosen = await AudienceSheet.show(
      context,
      initial: _audience,
      reach: ref.read(audienceReachProvider).value,
    );
    if (chosen != null && mounted) setState(() => _audience = chosen);
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expireAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(
        () => _expireAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          23,
          59,
        ).toUtc(),
      );
    }
  }

  Future<void> _send() async {
    final l10n = AppL10n.of(context);
    final draft = _draft;
    if (!draft.isSendable || _sending) return;
    final reach = ref.read(audienceReachProvider).value;
    final count = reach == null ? 0 : reachFor(draft.audience, reach);

    if (draft.isUrgent) {
      final confirmed = await ExecutiveConfirmSheet.show(
        context,
        weight: ConfirmWeight.highReach,
        kind: l10n.annUrgentConfirmKind,
        title: l10n.annUrgentConfirmTitle(count),
        body: l10n.annUrgentConfirmBody,
        recordedText: l10n.annUrgentConfirmLog,
        confirmLabel: l10n.annUrgentConfirmCta,
      );
      if (!confirmed || !mounted) return;
    }

    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(publishAnnouncementProvider)(draft);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            draft.isUrgent
                ? l10n.annPublishedUrgent(count)
                : l10n.annPublished(count),
          ),
        ),
      );
      router.go(AppRoutes.dashboardTabPath(ExecutiveTab.announcements.slug));
    } catch (error) {
      if (!mounted) return;
      // The draft stays on screen; only the failure is reported.
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
    final locale = Localizations.localeOf(context);
    final reach = ref.watch(audienceReachProvider).value;
    final count = reach == null ? null : reachFor(_audience, reach);
    final draft = _draft;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(
                  AppRoutes.dashboardTabPath(ExecutiveTab.announcements.slug),
                ),
        ),
        title: Text(l10n.annNew),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(RaeedSpacing.lg),
                children: [
                  TextField(
                    controller: _title,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.annFieldTitle,
                      hintText: l10n.annTitleHint,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  TextField(
                    controller: _body,
                    minLines: 3,
                    maxLines: 8,
                    decoration: InputDecoration(
                      labelText: l10n.annFieldBody,
                      hintText: l10n.annBodyHint,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  ExecutiveCard(
                    onTap: _pickAudience,
                    radius: RaeedRadius.lg,
                    borderColor: palette.primary,
                    borderWidth: 1.5,
                    padding: const EdgeInsets.symmetric(
                      horizontal: RaeedSpacing.md + 2,
                      vertical: RaeedSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.annFieldAudience,
                                style: context.type.caption.copyWith(
                                  color: palette.inkDim,
                                ),
                              ),
                            ),
                            Text(
                              l10n.annChange,
                              style: context.type.caption.copyWith(
                                color: palette.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          count == null
                              ? audienceLabel(l10n, _audience, reach: reach)
                              : '${audienceLabel(l10n, _audience, reach: reach)}'
                                    ' · ${l10n.audPeople(count)}',
                          style: context.type.label.copyWith(
                            color: palette.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          audienceSummary(l10n, _audience, reach: reach),
                          style: context.type.caption.copyWith(
                            color: palette.inkDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  Row(
                    children: [
                      Expanded(
                        child: _SmallField(
                          label: l10n.annPublishTiming,
                          value: l10n.annPublishNow,
                        ),
                      ),
                      const SizedBox(width: RaeedSpacing.sm + 2),
                      Expanded(
                        child: _SmallField(
                          label: l10n.annExpires,
                          value: _expireAt == null
                              ? l10n.annNoExpiry
                              : shortDate(locale, _expireAt!),
                          onTap: _pickExpiry,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  _UrgentToggle(
                    value: _urgent,
                    onChanged: (value) => setState(() => _urgent = value),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: palette.surface,
                border: Border(top: BorderSide(color: palette.border)),
              ),
              padding: const EdgeInsets.fromLTRB(
                RaeedSpacing.lg,
                RaeedSpacing.md,
                RaeedSpacing.lg,
                RaeedSpacing.md,
              ),
              child: FilledButton(
                style: _urgent
                    ? FilledButton.styleFrom(
                        backgroundColor: palette.accentDecorative,
                        foregroundColor: palette.accentOn,
                      )
                    : null,
                onPressed: draft.isSendable && !_sending ? _send : null,
                child: Text(
                  _urgent ? l10n.annSendUrgent(count ?? 0) : l10n.annSend,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallField extends StatelessWidget {
  const _SmallField({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ExecutiveCard(
      onTap: onTap,
      radius: RaeedRadius.lg,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md,
        vertical: RaeedSpacing.sm + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.type.caption.copyWith(color: palette.inkDim),
          ),
          Text(
            value,
            style: context.type
                .tabular(context.type.label)
                .copyWith(color: palette.ink, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _UrgentToggle extends StatelessWidget {
  const _UrgentToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return ExecutiveCard(
      onTap: () => onChanged(!value),
      radius: RaeedRadius.lg,
      color: value ? palette.accentSoft : palette.surface,
      borderColor: value ? palette.accentDecorative : palette.border,
      borderWidth: 1.5,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.annUrgentTitle,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.annUrgentBody,
                  style: context.type.caption.copyWith(color: palette.inkDim),
                ),
              ],
            ),
          ),
          const SizedBox(width: RaeedSpacing.sm),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: palette.accentDecorative,
            activeThumbColor: palette.surface,
            inactiveTrackColor: palette.border,
            inactiveThumbColor: palette.surface,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

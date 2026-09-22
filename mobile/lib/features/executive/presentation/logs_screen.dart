import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../domain/structure.dart';
import 'announcements_tab.dart' show FilterPill;
import 'executive_providers.dart';
import 'relative_time.dart';
import 'structure_screen.dart' show currentRoleLabel, isForbidden;
import 'widgets/admin_only_card.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/section_header.dart';
import 'widgets/tone_chip.dart';

enum LogTab { audit, health }

/// EXEC-M-13 — the audit log and the health-access view (`/logs`, admin).
class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({this.now, super.key});

  final DateTime? now;

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  LogTab _tab = LogTab.audit;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final role = ref.watch(
      sessionControllerProvider.select((s) => s.effectiveRole),
    );
    final entries = ref.watch(
      auditLogProvider(
        action: _tab == LogTab.health ? 'child.health_view' : null,
      ),
    );
    final forbidden = entries.error != null && isForbidden(entries.error!);

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: l10n.logsTitle, trailing: const AdminTag()),
            if (forbidden)
              Expanded(
                child: AdminOnlyCard(roleLabel: currentRoleLabel(l10n, role)),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RaeedSpacing.lg,
                ),
                child: Row(
                  children: [
                    FilterPill(
                      label: l10n.logTabAudit,
                      selected: _tab == LogTab.audit,
                      onTap: () => setState(() => _tab = LogTab.audit),
                    ),
                    const SizedBox(width: 6),
                    FilterPill(
                      label: l10n.logTabHealth,
                      selected: _tab == LogTab.health,
                      onTap: () => setState(() => _tab = LogTab.health),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: RaeedSpacing.sm + 2),
              Expanded(
                child: entries.when(
                  loading: () => const SkeletonCardList(count: 6, height: 72),
                  error: (error, _) => RaeedErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(auditLogProvider),
                  ),
                  data: (list) => ListView(
                    padding: const EdgeInsets.fromLTRB(
                      RaeedSpacing.lg,
                      0,
                      RaeedSpacing.lg,
                      RaeedSpacing.xl2,
                    ),
                    children: [
                      if (_tab == LogTab.health)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            RaeedSpacing.xs,
                            0,
                            RaeedSpacing.xs,
                            RaeedSpacing.sm,
                          ),
                          child: Text(
                            l10n.healthLogIntro,
                            style: context.type.caption.copyWith(
                              color: palette.inkDim,
                            ),
                          ),
                        ),
                      if (list.isEmpty)
                        ExecutiveEmptyState(
                          kind: EmptyStateKind.reassuring,
                          title: l10n.logsEmpty,
                          body: '',
                        )
                      else
                        for (final entry in list)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: RaeedSpacing.sm,
                            ),
                            child: AuditEntryCard(
                              entry: entry,
                              now: widget.now ?? DateTime.now(),
                            ),
                          ),
                      if (_tab == LogTab.audit)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: RaeedSpacing.xs,
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '${l10n.logsAppendOnly} '),
                                TextSpan(
                                  text: l10n.retentionUnset,
                                  style: TextStyle(color: palette.accent),
                                ),
                              ],
                            ),
                            style: context.type.caption.copyWith(
                              color: palette.inkDim,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One audit line: an icon tile by kind, who did what to which resource, when
/// and from what device.
class AuditEntryCard extends StatelessWidget {
  const AuditEntryCard({required this.entry, required this.now, super.key});

  final AuditEntry entry;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final (label, tone, icon) = describe(l10n, entry.action);
    final colors = ToneChip.colorsFor(context, tone);
    final device = entry.deviceMeta['device'] ?? entry.deviceMeta['platform'];

    return ExecutiveCard(
      radius: RaeedRadius.lg + 2,
      padding: const EdgeInsets.symmetric(
        horizontal: RaeedSpacing.md + 2,
        vertical: RaeedSpacing.sm + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(RaeedRadius.md),
            ),
            child: Icon(icon, size: 16, color: colors.foreground),
          ),
          const SizedBox(width: RaeedSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: entry.actorName.isEmpty ? '—' : entry.actorName,
                        style: context.type.label.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' · $label',
                        style: context.type.label.copyWith(color: palette.ink),
                      ),
                    ],
                  ),
                ),
                if (entry.resourceLabel != null)
                  Text(
                    entry.resourceLabel!,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                Text(
                  [
                    relativeTime(l10n, locale, entry.at, now: now),
                    clockTime(locale, entry.at),
                    if (device is String) device,
                  ].join(' · '),
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.inkDim, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The word, tone and icon for an action code.
  static (String, ChipTone, IconData) describe(AppL10n l10n, String action) =>
      switch (action) {
        'child.health_view' => (
          l10n.actionHealthView,
          ChipTone.danger,
          Icons.priority_high_rounded,
        ),
        'guardian.phone_reveal' => (
          l10n.actionPhoneReveal,
          ChipTone.danger,
          Icons.phone_outlined,
        ),
        'attendance.correct' => (
          l10n.actionCorrect,
          ChipTone.warning,
          Icons.history_rounded,
        ),
        'report.export' => (
          l10n.actionExport,
          ChipTone.accent,
          Icons.download_outlined,
        ),
        'message.hide' => (
          l10n.actionHideMessage,
          ChipTone.danger,
          Icons.visibility_off_outlined,
        ),
        'message_report.dismiss' => (
          l10n.actionDismissReport,
          ChipTone.neutral,
          Icons.flag_outlined,
        ),
        'conversation.oversight_read' => (
          l10n.actionOversightRead,
          ChipTone.info,
          Icons.visibility_outlined,
        ),
        'post.approve' => (
          l10n.actionApprovePost,
          ChipTone.success,
          Icons.check_rounded,
        ),
        'post.hide' => (
          l10n.actionHidePost,
          ChipTone.danger,
          Icons.hide_image_outlined,
        ),
        'announcement.publish' => (
          l10n.actionPublish,
          ChipTone.info,
          Icons.campaign_outlined,
        ),
        'group.assign' => (
          l10n.actionAssign,
          ChipTone.info,
          Icons.group_add_outlined,
        ),
        'group.create' || 'family.create' || 'branch.create' => (
          l10n.actionCreate,
          ChipTone.info,
          Icons.add_rounded,
        ),
        'season.archive' => (
          l10n.actionArchive,
          ChipTone.neutral,
          Icons.inventory_2_outlined,
        ),
        'invitation.resend' => (
          l10n.actionInvite,
          ChipTone.neutral,
          Icons.send_outlined,
        ),
        'access.denied' => (
          l10n.actionDenied,
          ChipTone.warning,
          Icons.lock_outline_rounded,
        ),
        'auth.login' || 'session.login' => (
          l10n.actionLogin,
          ChipTone.neutral,
          Icons.login_rounded,
        ),
        _ => (l10n.actionOther, ChipTone.neutral, Icons.circle_outlined),
      };
}

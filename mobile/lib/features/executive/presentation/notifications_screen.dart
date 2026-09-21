import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../application/notification_filter.dart';
import '../domain/notification_item.dart';
import 'announcements_tab.dart' show FilterPill;
import 'executive_providers.dart';
import 'relative_time.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';

/// EXEC-M-06 — the notification centre (`/notifications`).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({this.now, super.key});

  final DateTime? now;

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationFilter _filter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final notifications = ref.watch(notificationsControllerProvider);
    final all = notifications.value ?? const <NotificationItem>[];

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RaeedSpacing.sm,
                RaeedSpacing.xs,
                RaeedSpacing.md + 2,
                RaeedSpacing.sm,
              ),
              child: Row(
                children: [
                  BackButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.dashboard),
                  ),
                  Expanded(
                    child: Text(
                      l10n.notifTitle,
                      style: context.type.h1.copyWith(color: palette.ink),
                    ),
                  ),
                  if (unreadCount(all) > 0)
                    TextButton(
                      onPressed: () => ref
                          .read(notificationsControllerProvider.notifier)
                          .markAllRead(),
                      child: Text(l10n.notifMarkAllRead),
                    ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.lg),
              child: Row(
                children: [
                  for (final filter in NotificationFilter.values) ...[
                    FilterPill(
                      label: filter == NotificationFilter.all
                          ? '${l10n.notifFilterAll} ${all.length}'
                          : _filterLabel(l10n, filter),
                      selected: _filter == filter,
                      onTap: () => setState(() => _filter = filter),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: RaeedSpacing.md),
            Expanded(
              child: notifications.when(
                loading: () => const SkeletonCardList(count: 5, height: 80),
                error: (error, _) => RaeedErrorView(
                  error: error,
                  onRetry: () =>
                      ref.invalidate(notificationsControllerProvider),
                ),
                data: (items) {
                  final shown = filterNotifications(items, _filter);
                  if (shown.isEmpty) {
                    return ExecutiveEmptyState(
                      kind: EmptyStateKind.reassuring,
                      title: l10n.notifEmptyTitle,
                      body: l10n.notifEmptyBody,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      RaeedSpacing.lg,
                      0,
                      RaeedSpacing.lg,
                      RaeedSpacing.xl2,
                    ),
                    itemCount: shown.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: RaeedSpacing.sm),
                    itemBuilder: (_, index) => NotificationCard(
                      item: shown[index],
                      now: widget.now ?? DateTime.now(),
                      onTap: () => _open(context, shown[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, NotificationItem item) {
    final destination = item.destination;
    if (destination == null) return;
    final tab = ExecutiveTab.forDestination(destination);
    if (tab == null) return;
    context.go(AppRoutes.dashboardTabPath(tab.slug));
  }

  static String _filterLabel(AppL10n l10n, NotificationFilter filter) =>
      switch (filter) {
        NotificationFilter.all => l10n.notifFilterAll,
        NotificationFilter.critical => l10n.notifFilterCritical,
        NotificationFilter.requests => l10n.notifFilterRequests,
        NotificationFilter.memories => l10n.notifFilterMemories,
      };
}

/// One notification: an icon tile by kind, the title, the body, when.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.item,
    required this.now,
    this.onTap,
    super.key,
  });

  final NotificationItem item;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final critical = item.kind == NotificationKind.critical;
    final (iconBg, iconFg, icon) = switch (item.kind) {
      NotificationKind.critical => (
        palette.danger,
        palette.surface,
        Icons.priority_high_rounded,
      ),
      NotificationKind.request => (
        palette.infoSoft,
        palette.info,
        Icons.edit_outlined,
      ),
      NotificationKind.memories => (
        palette.accentSoft,
        palette.accent,
        Icons.photo_outlined,
      ),
      NotificationKind.security => (
        palette.surfaceAlt,
        palette.inkDim,
        Icons.devices_outlined,
      ),
      NotificationKind.other => (
        palette.surfaceAlt,
        palette.inkDim,
        Icons.notifications_none_rounded,
      ),
    };

    return Opacity(
      opacity: item.isRead ? 0.7 : 1,
      child: ExecutiveCard(
        onTap: onTap,
        radius: RaeedRadius.lg + 2,
        color: critical && !item.isRead ? palette.dangerSoft : null,
        borderColor: critical && !item.isRead ? palette.danger : null,
        padding: const EdgeInsets.symmetric(
          horizontal: RaeedSpacing.md + 2,
          vertical: RaeedSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
              ),
              child: Icon(icon, size: 18, color: iconFg),
            ),
            const SizedBox(width: RaeedSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: context.type.label.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.body != null)
                    Text(
                      item.body!,
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                      ),
                    ),
                  const SizedBox(height: RaeedSpacing.xs),
                  Text(
                    relativeTime(l10n, locale, item.sentAt, now: now),
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(color: palette.inkDim),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

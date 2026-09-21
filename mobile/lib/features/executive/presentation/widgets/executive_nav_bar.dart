import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../application/executive_tab_badges.dart';
import '../executive_providers.dart';

/// The five-tab bottom nav of the executive shell.
///
/// Badges are counts of things waiting, in `danger` because each one is a
/// question the executive opened the app to ask — a danger alert about a
/// group, a post awaiting review, a thread with something unread or reported.
class ExecutiveNavBar extends StatelessWidget {
  const ExecutiveNavBar({
    required this.current,
    required this.badges,
    required this.onSelect,
    super.key,
  });

  final ExecutiveTab current;
  final ExecutiveTabBadges badges;
  final ValueChanged<ExecutiveTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);

    return Semantics(
      container: true,
      label: l10n.execNavLabel,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(top: BorderSide(color: palette.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (final tab in ExecutiveTab.values)
                  Expanded(
                    child: _NavItem(
                      tab: tab,
                      selected: tab == current,
                      badge: _badgeFor(tab),
                      onTap: () => onSelect(tab),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _badgeFor(ExecutiveTab tab) => switch (tab) {
    ExecutiveTab.groups => badges.groups,
    ExecutiveTab.memories => badges.memories,
    ExecutiveTab.messages => badges.messages,
    _ => 0,
  };
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final ExecutiveTab tab;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final label = switch (tab) {
      ExecutiveTab.dashboard => l10n.execTabDashboard,
      ExecutiveTab.announcements => l10n.execTabAnnouncements,
      ExecutiveTab.messages => l10n.execTabMessages,
      ExecutiveTab.memories => l10n.execTabMemories,
      ExecutiveTab.groups => l10n.execTabGroups,
    };
    final color = selected ? palette.primary : palette.inkDim;

    return Semantics(
      button: true,
      selected: selected,
      label: badge > 0 ? '$label ($badge)' : label,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 56,
            minHeight: RaeedTouchTarget.primaryActionsPx,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_iconFor(tab, selected), size: 22, color: color),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: context.type.caption.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (badge > 0)
                PositionedDirectional(
                  top: 6,
                  end: 14,
                  child: ExcludeSemantics(
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: palette.danger,
                        borderRadius: BorderRadius.circular(RaeedRadius.pill),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$badge',
                        style: context.type
                            .tabular(context.type.caption)
                            .copyWith(
                              color: palette.surface,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(ExecutiveTab tab, bool selected) => switch (tab) {
    ExecutiveTab.dashboard =>
      selected ? Icons.dashboard_rounded : Icons.dashboard_outlined,
    ExecutiveTab.announcements =>
      selected ? Icons.campaign_rounded : Icons.campaign_outlined,
    ExecutiveTab.messages =>
      selected ? Icons.chat_bubble_rounded : Icons.chat_bubble_outline_rounded,
    ExecutiveTab.memories =>
      selected ? Icons.photo_library_rounded : Icons.photo_library_outlined,
    ExecutiveTab.groups =>
      selected ? Icons.groups_rounded : Icons.groups_outlined,
  };
}

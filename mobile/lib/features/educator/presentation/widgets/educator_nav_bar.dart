import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../educator_providers.dart';

/// The educator's five tabs: Today · Sessions · Groups · Messages · Memories.
class EducatorNavBar extends StatelessWidget {
  const EducatorNavBar({
    required this.current,
    required this.sessionsBadge,
    required this.messagesBadge,
    required this.onSelect,
    super.key,
  });

  final EducatorTab current;
  final int sessionsBadge;
  final int messagesBadge;
  final ValueChanged<EducatorTab> onSelect;

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
                for (final tab in EducatorTab.values)
                  Expanded(
                    child: _NavItem(
                      tab: tab,
                      selected: tab == current,
                      badge: switch (tab) {
                        EducatorTab.sessions => sessionsBadge,
                        EducatorTab.messages => messagesBadge,
                        _ => 0,
                      },
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
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final EducatorTab tab;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final label = switch (tab) {
      EducatorTab.today => l10n.eduTabToday,
      EducatorTab.sessions => l10n.eduTabSessions,
      EducatorTab.groups => l10n.eduTabGroups,
      EducatorTab.messages => l10n.eduTabMessages,
      EducatorTab.memories => l10n.eduTabMemories,
    };
    final icon = switch (tab) {
      EducatorTab.today =>
        selected ? Icons.today_rounded : Icons.today_outlined,
      EducatorTab.sessions =>
        selected ? Icons.calendar_month_rounded : Icons.calendar_month_outlined,
      EducatorTab.groups =>
        selected ? Icons.groups_rounded : Icons.groups_outlined,
      EducatorTab.messages =>
        selected
            ? Icons.chat_bubble_rounded
            : Icons.chat_bubble_outline_rounded,
      EducatorTab.memories =>
        selected ? Icons.photo_library_rounded : Icons.photo_library_outlined,
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
                  Icon(icon, size: 22, color: color),
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
}

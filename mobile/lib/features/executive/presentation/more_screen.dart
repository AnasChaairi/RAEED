import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/authorization/raeed_role.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../core/theme/theme_mode_controller.dart';
import 'widgets/executive_card.dart';

/// EXEC-M-07 — settings and the role switcher (`/more`).
///
/// No phone number on the profile card: the session deliberately does not
/// hold one (`MSG-06`). The role switcher narrows *presentation* only;
/// abilities remain the union of every role held.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;
    final themeMode = ref.watch(themeModeControllerProvider);
    final locale = ref.watch(localeControllerProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && context.isDarkTheme);
    final roles = _ordered(user?.roles ?? const {});

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            RaeedSpacing.lg,
            RaeedSpacing.xs,
            RaeedSpacing.lg,
            RaeedSpacing.xl2,
          ),
          children: [
            Row(
              children: [
                BackButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.dashboard),
                ),
                Text(
                  l10n.execMore,
                  style: context.type.h1.copyWith(color: palette.ink),
                ),
              ],
            ),
            const SizedBox(height: RaeedSpacing.sm),
            ExecutiveCard(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(RaeedRadius.lg + 2),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: palette.inkDim,
                    ),
                  ),
                  const SizedBox(width: RaeedSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? '',
                          style: context.type.h3.copyWith(color: palette.ink),
                        ),
                        Text(
                          user?.branchId == null
                              ? l10n.execScopeAllBranches
                              : l10n.execScopeRestricted,
                          style: context.type.caption.copyWith(
                            color: palette.inkDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RaeedSpacing.sm + 2),
            if (roles.isNotEmpty)
              ExecutiveCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${l10n.moreCurrentRole} — ${l10n.moreRolesCount(roles.length)}',
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.sm),
                    for (final role in roles) ...[
                      RoleChoice(
                        role: role,
                        selected: session.effectiveRole == role,
                        onTap: roles.length > 1
                            ? () => _switchTo(context, ref, role)
                            : null,
                      ),
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: RaeedSpacing.sm + 2),
            ExecutiveCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingRow(
                    label: l10n.moreDarkMode,
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) => ref
                          .read(themeModeControllerProvider.notifier)
                          .setDark(value),
                    ),
                  ),
                  Divider(color: palette.border),
                  _SettingRow(
                    label: l10n.moreLanguage,
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: locale.languageCode,
                        style: context.type.bodySmall.copyWith(
                          color: palette.inkDim,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text(l10n.languageArabic),
                          ),
                          DropdownMenuItem(
                            value: 'fr',
                            child: Text(l10n.languageFrench),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(l10n.languageEnglish),
                          ),
                        ],
                        onChanged: (code) {
                          if (code == null) return;
                          ref
                              .read(localeControllerProvider.notifier)
                              .setLocale(Locale(code));
                        },
                      ),
                    ),
                  ),
                  Divider(color: palette.border),
                  Padding(
                    padding: const EdgeInsets.all(RaeedSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.moreCriticalChannel,
                                style: context.type.label.copyWith(
                                  color: palette.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                              color: palette.inkDim,
                            ),
                          ],
                        ),
                        Text(
                          l10n.moreCriticalChannelLocked,
                          style: context.type.caption.copyWith(
                            color: palette.inkDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RaeedSpacing.md),
            Text(
              l10n.moreTagline,
              textAlign: TextAlign.center,
              style: context.type.caption.copyWith(color: palette.inkDim),
            ),
          ],
        ),
      ),
    );
  }

  /// Most privileged first, so the executive surface is the first option.
  static List<RaeedRole> _ordered(Set<RaeedRole> roles) => [
    for (final role in const [
      RaeedRole.admin,
      RaeedRole.executive,
      RaeedRole.educator,
      RaeedRole.parent,
    ])
      if (roles.contains(role)) role,
  ];

  void _switchTo(BuildContext context, WidgetRef ref, RaeedRole role) {
    ref.read(sessionControllerProvider.notifier).switchRole(role);
    context.go(role.hasOversight ? AppRoutes.dashboard : AppRoutes.home);
  }
}

/// One role in the switcher: a radio dot, the role's name, and what its
/// surface is for.
class RoleChoice extends StatelessWidget {
  const RoleChoice({
    required this.role,
    required this.selected,
    this.onTap,
    super.key,
  });

  final RaeedRole role;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final (label, hint) = switch (role) {
      RaeedRole.admin => (l10n.roleAdmin, l10n.roleHintAdmin),
      RaeedRole.executive => (l10n.roleExecutive, l10n.roleHintExecutive),
      RaeedRole.educator => (l10n.roleEducator, l10n.roleHintEducator),
      RaeedRole.parent => (l10n.roleParent, l10n.roleHintParent),
    };

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? palette.primarySoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaeedRadius.lg),
          side: BorderSide(
            color: selected ? palette.primary : palette.border,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaeedRadius.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: RaeedTouchTarget.primaryActionsPx,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RaeedSpacing.md,
                vertical: RaeedSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? palette.primary : Colors.transparent,
                      border: Border.all(
                        color: selected ? palette.primary : palette.inkDim,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: RaeedSpacing.sm + 2),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: context.type.label.copyWith(
                              color: palette.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            hint,
                            style: context.type.caption.copyWith(
                              color: palette.inkDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: RaeedTouchTarget.primaryActionsPx,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RaeedSpacing.lg,
          vertical: RaeedSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.type.label.copyWith(
                  color: palette.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

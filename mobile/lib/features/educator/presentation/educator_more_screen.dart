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
import '../../../shared/errors/failure_presenter.dart';
import '../../executive/presentation/announcements_tab.dart' show FilterPill;
import '../../executive/presentation/executive_providers.dart';
import '../../executive/presentation/more_screen.dart' show RoleChoice;
import '../../executive/presentation/widgets/executive_card.dart';
import '../domain/availability.dart';
import 'educator_providers.dart';

/// EDU-M-10 — the educator's More: role switch, availability hours, theme,
/// language, the locked reminder row, sign out. Presented to a guardian too
/// (without the educator-only cards), so a user holding both roles can
/// switch back from the parent surface.
///
/// Was: the educator's More: role switch, availability hours, theme,
/// language, the locked reminder row, sign out.
class EducatorMoreScreen extends ConsumerWidget {
  const EducatorMoreScreen({super.key});

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
    final groups = ref.watch(executiveGroupsProvider).value ?? const [];
    final isEducator = session.effectiveRole == RaeedRole.educator;
    final availability = isEducator
        ? ref.watch(availabilityControllerProvider).value
        : null;
    final roles = [
      for (final role in const [
        RaeedRole.admin,
        RaeedRole.executive,
        RaeedRole.educator,
        RaeedRole.parent,
      ])
        if (user?.roles.contains(role) ?? false) role,
    ];

    Future<void> setAvailability(AvailabilityWindow window) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(availabilityControllerProvider.notifier).set(window);
        messenger.showSnackBar(SnackBar(content: Text(l10n.availSavedToast)));
      } catch (error) {
        messenger.showSnackBar(
          SnackBar(content: Text(presentFailure(error, l10n).body)),
        );
      }
    }

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
                      : context.go(AppRoutes.home),
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
                          isEducator
                              ? l10n.moreEduRole(
                                  groups.map((g) => g.name).join(' · '),
                                )
                              : l10n.roleParent,
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
            if (roles.length > 1) ...[
              const SizedBox(height: RaeedSpacing.sm + 2),
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
                        onTap: () {
                          ref
                              .read(sessionControllerProvider.notifier)
                              .switchRole(role);
                          context.go(
                            role.hasOversight
                                ? AppRoutes.dashboard
                                : AppRoutes.home,
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: RaeedSpacing.sm + 2),
            if (isEducator)
              ExecutiveCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.availTitle,
                            style: context.type.label.copyWith(
                              color: palette.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          availability?.label ?? '—',
                          style: context.type
                              .tabular(context.type.label)
                              .copyWith(
                                color: palette.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: RaeedSpacing.xs),
                    Text(
                      l10n.availBody,
                      style: context.type.caption.copyWith(
                        color: palette.inkDim,
                      ),
                    ),
                    const SizedBox(height: RaeedSpacing.sm + 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final preset in AvailabilityWindow.presets)
                          FilterPill(
                            label: preset.label,
                            selected: availability == preset,
                            onTap: () => setAvailability(preset),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: RaeedSpacing.sm + 2),
            ExecutiveCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Row(
                    label: l10n.moreDarkMode,
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) => ref
                          .read(themeModeControllerProvider.notifier)
                          .setDark(value),
                    ),
                  ),
                  Divider(height: 1, color: palette.border),
                  _Row(
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
                          if (code != null) {
                            ref
                                .read(localeControllerProvider.notifier)
                                .setLocale(Locale(code));
                          }
                        },
                      ),
                    ),
                  ),
                  if (isEducator) ...[
                    Divider(height: 1, color: palette.border),
                    _Row(
                      label: l10n.attReminderRow,
                      trailing: Text(
                        l10n.attReminderLocked,
                        style: context.type
                            .tabular(context.type.caption)
                            .copyWith(color: palette.inkDim),
                      ),
                    ),
                  ],
                  Divider(height: 1, color: palette.border),
                  InkWell(
                    onTap: () =>
                        ref.read(sessionControllerProvider.notifier).signOut(),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: RaeedTouchTarget.primaryActionsPx,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RaeedSpacing.lg,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.moreSignOut,
                                style: context.type.label.copyWith(
                                  color: palette.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.logout_rounded,
                              size: 20,
                              color: palette.danger,
                            ),
                          ],
                        ),
                      ),
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
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
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
                color: context.palette.ink,
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

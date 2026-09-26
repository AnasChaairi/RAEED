import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';
import '../../../executive/presentation/relative_time.dart';
import '../../../executive/presentation/widgets/executive_card.dart';
import '../../../executive/presentation/widgets/tone_chip.dart';
import '../../domain/educator_session.dart';

/// The state chip on every session row.
class SessionStateChip extends StatelessWidget {
  const SessionStateChip({required this.item, required this.now, super.key});

  final SessionItem item;
  final DateTime now;

  static (String, ChipTone) describe(
    AppL10n l10n,
    SessionItem item,
    DateTime now,
  ) => switch (item.stateAt(now)) {
    SessionState.ended => (l10n.sessionEnded, ChipTone.success),
    SessionState.live => (l10n.sessStateLive, ChipTone.primary),
    SessionState.soon => (
      l10n.sessStateSoon(item.startsAt.difference(now).inMinutes),
      ChipTone.primary,
    ),
    SessionState.upcoming => (l10n.sessStateUpcoming, ChipTone.neutral),
    SessionState.noContent => (l10n.sessStateNoContent, ChipTone.warning),
    SessionState.cancelled => (l10n.sessionCancelled, ChipTone.danger),
    SessionState.rescheduled => (l10n.sessStateMoved, ChipTone.warning),
  };

  @override
  Widget build(BuildContext context) {
    final (label, tone) = describe(AppL10n.of(context), item, now);
    return ToneChip(label: label, tone: tone);
  }
}

/// A session row: time, title, group · meta, state chip.
class SessionRow extends StatelessWidget {
  const SessionRow({
    required this.item,
    required this.now,
    this.meta,
    super.key,
  });

  final SessionItem item;
  final DateTime now;

  /// Overrides the default "group · meta" line.
  final String? meta;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final locale = Localizations.localeOf(context);
    final state = item.stateAt(now);
    final cancelled = state == SessionState.cancelled;
    final title = item.title ?? item.group.name;
    final defaultMeta = [
      item.group.name,
      if (item.materialCount > 0) l10n.sessMetaMaterials(item.materialCount),
      if (item.homeworkCount > 0) l10n.sessMetaHomework,
      if (!item.hasContent && !cancelled) l10n.sessMetaGenerated,
    ].join(' · ');

    return Opacity(
      opacity: cancelled ? 0.6 : 1,
      child: ExecutiveCard(
        onTap: () => context.push(AppRoutes.sessionPath(item.id)),
        radius: RaeedRadius.lg + 2,
        borderColor: state == SessionState.noContent ? palette.warning : null,
        padding: const EdgeInsets.symmetric(
          horizontal: RaeedSpacing.md + 2,
          vertical: RaeedSpacing.sm + 4,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                clockTime(locale, item.startsAt),
                style: context.type
                    .tabular(context.type.label)
                    .copyWith(
                      color: palette.inkDim,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.type.label.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w700,
                      decoration: cancelled ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    meta ?? defaultMeta,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: RaeedSpacing.sm),
            SessionStateChip(item: item, now: now),
          ],
        ),
      ),
    );
  }
}

/// A material's kind, in a tinted square.
class MaterialKindTile extends StatelessWidget {
  const MaterialKindTile({required this.kind, this.size = 36, super.key});

  final MaterialKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final (label, background, foreground) = switch (kind) {
      MaterialKind.document => (
        l10n.matKindDocument,
        palette.dangerSoft,
        palette.danger,
      ),
      MaterialKind.image => (
        l10n.matKindImage,
        palette.successSoft,
        palette.success,
      ),
      MaterialKind.audio => (
        l10n.matKindAudio,
        palette.primarySoft,
        palette.primary,
      ),
      MaterialKind.video => (l10n.matKindVideo, palette.infoSoft, palette.info),
      MaterialKind.link => (
        l10n.matKindLink,
        palette.surfaceAlt,
        palette.inkDim,
      ),
    };
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(RaeedRadius.md),
      ),
      child: Text(
        label,
        style: context.type.caption.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

String visibilityLabel(AppL10n l10n, MaterialVisibility visibility) =>
    switch (visibility) {
      MaterialVisibility.beforeSession => l10n.visBefore,
      MaterialVisibility.afterSession => l10n.visAfter,
      MaterialVisibility.staffOnly => l10n.visStaff,
    };

ChipTone visibilityTone(MaterialVisibility visibility) => switch (visibility) {
  MaterialVisibility.beforeSession => ChipTone.success,
  MaterialVisibility.afterSession => ChipTone.info,
  MaterialVisibility.staffOnly => ChipTone.accent,
};

/// The bottom action bar every form on this surface ends with.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({required this.child, this.hint, super.key});

  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        RaeedSpacing.sm + 2,
        RaeedSpacing.lg,
        RaeedSpacing.md,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            child,
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: context.type.caption.copyWith(color: palette.inkDim),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A small field label above an input.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      text,
      style: context.type.caption.copyWith(
        color: context.palette.inkDim,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// A two- or three-way segmented control.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
    this.selectedColor,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelect;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final active = selectedColor ?? palette.primary;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: palette.border, width: 1.5),
        borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: Semantics(
                button: true,
                selected: value == selected,
                child: Material(
                  color: value == selected ? active : Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(value),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Center(
                        child: Text(
                          labelOf(value),
                          textAlign: TextAlign.center,
                          style: context.type.label.copyWith(
                            color: value == selected
                                ? palette.primaryOn
                                : palette.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A screen header with a back arrow, a title and a subtitle.
class EducatorPageHeader extends StatelessWidget {
  const EducatorPageHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.fallbackRoute = AppRoutes.home,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.sm,
        RaeedSpacing.xs,
        RaeedSpacing.md,
        RaeedSpacing.sm + 2,
      ),
      child: Row(
        children: [
          BackButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(fallbackRoute),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(color: palette.inkDim),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

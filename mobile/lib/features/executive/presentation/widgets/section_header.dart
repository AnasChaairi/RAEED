import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';

/// Back arrow, a screen title and an optional subtitle or trailing widget —
/// the header every More section shares.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.fallbackRoute = AppRoutes.more,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.sm,
        RaeedSpacing.xs,
        RaeedSpacing.md + 2,
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
                  style: context.type.h1.copyWith(color: palette.ink),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(color: palette.inkDim),
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

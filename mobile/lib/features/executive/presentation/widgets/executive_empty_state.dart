import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.gen.dart';
import '../../../../core/theme/raeed_theme.dart';

/// The two empty states the brief insists must not look alike.
enum EmptyStateKind {
  /// Nothing needs you. Green, calm.
  reassuring,

  /// This should not be empty — contact the association. Quiet, grey.
  dataProblem,
}

class ExecutiveEmptyState extends StatelessWidget {
  const ExecutiveEmptyState({
    required this.kind,
    required this.title,
    required this.body,
    this.action,
    super.key,
  });

  final EmptyStateKind kind;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reassuring = kind == EmptyStateKind.reassuring;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RaeedSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: reassuring ? palette.successSoft : palette.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                reassuring ? Icons.check_rounded : Icons.inbox_outlined,
                color: reassuring ? palette.success : palette.inkDim,
              ),
            ),
            const SizedBox(height: RaeedSpacing.md),
            Text(
              title,
              style: context.type.h3.copyWith(color: palette.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RaeedSpacing.xs),
            Text(
              body,
              style: context.type.bodySmall.copyWith(color: palette.inkDim),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: RaeedSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

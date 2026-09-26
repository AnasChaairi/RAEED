import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../executive/domain/announcement_draft.dart';
import '../../executive/presentation/announcements_tab.dart' show FilterPill;
import '../../executive/presentation/executive_providers.dart';
import 'widgets/session_widgets.dart';

/// EDU-M-09 — an announcement to the educator's own groups (`ANN-03`).
class EducatorAnnouncementScreen extends ConsumerStatefulWidget {
  const EducatorAnnouncementScreen({super.key});

  @override
  ConsumerState<EducatorAnnouncementScreen> createState() =>
      _EducatorAnnouncementScreenState();
}

class _EducatorAnnouncementScreenState
    extends ConsumerState<EducatorAnnouncementScreen> {
  Set<String> _groupIds = {};
  String _title = '';
  String _body = '';
  bool _ack = true;
  bool _sending = false;
  bool _seeded = false;

  Future<void> _publish(int reach) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    if (_groupIds.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.annPickGroup)));
      return;
    }
    if (_title.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(publishAnnouncementProvider)(
        AnnouncementDraft(
          title: _title,
          body: _body.trim().isEmpty ? null : _body,
          audience: AnnouncementAudience.groups(_groupIds),
          ackRequired: _ack,
        ),
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.annPublishedToast(reach))),
      );
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(AppRoutes.home);
      }
    } catch (error) {
      if (!mounted) return;
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
    final reach = ref.watch(audienceReachProvider).value;
    final groups = reach?.groups ?? const <AudienceCategory>[];
    if (!_seeded && groups.isNotEmpty) {
      _seeded = true;
      _groupIds = {groups.first.id};
    }
    final reachCount = groups
        .where((g) => _groupIds.contains(g.id))
        .fold<int>(0, (sum, g) => sum + g.guardianCount);

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          children: [
            EducatorPageHeader(title: l10n.annEduTitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(RaeedSpacing.lg),
                children: [
                  FieldLabel(l10n.annToGuardians),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final group in groups)
                        FilterPill(
                          label: group.name,
                          selected: _groupIds.contains(group.id),
                          onTap: () => setState(() {
                            final next = Set<String>.of(_groupIds);
                            if (!next.remove(group.id)) next.add(group.id);
                            _groupIds = next;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _groupIds.isEmpty
                        ? l10n.annPickGroup
                        : l10n.annReachGroups(reachCount),
                    style: context.type
                        .tabular(context.type.caption)
                        .copyWith(color: palette.inkDim),
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  FieldLabel(l10n.annFieldTitle),
                  TextField(
                    onChanged: (value) => setState(() => _title = value),
                    decoration: InputDecoration(
                      hintText: l10n.annTitleHint,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  FieldLabel(l10n.annFieldBody),
                  TextField(
                    onChanged: (value) => setState(() => _body = value),
                    minLines: 3,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: l10n.annBodyHint,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.md),
                  Semantics(
                    toggled: _ack,
                    child: Material(
                      color: palette.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RaeedRadius.lg),
                        side: BorderSide(
                          color: _ack ? palette.primary : palette.border,
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => setState(() => _ack = !_ack),
                        borderRadius: BorderRadius.circular(RaeedRadius.lg),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: RaeedSpacing.md + 2,
                            vertical: RaeedSpacing.sm + 2,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.annAckTitle,
                                      style: context.type.label.copyWith(
                                        color: palette.ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      l10n.annAckBody,
                                      style: context.type.caption.copyWith(
                                        color: palette.inkDim,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _ack,
                                onChanged: (value) =>
                                    setState(() => _ack = value),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: RaeedSpacing.sm + 2),
                  Text(
                    l10n.annUrgentExecOnly,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                ],
              ),
            ),
            BottomActionBar(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _sending ? null : () => _publish(reachCount),
                child: Text(l10n.annPublishCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

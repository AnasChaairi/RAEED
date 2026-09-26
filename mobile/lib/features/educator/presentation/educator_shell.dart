import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/raeed_theme.dart';
import 'educator_groups_tab.dart';
import 'educator_memories_tab.dart';
import 'educator_messages_tab.dart';
import 'educator_providers.dart';
import 'sessions_tab.dart';
import 'today_tab.dart';
import 'widgets/educator_nav_bar.dart';

/// The educator's home: five tabs under one nav bar (EDU-M-01..08).
class EducatorShell extends ConsumerStatefulWidget {
  const EducatorShell({this.initialTab, super.key});

  final EducatorTab? initialTab;

  @override
  ConsumerState<EducatorShell> createState() => _EducatorShellState();
}

class _EducatorShellState extends ConsumerState<EducatorShell> {
  @override
  void initState() {
    super.initState();
    _applyRequestedTab();
  }

  @override
  void didUpdateWidget(EducatorShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) _applyRequestedTab();
  }

  void _applyRequestedTab() {
    final requested = widget.initialTab;
    if (requested == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(educatorTabControllerProvider.notifier).select(requested);
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(educatorTabControllerProvider);
    final badges = ref.watch(educatorTabBadgesProvider);

    return Scaffold(
      backgroundColor: context.palette.bg,
      body: IndexedStack(
        index: current.index,
        children: const [
          TodayTab(),
          SessionsTab(),
          EducatorGroupsTab(),
          EducatorMessagesTab(),
          EducatorMemoriesTab(),
        ],
      ),
      bottomNavigationBar: EducatorNavBar(
        current: current,
        sessionsBadge: badges.sessions,
        messagesBadge: badges.messages,
        onSelect: (tab) =>
            ref.read(educatorTabControllerProvider.notifier).select(tab),
      ),
    );
  }
}

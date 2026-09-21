import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/raeed_theme.dart';
import 'announcements_tab.dart';
import 'dashboard_tab.dart';
import 'executive_providers.dart';
import 'groups_tab.dart';
import 'memories_tab.dart';
import 'messages_tab.dart';
import 'widgets/executive_nav_bar.dart';

/// The executive's home: five tabs under one bottom nav (`/dashboard`).
///
/// Tabs live in an [IndexedStack] so switching away from the Memories queue
/// and back does not lose the card under review, and each tab loads its own
/// data on first build rather than the shell loading everything at once.
class ExecutiveShell extends ConsumerStatefulWidget {
  const ExecutiveShell({this.initialTab, super.key});

  /// The tab a deep link asked for (`?tab=`), applied once on mount.
  final ExecutiveTab? initialTab;

  @override
  ConsumerState<ExecutiveShell> createState() => _ExecutiveShellState();
}

class _ExecutiveShellState extends ConsumerState<ExecutiveShell> {
  @override
  void initState() {
    super.initState();
    _applyRequestedTab();
  }

  @override
  void didUpdateWidget(ExecutiveShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) _applyRequestedTab();
  }

  void _applyRequestedTab() {
    final requested = widget.initialTab;
    if (requested == null) return;
    // After the frame: selecting during build would rebuild the shell
    // mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(executiveTabControllerProvider.notifier).select(requested);
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(executiveTabControllerProvider);
    final badges = ref.watch(executiveTabBadgesProvider);

    return Scaffold(
      backgroundColor: context.palette.bg,
      body: IndexedStack(
        index: current.index,
        children: const [
          DashboardTab(),
          AnnouncementsTab(),
          MessagesTab(),
          MemoriesTab(),
          GroupsTab(),
        ],
      ),
      bottomNavigationBar: ExecutiveNavBar(
        current: current,
        badges: badges,
        onSelect: (tab) =>
            ref.read(executiveTabControllerProvider.notifier).select(tab),
      ),
    );
  }
}

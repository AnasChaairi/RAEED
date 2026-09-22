import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/design_tokens.gen.dart';
import '../../../core/theme/raeed_theme.dart';
import '../../../shared/errors/failure_presenter.dart';
import '../../../shared/widgets/raeed_error_view.dart';
import '../domain/executive_child.dart' show AttendanceRatio;
import '../domain/reports.dart';
import 'announcements_tab.dart' show FilterPill;
import 'executive_providers.dart';
import 'widgets/executive_card.dart';
import 'widgets/executive_empty_state.dart';
import 'widgets/executive_skeletons.dart';
import 'widgets/section_header.dart';
import 'widgets/tone_chip.dart';

enum ReportTab { attendance, educators, engagement, export }

/// EXEC-M-11 — reports and the recorded export (`/reports`).
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportTab _tab = ReportTab.attendance;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: l10n.reportsTitle),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.lg),
              child: Row(
                children: [
                  for (final tab in ReportTab.values) ...[
                    FilterPill(
                      label: switch (tab) {
                        ReportTab.attendance => l10n.repTabAttendance,
                        ReportTab.educators => l10n.repTabEducators,
                        ReportTab.engagement => l10n.repTabEngagement,
                        ReportTab.export => l10n.repTabExport,
                      },
                      selected: _tab == tab,
                      onTap: () => setState(() => _tab = tab),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: RaeedSpacing.sm + 2),
            Expanded(
              child: switch (_tab) {
                ReportTab.attendance => const _AttendanceTab(),
                ReportTab.educators => const _EducatorsTab(),
                ReportTab.engagement => const _EngagementTab(),
                ReportTab.export => const ExportTab(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A named rate with its raw pair and a bar — never a percent alone.
class RateBar extends StatelessWidget {
  const RateBar({
    required this.name,
    required this.ratio,
    this.muted = false,
    super.key,
  });

  final String name;
  final AttendanceRatio ratio;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final percent = ratio.percent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: context.type.caption.copyWith(color: palette.ink),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: percent == null ? '—' : '$percent%',
                      style: context.type
                          .tabular(context.type.caption)
                          .copyWith(
                            color: palette.ink,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    TextSpan(
                      text: ' (${ratio.present}/${ratio.expected})',
                      style: context.type
                          .tabular(context.type.caption)
                          .copyWith(color: palette.inkDim),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percent ?? 0) / 100,
              minHeight: 8,
              backgroundColor: palette.surfaceAlt,
              color: muted ? palette.inkDim : palette.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final report = ref.watch(attendanceReportProvider);
    return report.when(
      loading: () => const SkeletonCardList(count: 2, height: 160),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(attendanceReportProvider),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.fromLTRB(
          RaeedSpacing.lg,
          0,
          RaeedSpacing.lg,
          RaeedSpacing.xl2,
        ),
        children: [
          ExecutiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.repByEducator,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (data.byEducator.isEmpty)
                  Text(
                    l10n.repNoData,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                for (final row in data.byEducator)
                  RateBar(name: row.name, ratio: row.ratio),
              ],
            ),
          ),
          const SizedBox(height: RaeedSpacing.sm + 2),
          ExecutiveCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.repByCategory,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.repRawNote,
                  style: context.type.caption.copyWith(color: palette.inkDim),
                ),
                if (data.byCategory.isEmpty)
                  Text(
                    l10n.repNoData,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                // A tiny denominator is drawn muted: its percentage says little.
                for (final row in data.byCategory)
                  RateBar(
                    name: row.name,
                    ratio: row.ratio,
                    muted: row.ratio.expected < 10,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EducatorsTab extends ConsumerWidget {
  const _EducatorsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final rows = ref.watch(educatorActivityProvider);
    return rows.when(
      loading: () => const SkeletonCardList(count: 3, height: 80),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(educatorActivityProvider),
      ),
      data: (list) => list.isEmpty
          ? ExecutiveEmptyState(
              kind: EmptyStateKind.dataProblem,
              title: l10n.repNoData,
              body: '',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                RaeedSpacing.lg,
                0,
                RaeedSpacing.lg,
                RaeedSpacing.xl2,
              ),
              itemCount: list.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: RaeedSpacing.sm),
              itemBuilder: (_, index) {
                final e = list[index];
                final (icon, color) = e.onTimeShare >= 0.99
                    ? (Icons.check_rounded, palette.success)
                    : e.onTimeShare >= 0.6
                    ? (Icons.schedule_rounded, palette.warning)
                    : (Icons.priority_high_rounded, palette.danger);
                return ExecutiveCard(
                  radius: RaeedRadius.lg + 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: RaeedSpacing.md + 2,
                    vertical: RaeedSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.displayName,
                              style: context.type.label.copyWith(
                                color: palette.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(icon, size: 18, color: color),
                        ],
                      ),
                      const SizedBox(height: RaeedSpacing.xs),
                      Wrap(
                        spacing: RaeedSpacing.sm + 2,
                        children: [
                          Text(
                            l10n.repPlanned(e.delivered, e.planned),
                            style: context.type
                                .tabular(context.type.caption)
                                .copyWith(color: palette.inkDim),
                          ),
                          Text(
                            l10n.repOnTime(e.markedOnTime, e.planned),
                            style: context.type
                                .tabular(context.type.caption)
                                .copyWith(color: palette.inkDim),
                          ),
                          Text(
                            l10n.repReplyUnknown,
                            style: context.type.caption.copyWith(
                              color: palette.inkDim,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _EngagementTab extends ConsumerWidget {
  const _EngagementTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final report = ref.watch(engagementReportProvider);

    Widget tile(String label, AttendanceRatio? ratio, {Widget? tag}) =>
        ExecutiveCard(
          radius: RaeedRadius.lg + 2,
          padding: const EdgeInsets.symmetric(
            horizontal: RaeedSpacing.lg,
            vertical: RaeedSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: context.type.caption.copyWith(color: palette.inkDim),
                  ),
                  if (tag != null) ...[const SizedBox(width: 6), tag],
                ],
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: ratio == null
                          ? l10n.repNotYet
                          : ratio.percent == null
                          ? '—'
                          : '${ratio.percent}% ',
                      style: ratio == null
                          ? context.type.bodySmall.copyWith(
                              color: palette.inkDim,
                            )
                          : context.type
                                .tabular(context.type.h1)
                                .copyWith(color: palette.ink),
                    ),
                    if (ratio != null)
                      TextSpan(
                        text: '(${ratio.present}/${ratio.expected})',
                        style: context.type
                            .tabular(context.type.caption)
                            .copyWith(color: palette.inkDim),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

    return report.when(
      loading: () => const SkeletonCardList(count: 3, height: 90),
      error: (error, _) => RaeedErrorView(
        error: error,
        onRetry: () => ref.invalidate(engagementReportProvider),
      ),
      data: (data) => ListView(
        padding: const EdgeInsets.fromLTRB(
          RaeedSpacing.lg,
          0,
          RaeedSpacing.lg,
          RaeedSpacing.xl2,
        ),
        children: [
          tile(l10n.repActivated, data.guardiansActivated),
          const SizedBox(height: RaeedSpacing.sm),
          tile(l10n.repPresenceAnswers, data.presenceAnswers),
          const SizedBox(height: RaeedSpacing.sm),
          tile(
            l10n.repHomework,
            null,
            tag: ToneChip(label: l10n.selfReported, tone: ChipTone.accent),
          ),
        ],
      ),
    );
  }
}

/// Field checkboxes, the health flag, and the file handed to the share
/// sheet once the server has built and recorded it.
class ExportTab extends ConsumerStatefulWidget {
  const ExportTab({this.share, super.key});

  /// Hands the file to the platform; injectable so tests do not open a sheet.
  final Future<void> Function(ExportFile file)? share;

  @override
  ConsumerState<ExportTab> createState() => _ExportTabState();
}

enum _ExportState { idle, busy, ready }

class _ExportTabState extends ConsumerState<ExportTab> {
  Set<ExportField> _fields = Set.of(defaultExportFields);
  _ExportState _state = _ExportState.idle;
  ExportFile? _file;

  Future<void> _start() async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _state = _ExportState.busy);
    try {
      final file = await ref.read(reportsRepositoryProvider).export(_fields);
      if (!mounted) return;
      setState(() {
        _file = file;
        _state = _ExportState.ready;
      });
      messenger.showSnackBar(
        SnackBar(content: Text('⦿ ${l10n.exportLoggedToast}')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _state = _ExportState.idle);
      messenger.showSnackBar(
        SnackBar(content: Text(presentFailure(error, l10n).body)),
      );
    }
  }

  Future<void> _share() async {
    final file = _file;
    if (file == null) return;
    final share = widget.share ?? _shareViaPlatform;
    await share(file);
  }

  static Future<void> _shareViaPlatform(ExportFile file) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${file.filename}';
    await File(path).writeAsString(file.content, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path, mimeType: 'text/csv')]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final containsHealth = exportContainsHealth(_fields);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RaeedSpacing.lg,
        0,
        RaeedSpacing.lg,
        RaeedSpacing.xl2,
      ),
      children: [
        Text(
          l10n.exportIntro,
          style: context.type.caption.copyWith(color: palette.inkDim),
        ),
        const SizedBox(height: RaeedSpacing.sm),
        for (final field in ExportField.values) ...[
          _FieldRow(
            field: field,
            label: _fieldLabel(l10n, field),
            selected: _fields.contains(field),
            onTap: () => setState(() {
              final next = Set<ExportField>.of(_fields);
              if (!next.remove(field)) next.add(field);
              _fields = next;
              _state = _ExportState.idle;
            }),
          ),
          const SizedBox(height: 6),
        ],
        const SizedBox(height: RaeedSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RaeedSpacing.md,
            vertical: RaeedSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⦿ ${l10n.exportLogged}',
                style: context.type.caption.copyWith(color: palette.ink),
              ),
              if (containsHealth)
                Text(
                  l10n.exportContainsHealth,
                  style: context.type.caption.copyWith(
                    color: palette.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: RaeedSpacing.sm + 2),
        switch (_state) {
          _ExportState.idle => FilledButton(
            onPressed: _fields.isEmpty ? null : _start,
            child: Text(l10n.exportCta(_fields.length)),
          ),
          _ExportState.busy => ExecutiveCard(
            radius: RaeedRadius.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.exportBusy,
                  style: context.type.label.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: RaeedSpacing.sm),
                const LinearProgressIndicator(minHeight: 8),
              ],
            ),
          ),
          _ExportState.ready => ExecutiveCard(
            radius: RaeedRadius.lg,
            color: palette.successSoft,
            borderColor: palette.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '✓ ${l10n.exportReady}',
                  style: context.type.label.copyWith(
                    color: palette.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_file!.filename} · ${l10n.exportRows(_file!.rowCount)}',
                  style: context.type
                      .tabular(context.type.caption)
                      .copyWith(color: palette.inkDim),
                ),
                const SizedBox(height: RaeedSpacing.sm + 2),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(RaeedTouchTarget.minPx),
                  ),
                  onPressed: _share,
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: Text(l10n.exportShare),
                ),
              ],
            ),
          ),
        },
      ],
    );
  }

  static String _fieldLabel(AppL10n l10n, ExportField field) => switch (field) {
    ExportField.name => l10n.exportName,
    ExportField.dob => l10n.exportDob,
    ExportField.group => l10n.exportGroup,
    ExportField.guardian => l10n.exportGuardian,
    ExportField.phone => l10n.exportPhone,
    ExportField.consent => l10n.exportConsent,
    ExportField.allergies => l10n.exportAllergies,
    ExportField.medications => l10n.exportMedications,
  };
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.field,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ExportField field;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppL10n.of(context);
    final accent = field.isHealth ? palette.danger : palette.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? (field.isHealth ? palette.dangerSoft : palette.primarySoft)
            : palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
          side: BorderSide(
            color: selected ? accent : palette.border,
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaeedRadius.md + 2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 46),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RaeedSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: selected ? accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: selected ? accent : palette.inkDim,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: palette.surface,
                          )
                        : null,
                  ),
                  const SizedBox(width: RaeedSpacing.sm + 2),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        label,
                        style: context.type.bodySmall.copyWith(
                          color: palette.ink,
                        ),
                      ),
                    ),
                  ),
                  if (field.isHealth)
                    ExcludeSemantics(
                      child: ToneChip(
                        label: l10n.healthTag,
                        tone: ChipTone.danger,
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

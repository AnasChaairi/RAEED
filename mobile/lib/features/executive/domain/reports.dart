import 'package:meta/meta.dart';

import 'executive_child.dart' show AttendanceRatio;

/// One bar of a rate report: a name with its raw present/expected pair.
@immutable
class RateRow {
  const RateRow({required this.id, required this.name, required this.ratio});

  final String id;
  final String name;
  final AttendanceRatio ratio;
}

@immutable
class AttendanceReport {
  const AttendanceReport({required this.byEducator, required this.byCategory});

  final List<RateRow> byEducator;
  final List<RateRow> byCategory;
}

@immutable
class EducatorActivity {
  const EducatorActivity({
    required this.id,
    required this.displayName,
    required this.planned,
    required this.delivered,
    required this.markedOnTime,
    this.replyMinutes,
  });

  final String id;
  final String displayName;
  final int planned;
  final int delivered;
  final int markedOnTime;

  /// Null until messaging keeps it.
  final int? replyMinutes;

  /// Green when every session was marked on time, amber when most, red
  /// otherwise — colour never alone, the numbers sit beside it.
  double get onTimeShare => planned == 0 ? 1 : markedOnTime / planned;
}

@immutable
class EngagementReport {
  const EngagementReport({
    required this.guardiansActivated,
    required this.presenceAnswers,
    this.homeworkDoneRate,
  });

  final AttendanceRatio guardiansActivated;
  final AttendanceRatio presenceAnswers;

  /// Self-reported, and null until homework exists.
  final int? homeworkDoneRate;
}

/// The columns an export may carry.
enum ExportField {
  name('name'),
  dob('dob'),
  group('group'),
  guardian('guardian'),
  phone('phone'),
  consent('consent'),
  allergies('allergies', isHealth: true),
  medications('medications', isHealth: true);

  const ExportField(this.wireValue, {this.isHealth = false});

  final String wireValue;

  /// Off by default and flagged: this column carries health information.
  final bool isHealth;
}

/// The default selection: identity and group, nothing sensitive.
const Set<ExportField> defaultExportFields = {
  ExportField.name,
  ExportField.dob,
  ExportField.group,
  ExportField.guardian,
  ExportField.consent,
};

/// Whether a selection carries health information.
bool exportContainsHealth(Set<ExportField> fields) =>
    fields.any((field) => field.isHealth);

/// The file the server built.
@immutable
class ExportFile {
  const ExportFile({
    required this.filename,
    required this.content,
    required this.fields,
    required this.containsHealth,
    required this.rowCount,
    required this.createdAt,
  });

  final String filename;

  /// UTF-8 CSV text.
  final String content;
  final List<ExportField> fields;
  final bool containsHealth;
  final int rowCount;
  final DateTime createdAt;
}

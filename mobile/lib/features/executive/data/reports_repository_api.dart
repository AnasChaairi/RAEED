import '../../../core/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../domain/executive_child.dart' show AttendanceRatio;
import '../domain/reports.dart';
import '../domain/reports_repository.dart';
import 'wire_helpers.dart';

RateRow rateRowFromJson(Map<String, Object?> json) => RateRow(
  id: stringOrNull(json['id']) ?? '',
  name: stringOrNull(json['name']) ?? '',
  ratio: AttendanceRatio(
    present: intOrNull(json['present']) ?? 0,
    expected: intOrNull(json['expected']) ?? 0,
  ),
);

EducatorActivity educatorActivityFromJson(Map<String, Object?> json) =>
    EducatorActivity(
      id: requireField<String>(json, 'id'),
      displayName: stringOrNull(json['display_name']) ?? '',
      planned: intOrNull(json['planned']) ?? 0,
      delivered: intOrNull(json['delivered']) ?? 0,
      markedOnTime: intOrNull(json['marked_on_time']) ?? 0,
      replyMinutes: intOrNull(json['reply_minutes']),
    );

AttendanceRatio _pair(Object? value) {
  final json = objectOrNull(value) ?? const {};
  return AttendanceRatio(
    present: intOrNull(json['count']) ?? 0,
    expected: intOrNull(json['total']) ?? 0,
  );
}

const Map<String, ExportField> _exportFieldByWire = {
  'name': ExportField.name,
  'dob': ExportField.dob,
  'group': ExportField.group,
  'guardian': ExportField.guardian,
  'phone': ExportField.phone,
  'consent': ExportField.consent,
  'allergies': ExportField.allergies,
  'medications': ExportField.medications,
};

/// [ReportsRepository] against `/reports`.
class ApiReportsRepository implements ReportsRepository {
  const ApiReportsRepository(this._client);

  final ApiClient _client;

  @override
  Future<AttendanceReport> fetchAttendance() async {
    final json = await _client.getObject('/reports/attendance');
    return AttendanceReport(
      byEducator: objectList(
        json['by_educator'],
        field: 'by_educator',
      ).map(rateRowFromJson).toList(growable: false),
      byCategory: objectList(
        json['by_category'],
        field: 'by_category',
      ).map(rateRowFromJson).toList(growable: false),
    );
  }

  @override
  Future<List<EducatorActivity>> fetchEducators() async =>
      (await _client.getList<EducatorActivity>(
        '/reports/educators',
        educatorActivityFromJson,
      )).items;

  @override
  Future<EngagementReport> fetchEngagement() async {
    final json = await _client.getObject('/reports/engagement');
    return EngagementReport(
      guardiansActivated: _pair(json['guardians_activated']),
      presenceAnswers: _pair(json['presence_answers']),
      homeworkDoneRate: intOrNull(json['homework_done_rate']),
    );
  }

  @override
  Future<ExportFile> export(Set<ExportField> fields) async {
    final json = await _client.post(
      '/reports/exports',
      body: {
        'fields': [
          for (final field in ExportField.values)
            if (fields.contains(field)) field.wireValue,
        ],
      },
    );
    return ExportFile(
      filename: stringOrNull(json['filename']) ?? 'export.csv',
      content: requireField<String>(json, 'content'),
      fields: [
        for (final wire in stringList(json['fields']))
          if (_exportFieldByWire[wire] case final ExportField field) field,
      ],
      containsHealth: boolOr(json['contains_health'], false),
      rowCount: intOrNull(json['row_count']) ?? 0,
      createdAt: requireDateTime(json, 'created_at'),
    );
  }
}

import 'package:meta/meta.dart';

enum SeasonStatus { active, archived }

@immutable
class Season {
  const Season({
    required this.id,
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.groupCount,
    required this.childCount,
  });

  final String id;
  final String label;
  final DateTime startDate;
  final DateTime endDate;
  final SeasonStatus status;
  final int groupCount;
  final int childCount;
}

/// `category_gender` from the schema.
enum CategoryGender { boys, girls, mixed }

/// A فئة, with its age range and gender as stored — null until the board
/// decides (open decision #1).
@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.childCount,
    required this.groupCount,
    this.minAge,
    this.maxAge,
    this.gender,
  });

  final String id;
  final String name;
  final int? minAge;
  final int? maxAge;
  final CategoryGender? gender;
  final int childCount;
  final int groupCount;

  bool get isRangeSet => minAge != null || maxAge != null || gender != null;
}

@immutable
class Branch {
  const Branch({
    required this.id,
    required this.name,
    this.address,
    this.executiveNames = const [],
  });

  final String id;
  final String name;
  final String? address;
  final List<String> executiveNames;
}

/// One line of the audit log.
@immutable
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.at,
    required this.action,
    required this.resourceType,
    required this.actorName,
    this.actorId,
    this.actorRole,
    this.resourceId,
    this.resourceLabel,
    this.deviceMeta = const {},
  });

  final String id;
  final DateTime at;
  final String? actorId;
  final String actorName;
  final String? actorRole;
  final String action;
  final String resourceType;
  final String? resourceId;
  final String? resourceLabel;
  final Map<String, Object?> deviceMeta;

  /// The health-access view's rows.
  bool get isHealthView => action == 'child.health_view';
}

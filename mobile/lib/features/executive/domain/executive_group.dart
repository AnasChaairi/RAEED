import 'package:meta/meta.dart';

/// A group as the executive's list shows it.
@immutable
class ExecutiveGroup {
  const ExecutiveGroup({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.enrolledCount,
    this.capacity,
    this.educatorNames = const [],
    this.scheduleLabel,
    this.place,
    this.stats,
  });

  final String id;
  final String name;

  /// The فئة this group belongs to.
  final String categoryName;

  final int enrolledCount;

  /// `group.capacity` — nullable in the schema, so unknown is representable.
  final int? capacity;

  final List<String> educatorNames;

  /// "السبت 10:00", already rendered by the server from `weekly_schedule_json`.
  final String? scheduleLabel;

  /// The usual room.
  final String? place;

  /// The educator's at-a-glance numbers (EDU-M-06); absent on oversight lists.
  final GroupStats? stats;

  /// Whether more children are enrolled than the group was sized for.
  ///
  /// A warning, not a danger: it is a planning problem, not a missing child.
  bool get isOverCapacity => capacity != null && enrolledCount > capacity!;
}

/// `session_status` from `specs/03-domain-model/schema.sql`.
enum SessionStatus {
  planned('planned'),
  delivered('delivered'),
  cancelled('cancelled');

  const SessionStatus(this.wireValue);

  final String wireValue;
}

/// One session in a group's list.
@immutable
class GroupSession {
  const GroupSession({
    required this.id,
    required this.groupId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.attendanceRecorded,
    this.title,
    this.presentCount,
    this.enrolledCount,
  });

  final String id;
  final String groupId;
  final DateTime startsAt;
  final DateTime endsAt;
  final SessionStatus status;

  /// Whether any attendance record exists yet.
  final bool attendanceRecorded;

  final String? title;

  /// Present-or-late marks, when attendance was recorded.
  final int? presentCount;

  /// Children expected, when attendance was recorded.
  final int? enrolledCount;
}

/// A child with three consecutive unexplained absences — a care flag.
@immutable
class CareFlag {
  const CareFlag({
    required this.childId,
    required this.fullName,
    required this.consecutiveAbsences,
  });

  final String childId;
  final String fullName;
  final int consecutiveAbsences;
}

/// The numbers on the educator's group card.
@immutable
class GroupStats {
  const GroupStats({
    required this.present,
    required this.expected,
    required this.homeworkDone,
    required this.homeworkTotal,
    this.nextSessionAt,
    this.flags = const [],
  });

  final int present;
  final int expected;
  final int homeworkDone;
  final int homeworkTotal;
  final DateTime? nextSessionAt;
  final List<CareFlag> flags;

  int? get attendancePercent =>
      expected == 0 ? null : (present * 100 / expected).round();
  int? get homeworkPercent =>
      homeworkTotal == 0 ? null : (homeworkDone * 100 / homeworkTotal).round();
}

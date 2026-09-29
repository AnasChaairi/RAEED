import 'package:meta/meta.dart';

import 'session_kind.dart';

/// One entry of a child's schedule, as the guardian sees it: when, what
/// kind, what it is about, where. No educator working state here.
@immutable
class ChildSession {
  const ChildSession({
    required this.id,
    required this.kind,
    required this.startsAt,
    required this.endsAt,
    required this.isCancelled,
    this.title,
    this.place,
  });

  final String id;
  final SessionKind kind;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isCancelled;
  final String? title;
  final String? place;
}

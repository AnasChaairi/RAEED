import 'package:meta/meta.dart';

/// How far a child has got through today's session.
///
/// One closed set covering both halves of the weekly cycle in
/// `specs/02-architecture.md` — the presence confirmation a parent answers
/// *before* the session, and the attendance an educator marks *during* it.
/// They are modelled together because the home card shows one pill, and which
/// half it is reading from is exactly what the parent needs to see.
enum DayStatusKind {
  /// No session scheduled today. The quietest state, and the common one.
  noSession,

  /// A presence confirmation is open and nobody has answered it yet.
  ///
  /// `specs/06-mobile-app-spec.md`: an unanswered confirmation surfaces on the
  /// home card itself so it survives a missed push.
  awaitingPresenceAnswer,

  /// A guardian answered "yes" — the child is expected.
  presenceConfirmed,

  /// A guardian declared the child absent in advance (`ATT-04`).
  presenceDeclined,

  /// A guardian warned the child will be late.
  presenceLate,

  /// Marked present.
  present,

  /// Marked late.
  late,

  /// Marked absent.
  absent,

  /// Marked absent with an accepted excuse.
  excused,

  /// The server sent a status this build predates.
  ///
  /// Rendered neutrally rather than crashing — a new `attendance_status` must
  /// not take down a parent's home screen.
  unknown,
}

/// How long an absence alert stays "fresh" on the home card.
///
/// `specs/06-mobile-app-spec.md`: "a fresh absence alert overrides the status
/// pill to a high-contrast alert state". Six hours covers a session and the
/// rest of the afternoon, so a parent who opens the app after work still sees
/// it — while yesterday's resolved alert does not shout at them on a morning
/// where nothing is wrong.
const Duration absenceAlertFreshness = Duration(hours: 6);

/// Today's status for one child, as the home card needs it.
@immutable
class ChildDayStatus {
  const ChildDayStatus({required this.kind, this.alertRaisedAt});

  /// The quiet default: nothing scheduled, nothing to report.
  const ChildDayStatus.noSession() : kind = DayStatusKind.noSession, alertRaisedAt = null;

  /// Which state today is in.
  final DayStatusKind kind;

  /// When the critical-alert pipeline (`RAEED-18`) raised an absence alert for
  /// this child today, in UTC. Null when no alert was raised.
  final DateTime? alertRaisedAt;

  /// Whether the pill should take its high-contrast alert form.
  ///
  /// Requires both an unexplained absence *and* a recent alert: a child marked
  /// absent after their guardian already declared them absent is not an alert,
  /// it is the system working. That distinction is the whole point of the
  /// critical-alert rule in `specs/11-testing-strategy.md` (case 2), so the
  /// pill must not re-derive it from the status alone.
  bool isFreshAlertAt(DateTime now) {
    final raisedAt = alertRaisedAt;
    if (raisedAt == null) return false;
    if (kind != DayStatusKind.absent) return false;
    final age = now.toUtc().difference(raisedAt.toUtc());
    return !age.isNegative && age <= absenceAlertFreshness;
  }

  /// Whether a guardian still owes an answer to today's presence confirmation.
  bool get needsPresenceAnswer => kind == DayStatusKind.awaitingPresenceAnswer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildDayStatus &&
          other.kind == kind &&
          other.alertRaisedAt == alertRaisedAt;

  @override
  int get hashCode => Object.hash(kind, alertRaisedAt);
}

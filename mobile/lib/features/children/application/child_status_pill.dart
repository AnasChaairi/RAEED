import 'package:meta/meta.dart';

import '../domain/child.dart';
import '../domain/child_day_status.dart';

/// The colour role a status pill takes.
///
/// Names the *meaning*, not the colour: the widget maps these onto
/// `context.palette`, so the design tokens stay the only source of colour and
/// this file stays testable without a `BuildContext`.
enum StatusPillTone {
  /// Nothing is happening today. The quietest treatment.
  neutral,

  /// Informational — the child is expected.
  info,

  /// Something is owed by the user, or the child was late.
  attention,

  /// Confirmed good: present.
  positive,

  /// An absence that has been explained.
  muted,

  /// An unexplained absence. Reserved for the alert state.
  critical,
}

/// A resolved status pill: what to say, in which tone, and how loudly.
@immutable
class StatusPill {
  const StatusPill({
    required this.kind,
    required this.tone,
    required this.isAlert,
    required this.isActionable,
  });

  /// The underlying state, which the widget turns into a localized label.
  final DayStatusKind kind;

  /// The colour role.
  final StatusPillTone tone;

  /// Whether this is the high-contrast absence-alert form.
  ///
  /// `specs/06-mobile-app-spec.md`: "a fresh absence alert overrides the status
  /// pill to a high-contrast alert state".
  final bool isAlert;

  /// Whether tapping the pill leads somewhere useful.
  ///
  /// True for a pending presence confirmation (tap → answer it) and for an
  /// alert (tap → the attendance detail that explains it). False for a quiet
  /// day: a pill that looks tappable and does nothing is worse than a label.
  final bool isActionable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusPill &&
          other.kind == kind &&
          other.tone == tone &&
          other.isAlert == isAlert &&
          other.isActionable == isActionable;

  @override
  int get hashCode => Object.hash(kind, tone, isAlert, isActionable);
}

/// Resolves the pill for [child] as of [now].
///
/// A pure function of the child's state and the clock, so the alert-override
/// rule can be tested directly rather than inferred from a rendered widget.
///
/// The override is checked *first*: a fresh, unexplained absence outranks
/// everything else the card could say, which is the entire reason the alert
/// pipeline in `specs/02-architecture.md` exists.
StatusPill resolveStatusPill(Child child, DateTime now) {
  final status = child.todayStatus;

  if (status.isFreshAlertAt(now)) {
    return const StatusPill(
      kind: DayStatusKind.absent,
      tone: StatusPillTone.critical,
      isAlert: true,
      isActionable: true,
    );
  }

  return switch (status.kind) {
    DayStatusKind.noSession => const StatusPill(
      kind: DayStatusKind.noSession,
      tone: StatusPillTone.neutral,
      isAlert: false,
      isActionable: false,
    ),
    DayStatusKind.awaitingPresenceAnswer => const StatusPill(
      kind: DayStatusKind.awaitingPresenceAnswer,
      tone: StatusPillTone.attention,
      isAlert: false,
      isActionable: true,
    ),
    DayStatusKind.presenceConfirmed => const StatusPill(
      kind: DayStatusKind.presenceConfirmed,
      tone: StatusPillTone.info,
      isAlert: false,
      isActionable: true,
    ),
    DayStatusKind.presenceDeclined => const StatusPill(
      kind: DayStatusKind.presenceDeclined,
      tone: StatusPillTone.muted,
      isAlert: false,
      isActionable: true,
    ),
    DayStatusKind.presenceLate => const StatusPill(
      kind: DayStatusKind.presenceLate,
      tone: StatusPillTone.attention,
      isAlert: false,
      isActionable: true,
    ),
    DayStatusKind.present => const StatusPill(
      kind: DayStatusKind.present,
      tone: StatusPillTone.positive,
      isAlert: false,
      isActionable: true,
    ),
    DayStatusKind.late => const StatusPill(
      kind: DayStatusKind.late,
      tone: StatusPillTone.attention,
      isAlert: false,
      isActionable: true,
    ),
    // Absent without a fresh alert: either the alert has aged out, or a
    // guardian had already declared the absence, in which case there was never
    // an alert to raise. Still serious enough to stand out, but not shouting.
    DayStatusKind.absent => const StatusPill(
      kind: DayStatusKind.absent,
      tone: StatusPillTone.critical,
      isAlert: false,
      isActionable: true,
    ),
    DayStatusKind.excused => const StatusPill(
      kind: DayStatusKind.excused,
      tone: StatusPillTone.muted,
      isAlert: false,
      isActionable: true,
    ),
    DayStatusKind.unknown => const StatusPill(
      kind: DayStatusKind.unknown,
      tone: StatusPillTone.neutral,
      isAlert: false,
      isActionable: false,
    ),
  };
}

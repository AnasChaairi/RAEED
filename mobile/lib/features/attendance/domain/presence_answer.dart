/// `presence_answer_value` from `specs/03-domain-model/schema.sql`.
enum PresenceAnswerValue {
  /// The child will attend.
  yes('yes'),

  /// The child will not attend — a declared absence (`ATT-04`).
  no('no'),

  /// The child will attend, late.
  late('late');

  const PresenceAnswerValue(this.wireValue);

  /// The exact string the API uses.
  final String wireValue;

  /// Resolves a wire value, or null when unrecognised.
  static PresenceAnswerValue? fromWire(String? value) {
    if (value == null) return null;
    for (final answer in PresenceAnswerValue.values) {
      if (answer.wireValue == value) return answer;
    }
    return null;
  }
}

/// `absence_reason` from `specs/03-domain-model/schema.sql`.
///
/// A closed set, offered as chips, precisely so a guardian answering a push at
/// 7am never has to type. [other] is the only value that asks for text, and it
/// exists so the set can stay closed rather than growing a long tail.
enum AbsenceReason {
  /// Illness.
  illness('illness'),

  /// Travel.
  travel('travel'),

  /// An exam.
  exam('exam'),

  /// Anything else — the one option that accepts a free-text note.
  other('other');

  const AbsenceReason(this.wireValue);

  /// The exact string the API uses.
  final String wireValue;

  /// Whether choosing this reason should reveal a text field.
  bool get needsNote => this == AbsenceReason.other;

  /// Resolves a wire value, or null when unrecognised.
  static AbsenceReason? fromWire(String? value) {
    if (value == null) return null;
    for (final reason in AbsenceReason.values) {
      if (reason.wireValue == value) return reason;
    }
    return null;
  }
}

/// One guardian's answer for one child, as this device holds it.
///
/// Immutable and pure: it is built at the moment of the tap, queued, and sent
/// unchanged. Nothing in here is recomputed at sync time.
class PresenceAnswerDraft {
  const PresenceAnswerDraft({
    required this.confirmationId,
    required this.childId,
    required this.answer,
    this.reason,
    this.note,
  });

  /// `presence_confirmation.id` this answers.
  final String confirmationId;

  /// The child the answer is about.
  final String childId;

  /// Yes, no, or late.
  final PresenceAnswerValue answer;

  /// The reason, when the answer is not [PresenceAnswerValue.yes].
  final AbsenceReason? reason;

  /// Free text, only ever set alongside [AbsenceReason.other].
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresenceAnswerDraft &&
          other.confirmationId == confirmationId &&
          other.childId == childId &&
          other.answer == answer &&
          other.reason == reason &&
          other.note == note;

  @override
  int get hashCode =>
      Object.hash(confirmationId, childId, answer, reason, note);
}

/// A confirmation this device knows about and the guardian has not answered.
///
/// Surfaced on the Home card as well as by push, so a confirmation survives a
/// notification that never arrived (`specs/06-mobile-app-spec.md`: "an
/// unanswered confirmation also surfaces on the Home card itself so it survives
/// a missed push").
class PendingPresenceConfirmation {
  const PendingPresenceConfirmation({
    required this.confirmationId,
    required this.sessionId,
    required this.childId,
    required this.childName,
    required this.sessionStartsAt,
    this.groupName,
    this.deadlineAt,
  });

  /// `presence_confirmation.id`.
  final String confirmationId;

  /// The session being confirmed.
  final String sessionId;

  /// The child the question is about.
  final String childId;

  /// The child's display name.
  final String childName;

  /// When the session starts (UTC).
  final DateTime sessionStartsAt;

  /// The group's name, for the card's subtitle.
  final String? groupName;

  /// `presence_confirmation.deadline_at`, when the server set one.
  final DateTime? deadlineAt;
}

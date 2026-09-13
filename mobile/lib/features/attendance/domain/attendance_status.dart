/// `attendance_status` from `specs/03-domain-model/schema.sql`.
///
/// The order of the constants is the order the marking buttons appear in, and
/// that order is a product decision, not an alphabetical accident: `present`
/// comes first because it is overwhelmingly the common case and the sheet
/// arrives pre-filled from presence answers, and `absent` sits after `late`
/// because reaching it can page a parent. `excused` is last and has no button
/// of its own — it is an excuse accepted afterwards, not a mark made while
/// walking a hall.
enum AttendanceStatus {
  /// The child is here.
  present('present'),

  /// Here, but after the session started.
  late('late'),

  /// Not here, with no accepted excuse recorded.
  ///
  /// This is the status that feeds the critical-alert pipeline. Whether a
  /// particular `absent` mark actually alerts is decided server-side against
  /// the child's presence answers (`specs/02-architecture.md`) — the app
  /// records the mark and does not attempt that judgement.
  absent('absent'),

  /// Not here, excused.
  excused('excused');

  const AttendanceStatus(this.wireValue);

  /// The exact string the API uses.
  final String wireValue;

  /// Resolves a wire value, or null when the server sent something this build
  /// predates.
  static AttendanceStatus? fromWire(String? value) {
    if (value == null) return null;
    for (final status in AttendanceStatus.values) {
      if (status.wireValue == value) return status;
    }
    return null;
  }

}

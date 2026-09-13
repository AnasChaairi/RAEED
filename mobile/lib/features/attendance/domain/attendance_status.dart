/// `attendance_status` from `specs/03-domain-model/schema.sql`.
///
/// The order of the constants is the order the one-tap chip cycles through, and
/// that order is a product decision, not an alphabetical accident — see
/// [AttendanceStatus.next].
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

  /// The next status in the one-tap cycle: present → late → absent → excused →
  /// present.
  ///
  /// `present` comes first because it is overwhelmingly the common case and the
  /// sheet arrives pre-filled from presence answers; `absent` sits third so it
  /// takes a deliberate number of taps to reach, since reaching it can page a
  /// parent. `excused` follows `absent` because the correction an educator
  /// makes most often is "absent, but actually excused".
  AttendanceStatus get next =>
      AttendanceStatus.values[(index + 1) % AttendanceStatus.values.length];
}

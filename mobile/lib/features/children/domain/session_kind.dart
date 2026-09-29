/// What a session is: the weekly حصة the schedule generates, or an activity
/// the educator adds by hand — a sport outing or a workshop (ورشة).
enum SessionKind {
  session('session'),
  sport('sport'),
  workshop('workshop');

  const SessionKind(this.wireValue);

  final String wireValue;

  static SessionKind fromWire(String? value) => switch (value) {
    'sport' => SessionKind.sport,
    'workshop' => SessionKind.workshop,
    _ => SessionKind.session,
  };
}

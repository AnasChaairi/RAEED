import 'package:meta/meta.dart';

/// The window in which a guardian's message reaches the educator with a
/// sound (`MSG-07`); outside it, messages arrive silently.
@immutable
class AvailabilityWindow {
  const AvailabilityWindow({required this.start, required this.end});

  /// "HH:MM" in the organisation's zone.
  final String start;
  final String end;

  /// The design's three presets.
  static const List<AvailabilityWindow> presets = [
    AvailabilityWindow(start: '09:00', end: '20:00'),
    AvailabilityWindow(start: '14:00', end: '21:00'),
    AvailabilityWindow(start: '17:00', end: '21:00'),
  ];

  String get label => '$start–$end';

  @override
  bool operator ==(Object other) =>
      other is AvailabilityWindow && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

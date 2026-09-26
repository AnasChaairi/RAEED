import 'availability.dart';
import 'educator_session.dart';

/// Today and the educator's own settings (EDU-M-01, EDU-M-10).
abstract interface class EducatorRepository {
  Future<TodayView> fetchToday();

  /// "I have read this" (`ANN-06`).
  Future<void> confirmRead(String announcementId);

  Future<AvailabilityWindow?> fetchAvailability();

  Future<AvailabilityWindow> setAvailability(AvailabilityWindow window);
}

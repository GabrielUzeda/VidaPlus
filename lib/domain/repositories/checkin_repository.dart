// Interface de repositório para CheckIn
import '../entities/checkin.dart';

abstract class CheckInRepository {
  Future<List<CheckIn>> getCheckInsByUserAndDate(String userId, DateTime date);
  Future<List<CheckIn>> getCheckInsByHabit(String habitId, {DateTime? startDate, DateTime? endDate});
  Future<CheckIn> createCheckIn({
    required String habitId,
    required String userId,
    required DateTime date,
    required bool completed,
    String? note,
  });
  Future<CheckIn> updateCheckIn({
    required String id,
    bool? completed,
    String? note,
  });
  Future<void> deleteCheckIn(String id);
} 
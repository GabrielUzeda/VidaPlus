// Interface de repositório para Habit
import '../entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits(String userId);
  Future<Habit> getHabitById(String id);
  Future<List<Habit>> getHabitsByFrequency(String userId, Frequency frequency);
  Future<Habit> createHabit({
    required String userId,
    required String name,
    required String description,
    required Frequency frequency,
    required CustomTimeOfDay preferredTime,
  });
  Future<Habit> updateHabit({
    required String id,
    String? name,
    String? description,
    Frequency? frequency,
    CustomTimeOfDay? preferredTime,
    bool? active,
  });
  Future<void> deleteHabit(String id);
} 
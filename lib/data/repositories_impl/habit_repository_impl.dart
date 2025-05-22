// Implementação do repositório de hábitos
import 'package:vida_plus/data/datasources/firestore_habit_datasource.dart';
import 'package:vida_plus/data/models/habit_model.dart';
import 'package:vida_plus/domain/entities/habit.dart';
import 'package:vida_plus/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final FirestoreHabitDatasource _habitDatasource;

  HabitRepositoryImpl({
    required FirestoreHabitDatasource habitDatasource,
  }) : _habitDatasource = habitDatasource;

  @override
  Future<List<Habit>> getHabits(String userId) async {
    try {
      return await _habitDatasource.getHabits(userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Habit> getHabitById(String id) async {
    try {
      return await _habitDatasource.getHabitById(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Habit>> getHabitsByFrequency(String userId, Frequency frequency) async {
    try {
      final frequencyString = _mapFrequencyToString(frequency);
      return await _habitDatasource.getHabitsByFrequency(userId, frequencyString);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Habit> createHabit({
    required String userId,
    required String name,
    required String description,
    required Frequency frequency,
    required CustomTimeOfDay preferredTime,
  }) async {
    try {
      final timeOfDayModel = TimeOfDayModel.fromEntity(preferredTime);

      return await _habitDatasource.createHabit(
        userId: userId,
        name: name,
        description: description,
        frequency: _mapFrequencyToString(frequency),
        preferredTime: timeOfDayModel.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Habit> updateHabit({
    required String id,
    String? name,
    String? description,
    Frequency? frequency,
    CustomTimeOfDay? preferredTime,
    bool? active,
  }) async {
    try {
      Map<String, dynamic>? preferredTimeJson;
      if (preferredTime != null) {
        final timeOfDayModel = TimeOfDayModel.fromEntity(preferredTime);
        preferredTimeJson = timeOfDayModel.toJson();
      }

      return await _habitDatasource.updateHabit(
        id: id,
        name: name,
        description: description,
        frequency: frequency != null ? _mapFrequencyToString(frequency) : null,
        preferredTime: preferredTimeJson,
        active: active,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await _habitDatasource.deleteHabit(id);
    } catch (e) {
      rethrow;
    }
  }

  String _mapFrequencyToString(Frequency frequency) {
    switch (frequency) {
      case Frequency.daily:
        return 'daily';
      case Frequency.weekly:
        return 'weekly';
      case Frequency.custom:
        return 'custom';
      default:
        return 'daily';
    }
  }
} 
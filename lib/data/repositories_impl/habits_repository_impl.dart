import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/checkin_entity.dart';
import '../../domain/repositories/habits_repository.dart';
import '../datasources/firestore_habits_datasource.dart';
import '../models/habit_model.dart';
import '../models/checkin_model.dart';

// Implementação do repositório de hábitos (SOLID - Dependency Inversion)
class HabitsRepositoryImpl implements HabitsRepository {
  final FirestoreHabitsDatasource _datasource;

  HabitsRepositoryImpl({
    required FirestoreHabitsDatasource datasource,
  }) : _datasource = datasource;

  @override
  Future<List<HabitEntity>> getUserHabits(String userId) async {
    final habitModels = await _datasource.getUserHabits(userId);
    return habitModels.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<List<HabitEntity>> getUserHabitsStream(String userId) {
    return _datasource.getUserHabitsStream(userId).map((habitModels) {
      return habitModels.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<HabitEntity> createHabit(HabitEntity habit) async {
    final habitModel = HabitModel.fromEntity(habit);
    final createdModel = await _datasource.createHabit(habitModel);
    return createdModel.toEntity();
  }

  @override
  Future<HabitEntity> updateHabit(HabitEntity habit) async {
    final habitModel = HabitModel.fromEntity(habit);
    final updatedModel = await _datasource.updateHabit(habitModel);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    await _datasource.deleteHabit(habitId);
  }

  @override
  Future<HabitEntity?> getHabitById(String habitId) async {
    final habitModel = await _datasource.getHabitById(habitId);
    return habitModel?.toEntity();
  }

  @override
  Future<CheckInEntity> createCheckIn(CheckInEntity checkIn) async {
    final checkInModel = CheckInModel.fromEntity(checkIn);
    final createdModel = await _datasource.createCheckIn(checkInModel);
    return createdModel.toEntity();
  }

  @override
  Future<List<CheckInEntity>> getCheckInsForHabitAndDate({
    required String habitId,
    required DateTime date,
  }) async {
    final checkInModels = await _datasource.getCheckInsForHabitAndDate(
      habitId: habitId,
      date: date,
    );
    return checkInModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CheckInEntity>> getCheckInsForUserAndDate({
    required String userId,
    required DateTime date,
  }) async {
    final checkInModels = await _datasource.getCheckInsForUserAndDate(
      userId: userId,
      date: date,
    );
    return checkInModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CheckInEntity>> getHabitCheckInHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final checkInModels = await _datasource.getHabitCheckInHistory(
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
    );
    return checkInModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>> getUserProgress({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _datasource.getUserProgress(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
} 
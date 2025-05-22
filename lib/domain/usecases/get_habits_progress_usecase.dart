import '../entities/checkin_entity.dart';
import '../repositories/habits_repository.dart';
import 'base_usecase.dart';

// Caso de uso para obter progresso dos hábitos
class GetHabitsProgressUseCase implements UseCase<Map<String, dynamic>, GetProgressParams> {
  final HabitsRepository _habitsRepository;

  GetHabitsProgressUseCase(this._habitsRepository);

  @override
  Future<Map<String, dynamic>> call(GetProgressParams params) async {
    if (params.userId.isEmpty) {
      throw Exception('ID do usuário é obrigatório');
    }

    return await _habitsRepository.getUserProgress(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

// Caso de uso para obter check-ins de hoje
class GetTodayCheckInsUseCase implements UseCase<List<CheckInEntity>, String> {
  final HabitsRepository _habitsRepository;

  GetTodayCheckInsUseCase(this._habitsRepository);

  @override
  Future<List<CheckInEntity>> call(String userId) async {
    if (userId.isEmpty) {
      throw Exception('ID do usuário é obrigatório');
    }

    final today = DateTime.now();
    return await _habitsRepository.getCheckInsForUserAndDate(
      userId: userId,
      date: today,
    );
  }
}

// Caso de uso para obter histórico de check-ins de um hábito
class GetHabitHistoryUseCase implements UseCase<List<CheckInEntity>, GetHabitHistoryParams> {
  final HabitsRepository _habitsRepository;

  GetHabitHistoryUseCase(this._habitsRepository);

  @override
  Future<List<CheckInEntity>> call(GetHabitHistoryParams params) async {
    if (params.habitId.isEmpty) {
      throw Exception('ID do hábito é obrigatório');
    }

    return await _habitsRepository.getHabitCheckInHistory(
      habitId: params.habitId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

// Parâmetros para obter progresso
class GetProgressParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetProgressParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });
}

// Parâmetros para obter histórico de hábito
class GetHabitHistoryParams {
  final String habitId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetHabitHistoryParams({
    required this.habitId,
    this.startDate,
    this.endDate,
  });
} 
import '../entities/habit_entity.dart';
import '../repositories/habits_repository.dart';
import 'base_usecase.dart';

class GetUserHabitsUseCase implements UseCase<List<HabitEntity>, String> {
  final HabitsRepository _habitsRepository;

  GetUserHabitsUseCase(this._habitsRepository);

  @override
  Future<List<HabitEntity>> call(String userId) async {
    if (userId.isEmpty) {
      throw Exception('ID do usuário é obrigatório');
    }

    return await _habitsRepository.getUserHabits(userId);
  }
}

class GetUserHabitsStreamUseCase implements StreamUseCase<List<HabitEntity>, String> {
  final HabitsRepository _habitsRepository;

  GetUserHabitsStreamUseCase(this._habitsRepository);

  @override
  Stream<List<HabitEntity>> call(String userId) {
    if (userId.isEmpty) {
      throw Exception('ID do usuário é obrigatório');
    }

    return _habitsRepository.getUserHabitsStream(userId);
  }
} 
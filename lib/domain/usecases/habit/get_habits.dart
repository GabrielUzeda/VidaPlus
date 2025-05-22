// Caso de uso para obter hábitos do usuário
import '../../entities/habit.dart';
import '../../repositories/habit_repository.dart';

class GetHabits {
  final HabitRepository _habitRepository;

  GetHabits(this._habitRepository);

  Future<List<Habit>> call(String userId) async {
    if (userId.isEmpty) {
      throw Exception('ID do usuário não pode estar vazio');
    }
    try {
      return await _habitRepository.getHabits(userId);
    } catch (e) {
      throw Exception('Erro ao obter hábitos: ${e.toString()}');
    }
  }
}

class GetHabitsByFrequency {
  final HabitRepository _habitRepository;

  GetHabitsByFrequency(this._habitRepository);

  Future<List<Habit>> call(String userId, Frequency frequency) async {
    if (userId.isEmpty) {
      throw Exception('ID do usuário não pode estar vazio');
    }
    try {
      return await _habitRepository.getHabitsByFrequency(userId, frequency);
    } catch (e) {
      throw Exception('Erro ao obter hábitos por frequência: ${e.toString()}');
    }
  }
} 
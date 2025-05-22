import '../entities/habit_entity.dart';
import '../repositories/habits_repository.dart';
import 'base_usecase.dart';

// Caso de uso para atualizar um hábito existente
class UpdateHabitUseCase implements UseCase<HabitEntity, HabitEntity> {
  final HabitsRepository _habitsRepository;

  UpdateHabitUseCase(this._habitsRepository);

  @override
  Future<HabitEntity> call(HabitEntity habit) async {
    // Validações de negócio
    if (habit.id.isEmpty) {
      throw Exception('ID do hábito é obrigatório');
    }

    if (habit.name.trim().isEmpty) {
      throw Exception('Nome do hábito é obrigatório');
    }

    if (habit.name.trim().length < 3) {
      throw Exception('Nome do hábito deve ter pelo menos 3 caracteres');
    }

    if (habit.name.trim().length > 50) {
      throw Exception('Nome do hábito deve ter no máximo 50 caracteres');
    }

    // Valida horário recomendado se fornecido
    if (habit.recommendedTime != null) {
      if (!_isValidTime(habit.recommendedTime!)) {
        throw Exception('Horário deve estar no formato HH:MM (ex: 08:30)');
      }
    }

    // Atualiza o hábito com novo timestamp
    final updatedHabit = habit.copyWith(
      name: habit.name.trim(),
      updatedAt: DateTime.now(),
    );

    return await _habitsRepository.updateHabit(updatedHabit);
  }

  // Valida formato de horário (HH:MM)
  bool _isValidTime(String time) {
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }
} 
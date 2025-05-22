import '../entities/habit_entity.dart';
import '../repositories/habits_repository.dart';
import 'base_usecase.dart';

// Caso de uso para criar um novo hábito
class CreateHabitUseCase implements UseCase<HabitEntity, CreateHabitParams> {
  final HabitsRepository _habitsRepository;

  CreateHabitUseCase(this._habitsRepository);

  @override
  Future<HabitEntity> call(CreateHabitParams params) async {
    // Validações de negócio
    if (params.name.trim().isEmpty) {
      throw Exception('Nome do hábito é obrigatório');
    }

    if (params.name.trim().length < 3) {
      throw Exception('Nome do hábito deve ter pelo menos 3 caracteres');
    }

    if (params.name.trim().length > 50) {
      throw Exception('Nome do hábito deve ter no máximo 50 caracteres');
    }

    // Valida horário recomendado se fornecido
    if (params.recommendedTime != null) {
      if (!_isValidTime(params.recommendedTime!)) {
        throw Exception('Horário deve estar no formato HH:MM (ex: 08:30)');
      }
    }

    // Cria a entidade do hábito
    final now = DateTime.now();
    final newHabit = HabitEntity(
      id: '', // Será definido pelo repositório
      userId: params.userId,
      name: params.name.trim(),
      frequency: params.frequency,
      recommendedTime: params.recommendedTime,
      createdAt: now,
      updatedAt: now,
    );

    return await _habitsRepository.createHabit(newHabit);
  }

  // Valida formato de horário (HH:MM)
  bool _isValidTime(String time) {
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }
}

// Parâmetros para criação de hábito
class CreateHabitParams {
  final String userId;
  final String name;
  final HabitFrequency frequency;
  final String? recommendedTime;

  const CreateHabitParams({
    required this.userId,
    required this.name,
    required this.frequency,
    this.recommendedTime,
  });
} 
// Casos de uso para gerenciar hábitos
import '../../entities/habit.dart';
import '../../repositories/habit_repository.dart';

class CreateHabit {
  final HabitRepository _habitRepository;

  CreateHabit(this._habitRepository);

  Future<Habit> call({
    required String userId,
    required String name,
    required String description,
    required Frequency frequency,
    required CustomTimeOfDay preferredTime,
  }) async {
    // Validações
    if (userId.isEmpty) {
      throw Exception('ID do usuário não pode estar vazio');
    }
    if (name.isEmpty) {
      throw Exception('Nome do hábito não pode estar vazio');
    }
    if (description.isEmpty) {
      throw Exception('Descrição do hábito não pode estar vazia');
    }
    if (preferredTime.hour < 0 || preferredTime.hour > 23) {
      throw Exception('Hora inválida');
    }
    if (preferredTime.minute < 0 || preferredTime.minute > 59) {
      throw Exception('Minuto inválido');
    }

    try {
      return await _habitRepository.createHabit(
        userId: userId,
        name: name,
        description: description,
        frequency: frequency,
        preferredTime: preferredTime,
      );
    } catch (e) {
      throw Exception('Erro ao criar hábito: ${e.toString()}');
    }
  }
}

class UpdateHabit {
  final HabitRepository _habitRepository;

  UpdateHabit(this._habitRepository);

  Future<Habit> call({
    required String id,
    String? name,
    String? description,
    Frequency? frequency,
    CustomTimeOfDay? preferredTime,
    bool? active,
  }) async {
    if (id.isEmpty) {
      throw Exception('ID do hábito não pode estar vazio');
    }

    if (name != null && name.isEmpty) {
      throw Exception('Nome do hábito não pode estar vazio');
    }

    if (description != null && description.isEmpty) {
      throw Exception('Descrição do hábito não pode estar vazia');
    }

    if (preferredTime != null) {
      if (preferredTime.hour < 0 || preferredTime.hour > 23) {
        throw Exception('Hora inválida');
      }
      if (preferredTime.minute < 0 || preferredTime.minute > 59) {
        throw Exception('Minuto inválido');
      }
    }

    try {
      return await _habitRepository.updateHabit(
        id: id,
        name: name,
        description: description,
        frequency: frequency,
        preferredTime: preferredTime,
        active: active,
      );
    } catch (e) {
      throw Exception('Erro ao atualizar hábito: ${e.toString()}');
    }
  }
}

class DeleteHabit {
  final HabitRepository _habitRepository;

  DeleteHabit(this._habitRepository);

  Future<void> call(String id) async {
    if (id.isEmpty) {
      throw Exception('ID do hábito não pode estar vazio');
    }

    try {
      await _habitRepository.deleteHabit(id);
    } catch (e) {
      throw Exception('Erro ao excluir hábito: ${e.toString()}');
    }
  }
} 
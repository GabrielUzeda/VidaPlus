import '../repositories/habits_repository.dart';
import 'base_usecase.dart';

// Caso de uso para deletar um hábito
class DeleteHabitUseCase implements UseCase<void, String> {
  final HabitsRepository _habitsRepository;

  DeleteHabitUseCase(this._habitsRepository);

  @override
  Future<void> call(String habitId) async {
    // Validações de negócio
    if (habitId.isEmpty) {
      throw Exception('ID do hábito é obrigatório');
    }

    // Aqui poderia ter validações adicionais como:
    // - Verificar se o hábito existe
    // - Verificar se o usuário tem permissão para deletar
    // - Verificar se há dependências (check-ins relacionados)

    await _habitsRepository.deleteHabit(habitId);
  }
} 
import '../entities/checkin_entity.dart';
import '../repositories/habits_repository.dart';
import 'base_usecase.dart';

// Caso de uso para registrar check-in de um hábito
class CheckInHabitUseCase implements UseCase<CheckInEntity, CheckInHabitParams> {
  final HabitsRepository _habitsRepository;

  CheckInHabitUseCase(this._habitsRepository);

  @override
  Future<CheckInEntity> call(CheckInHabitParams params) async {
    // Validações de negócio
    if (params.habitId.isEmpty) {
      throw Exception('ID do hábito é obrigatório');
    }

    if (params.userId.isEmpty) {
      throw Exception('ID do usuário é obrigatório');
    }

    // Verifica se já foi feito check-in hoje para este hábito
    final today = DateTime.now();
    final todayCheckIns = await _habitsRepository.getCheckInsForUserAndDate(
      userId: params.userId,
      date: today,
    );

    final alreadyCheckedIn = todayCheckIns.any((checkIn) => checkIn.habitId == params.habitId);
    if (alreadyCheckedIn) {
      throw Exception('Check-in já foi realizado hoje para este hábito');
    }

    // Valida notas se fornecidas
    if (params.notes != null && params.notes!.length > 200) {
      throw Exception('Notas devem ter no máximo 200 caracteres');
    }

    // Cria o check-in
    final now = DateTime.now();
    final checkIn = CheckInEntity(
      id: '', // Será definido pelo repositório
      habitId: params.habitId,
      userId: params.userId,
      completedAt: now,
      date: DateTime(now.year, now.month, now.day), // Data sem horário
      notes: params.notes?.trim(),
    );

    return await _habitsRepository.createCheckIn(checkIn);
  }
}

// Parâmetros para check-in de hábito
class CheckInHabitParams {
  final String habitId;
  final String userId;
  final String? notes;

  const CheckInHabitParams({
    required this.habitId,
    required this.userId,
    this.notes,
  });
} 
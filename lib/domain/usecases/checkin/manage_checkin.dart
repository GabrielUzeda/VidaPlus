// Casos de uso para gerenciar check-ins
import '../../entities/checkin.dart';
import '../../repositories/checkin_repository.dart';

class CreateCheckIn {
  final CheckInRepository _checkInRepository;

  CreateCheckIn(this._checkInRepository);

  Future<CheckIn> call({
    required String habitId,
    required String userId,
    required DateTime date,
    required bool completed,
    String? note,
  }) async {
    // Validações
    if (habitId.isEmpty) {
      throw Exception('ID do hábito não pode estar vazio');
    }
    if (userId.isEmpty) {
      throw Exception('ID do usuário não pode estar vazio');
    }

    try {
      return await _checkInRepository.createCheckIn(
        habitId: habitId,
        userId: userId,
        date: date,
        completed: completed,
        note: note,
      );
    } catch (e) {
      throw Exception('Erro ao criar check-in: ${e.toString()}');
    }
  }
}

class UpdateCheckIn {
  final CheckInRepository _checkInRepository;

  UpdateCheckIn(this._checkInRepository);

  Future<CheckIn> call({
    required String id,
    bool? completed,
    String? note,
  }) async {
    if (id.isEmpty) {
      throw Exception('ID do check-in não pode estar vazio');
    }

    try {
      return await _checkInRepository.updateCheckIn(
        id: id,
        completed: completed,
        note: note,
      );
    } catch (e) {
      throw Exception('Erro ao atualizar check-in: ${e.toString()}');
    }
  }
}

class DeleteCheckIn {
  final CheckInRepository _checkInRepository;

  DeleteCheckIn(this._checkInRepository);

  Future<void> call(String id) async {
    if (id.isEmpty) {
      throw Exception('ID do check-in não pode estar vazio');
    }

    try {
      await _checkInRepository.deleteCheckIn(id);
    } catch (e) {
      throw Exception('Erro ao excluir check-in: ${e.toString()}');
    }
  }
}

class GetCheckInsByUserAndDate {
  final CheckInRepository _checkInRepository;

  GetCheckInsByUserAndDate(this._checkInRepository);

  Future<List<CheckIn>> call(String userId, DateTime date) async {
    if (userId.isEmpty) {
      throw Exception('ID do usuário não pode estar vazio');
    }

    try {
      return await _checkInRepository.getCheckInsByUserAndDate(userId, date);
    } catch (e) {
      throw Exception('Erro ao obter check-ins: ${e.toString()}');
    }
  }
}

class GetCheckInsByHabit {
  final CheckInRepository _checkInRepository;

  GetCheckInsByHabit(this._checkInRepository);

  Future<List<CheckIn>> call(String habitId, {DateTime? startDate, DateTime? endDate}) async {
    if (habitId.isEmpty) {
      throw Exception('ID do hábito não pode estar vazio');
    }

    try {
      return await _checkInRepository.getCheckInsByHabit(habitId, startDate: startDate, endDate: endDate);
    } catch (e) {
      rethrow;
    }
  }
} 
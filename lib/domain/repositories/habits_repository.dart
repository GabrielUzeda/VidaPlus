import '../entities/habit_entity.dart';
import '../entities/checkin_entity.dart';

// Interface para o repositório de hábitos (SOLID - Dependency Inversion)
abstract class HabitsRepository {
  // Obtém todos os hábitos do usuário
  Future<List<HabitEntity>> getUserHabits(String userId);
  
  // Stream dos hábitos do usuário
  Stream<List<HabitEntity>> getUserHabitsStream(String userId);
  
  // Cria um novo hábito
  Future<HabitEntity> createHabit(HabitEntity habit);
  
  // Atualiza um hábito existente
  Future<HabitEntity> updateHabit(HabitEntity habit);
  
  // Remove um hábito
  Future<void> deleteHabit(String habitId);
  
  // Obtém um hábito por ID
  Future<HabitEntity?> getHabitById(String habitId);
  
  // Registra um check-in para um hábito
  Future<CheckInEntity> createCheckIn(CheckInEntity checkIn);
  
  // Obtém check-ins por hábito e data
  Future<List<CheckInEntity>> getCheckInsForHabitAndDate({
    required String habitId,
    required DateTime date,
  });
  
  // Obtém check-ins por usuário e data
  Future<List<CheckInEntity>> getCheckInsForUserAndDate({
    required String userId,
    required DateTime date,
  });
  
  // Obtém histórico de check-ins para um hábito
  Future<List<CheckInEntity>> getHabitCheckInHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  // Obtém estatísticas de progresso para um usuário
  Future<Map<String, dynamic>> getUserProgress({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
} 
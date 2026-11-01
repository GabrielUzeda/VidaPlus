import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../models/local_habit_model.dart';
import '../models/local_checkin_model.dart';

class LocalHabitsDatasource {
  static const String _habitsBoxName = 'habits';
  static const String _checkinsBoxName = 'checkins';
  
  late Box<LocalHabitModel> _habitsBox;
  late Box<LocalCheckInModel> _checkinsBox;
  final _uuid = const Uuid();
  final _habitsController = StreamController<List<LocalHabitModel>>.broadcast();

  LocalHabitsDatasource();

  // Inicializa o datasource
  Future<void> initialize() async {
    _habitsBox = await Hive.openBox<LocalHabitModel>(_habitsBoxName);
    _checkinsBox = await Hive.openBox<LocalCheckInModel>(_checkinsBoxName);
  }

  // Stream dos hábitos do usuário
  Stream<List<LocalHabitModel>> getUserHabitsStream(String userId) {
    return _habitsController.stream;
  }

  // Obtém todos os hábitos ativos do usuário
  Future<List<LocalHabitModel>> getUserHabits(String userId) async {
    try {
      final habits = _habitsBox.values
          .where((habit) => habit.userId == userId && habit.isActive)
          .toList();
      
      // Ordena por data de criação
      habits.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      // Emite o evento para o stream
      _habitsController.add(habits);
      
      debugPrint('📋 Found ${habits.length} habits for user $userId');
      return habits;
    } catch (e) {
      debugPrint('❌ Error getting user habits: $e');
      return [];
    }
  }

  // Cria um novo hábito
  Future<LocalHabitModel> createHabit(LocalHabitModel habit) async {
    try {
      final habitId = _uuid.v4();
      final newHabit = habit.copyWith(id: habitId);
      
      await _habitsBox.put(habitId, newHabit);
      
      // Atualiza o stream
      await getUserHabits(habit.userId);
      
      debugPrint('✅ Habit created: ${newHabit.name}');
      return newHabit;
    } catch (e) {
      debugPrint('❌ Error creating habit: $e');
      throw Exception('Erro ao criar hábito: $e');
    }
  }

  // Atualiza um hábito existente
  Future<LocalHabitModel> updateHabit(LocalHabitModel habit) async {
    try {
      final updatedHabit = habit.copyWith(updatedAt: DateTime.now());
      
      await _habitsBox.put(habit.id, updatedHabit);
      
      // Atualiza o stream
      await getUserHabits(habit.userId);
      
      debugPrint('✅ Habit updated: ${updatedHabit.name}');
      return updatedHabit;
    } catch (e) {
      debugPrint('❌ Error updating habit: $e');
      throw Exception('Erro ao atualizar hábito: $e');
    }
  }

  // Remove um hábito (marca como inativo)
  Future<void> deleteHabit(String habitId) async {
    try {
      final habit = _habitsBox.get(habitId);
      if (habit == null) {
        throw Exception('Hábito não encontrado');
      }

      final updatedHabit = habit.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );

      await _habitsBox.put(habitId, updatedHabit);
      
      // Atualiza o stream
      await getUserHabits(habit.userId);
      
      debugPrint('✅ Habit deleted: ${habit.name}');
    } catch (e) {
      debugPrint('❌ Error deleting habit: $e');
      throw Exception('Erro ao deletar hábito: $e');
    }
  }

  // Obtém um hábito por ID
  Future<LocalHabitModel?> getHabitById(String habitId) async {
    try {
      return _habitsBox.get(habitId);
    } catch (e) {
      debugPrint('❌ Error getting habit by ID: $e');
      return null;
    }
  }

  // Registra um check-in para um hábito
  Future<LocalCheckInModel> createCheckIn(LocalCheckInModel checkIn) async {
    try {
      // Normaliza a data para o início do dia
      final normalizedDate = DateTime(
        checkIn.date.year,
        checkIn.date.month,
        checkIn.date.day,
      );

      final checkinId = _uuid.v4();
      final newCheckIn = checkIn.copyWith(
        id: checkinId,
        date: normalizedDate,
      );
      
      await _checkinsBox.put(checkinId, newCheckIn);
      
      debugPrint('✅ Check-in created for habit ${checkIn.habitId}');
      return newCheckIn;
    } catch (e) {
      debugPrint('❌ Error creating check-in: $e');
      throw Exception('Erro ao criar check-in: $e');
    }
  }

  // Obtém check-ins por hábito e data
  Future<List<LocalCheckInModel>> getCheckInsForHabitAndDate({
    required String habitId,
    required DateTime date,
  }) async {
    try {
      // Normaliza a data para o início do dia
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final nextDay = normalizedDate.add(const Duration(days: 1));

      final checkIns = _checkinsBox.values.where((checkIn) {
        return checkIn.habitId == habitId &&
               checkIn.date.isAfter(normalizedDate.subtract(const Duration(seconds: 1))) &&
               checkIn.date.isBefore(nextDay);
      }).toList();

      debugPrint('📅 Found ${checkIns.length} check-ins for habit $habitId on ${DateFormat('yyyy-MM-dd').format(date)}');
      return checkIns;
    } catch (e) {
      debugPrint('❌ Error getting check-ins for habit and date: $e');
      return [];
    }
  }

  // Obtém check-ins por usuário e data
  Future<List<LocalCheckInModel>> getCheckInsForUserAndDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      // Normaliza a data para o início do dia
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final nextDay = normalizedDate.add(const Duration(days: 1));

      final checkIns = _checkinsBox.values.where((checkIn) {
        return checkIn.userId == userId &&
               checkIn.date.isAfter(normalizedDate.subtract(const Duration(seconds: 1))) &&
               checkIn.date.isBefore(nextDay);
      }).toList();

      debugPrint('📅 Found ${checkIns.length} check-ins for user $userId on ${DateFormat('yyyy-MM-dd').format(date)}');
      return checkIns;
    } catch (e) {
      debugPrint('❌ Error getting check-ins for user and date: $e');
      return [];
    }
  }

  // Obtém histórico de check-ins para um hábito
  Future<List<LocalCheckInModel>> getHabitCheckInHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var checkIns = _checkinsBox.values.where((checkIn) => checkIn.habitId == habitId);

      if (startDate != null) {
        final normalizedStartDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        checkIns = checkIns.where((checkIn) => 
          checkIn.date.isAfter(normalizedStartDate.subtract(const Duration(seconds: 1)))
        );
      }

      if (endDate != null) {
        final normalizedEndDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
        ).add(const Duration(days: 1)); // Inclui o dia completo
        checkIns = checkIns.where((checkIn) => checkIn.date.isBefore(normalizedEndDate));
      }

      final result = checkIns.toList();
      // Ordena por data (mais recente primeiro)
      result.sort((a, b) => b.date.compareTo(a.date));

      debugPrint('📈 Found ${result.length} check-ins in history for habit $habitId');
      return result;
    } catch (e) {
      debugPrint('❌ Error getting habit check-in history: $e');
      return [];
    }
  }

  // Obtém estatísticas de progresso para um usuário
  Future<Map<String, dynamic>> getUserProgress({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Define período padrão se não fornecido (últimos 30 dias)
      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));

      // Normaliza as datas
      final normalizedStart = DateTime(start.year, start.month, start.day);
      final normalizedEnd = DateTime(end.year, end.month, end.day)
          .add(const Duration(days: 1));

      // Busca hábitos do usuário
      final habits = _habitsBox.values
          .where((habit) => habit.userId == userId && habit.isActive)
          .toList();

      if (habits.isEmpty) {
        return {
          'totalHabits': 0,
          'totalCheckIns': 0,
          'completionRate': 0.0,
          'dailyProgress': <String, int>{},
          'habitProgress': <String, Map<String, dynamic>>{},
        };
      }

      // Busca check-ins do período
      final checkIns = _checkinsBox.values.where((checkIn) {
        return checkIn.userId == userId &&
               checkIn.date.isAfter(normalizedStart.subtract(const Duration(seconds: 1))) &&
               checkIn.date.isBefore(normalizedEnd);
      }).toList();

      // Calcula estatísticas
      final totalCheckIns = checkIns.length;
      final dailyProgress = <String, int>{};
      final habitProgress = <String, Map<String, dynamic>>{};

      // Agrupa check-ins por data
      for (final checkIn in checkIns) {
        final dateKey = DateFormat('yyyy-MM-dd').format(checkIn.date);
        dailyProgress[dateKey] = (dailyProgress[dateKey] ?? 0) + 1;
      }

      // Calcula progresso por hábito
      for (final habit in habits) {
        final habitCheckIns = checkIns.where((c) => c.habitId == habit.id).length;
        
        // Calcula quantos dias o hábito deveria ter sido feito
        final daysDiff = normalizedEnd.difference(normalizedStart).inDays;
        final expectedCheckIns = habit.frequency == 'daily' ? daysDiff : (daysDiff / 7).ceil();
        
        final completionRate = expectedCheckIns > 0 ? (habitCheckIns / expectedCheckIns.toDouble()) : 0.0;
        
        habitProgress[habit.id] = {
          'name': habit.name,
          'checkIns': habitCheckIns,
          'expected': expectedCheckIns,
          'completionRate': completionRate.clamp(0.0, 1.0),
        };
      }

      // Calcula taxa de conclusão geral
      final totalExpected = habits.fold<int>(0, (sum, habit) {
        final daysDiff = normalizedEnd.difference(normalizedStart).inDays;
        return sum + (habit.frequency == 'daily' ? daysDiff : (daysDiff / 7).ceil());
      });
      
      final overallCompletionRate = totalExpected > 0 ? (totalCheckIns / totalExpected.toDouble()) : 0.0;

      final result = {
        'totalHabits': habits.length,
        'totalCheckIns': totalCheckIns,
        'completionRate': overallCompletionRate.clamp(0.0, 1.0),
        'dailyProgress': dailyProgress,
        'habitProgress': habitProgress,
      };

      debugPrint('📊 User progress calculated: ${result['totalCheckIns']} check-ins, ${((result['completionRate'] as double) * 100).toStringAsFixed(1)}% completion');
      return result;
    } catch (e) {
      debugPrint('❌ Error getting user progress: $e');
      return {
        'totalHabits': 0,
        'totalCheckIns': 0,
        'completionRate': 0.0,
        'dailyProgress': <String, int>{},
        'habitProgress': <String, Map<String, dynamic>>{},
      };
    }
  }

  // Limpa todos os dados (para testes)
  Future<void> clearAllData() async {
    try {
      await _habitsBox.clear();
      await _checkinsBox.clear();
      _habitsController.add([]);
      debugPrint('✅ All habits data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing habits data: $e');
    }
  }

  // Fecha o datasource
  Future<void> dispose() async {
    await _habitsController.close();
  }
} 
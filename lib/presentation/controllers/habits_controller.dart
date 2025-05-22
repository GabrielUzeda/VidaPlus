import 'package:flutter/foundation.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/checkin_entity.dart';
import '../../domain/repositories/habits_repository.dart';
import '../../core/services/notification_service.dart';

// Controlador de estado para hábitos (SOLID - Single Responsibility)
class HabitsController extends ChangeNotifier {
  final HabitsRepository _habitsRepository;
  final NotificationService _notificationService;

  HabitsController({
    required HabitsRepository habitsRepository,
    required NotificationService notificationService,
  })  : _habitsRepository = habitsRepository,
        _notificationService = notificationService;

  List<HabitEntity> _habits = [];
  List<CheckInEntity> _todayCheckIns = [];
  Map<String, dynamic>? _userProgress;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<HabitEntity> get habits => _habits;
  List<CheckInEntity> get todayCheckIns => _todayCheckIns;
  Map<String, dynamic>? get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carrega hábitos do usuário
  Future<void> loadUserHabits(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _habits = await _habitsRepository.getUserHabits(userId);
      
      // Carrega check-ins de hoje também
      await _loadTodayCheckIns(userId);
      
      // Agenda notificações para os hábitos
      for (final habit in _habits) {
        if (habit.recommendedTime != null) {
          await _notificationService.scheduleHabitReminder(habit);
        }
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Stream dos hábitos do usuário (para atualizações em tempo real)
  Stream<List<HabitEntity>> getUserHabitsStream(String userId) {
    return _habitsRepository.getUserHabitsStream(userId);
  }

  // Carrega check-ins de hoje
  Future<void> _loadTodayCheckIns(String userId) async {
    try {
      final today = DateTime.now();
      _todayCheckIns = await _habitsRepository.getCheckInsForUserAndDate(
        userId: userId,
        date: today,
      );
    } catch (e) {
      // Silently handle error - check-ins remain empty
    }
  }

  // Cria um novo hábito
  Future<void> createHabit({
    required String userId,
    required String name,
    required HabitFrequency frequency,
    String? recommendedTime,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final now = DateTime.now();
      final newHabit = HabitEntity(
        id: '', // Será definido pelo Firestore
        userId: userId,
        name: name,
        frequency: frequency,
        recommendedTime: recommendedTime,
        createdAt: now,
        updatedAt: now,
      );

      final createdHabit = await _habitsRepository.createHabit(newHabit);
      
      // Adiciona à lista local
      _habits.add(createdHabit);
      
      // Agenda notificação se tiver horário
      if (createdHabit.recommendedTime != null) {
        await _notificationService.scheduleHabitReminder(createdHabit);
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Atualiza um hábito existente
  Future<void> updateHabit(HabitEntity habit) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedHabit = await _habitsRepository.updateHabit(habit);
      
      // Atualiza na lista local
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = updatedHabit;
      }
      
      // Atualiza notificação
      if (updatedHabit.recommendedTime != null) {
        await _notificationService.scheduleHabitReminder(updatedHabit);
      } else {
        await _notificationService.cancelHabitReminder(updatedHabit.id);
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Remove um hábito
  Future<void> deleteHabit(String habitId) async {
    try {
      _setLoading(true);
      _clearError();

      await _habitsRepository.deleteHabit(habitId);
      
      // Remove da lista local
      _habits.removeWhere((h) => h.id == habitId);
      
      // Cancela notificação
      await _notificationService.cancelHabitReminder(habitId);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Registra check-in para um hábito
  Future<void> checkInHabit({
    required String habitId,
    required String userId,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final checkIn = CheckInEntity(
        id: '', // Será definido pelo Firestore
        habitId: habitId,
        userId: userId,
        completedAt: now,
        date: today,
        notes: notes,
      );

      final createdCheckIn = await _habitsRepository.createCheckIn(checkIn);
      
      // Adiciona à lista de check-ins de hoje
      _todayCheckIns.add(createdCheckIn);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Verifica se um hábito foi realizado hoje
  bool isHabitCompletedToday(String habitId) {
    return _todayCheckIns.any((checkIn) => checkIn.habitId == habitId);
  }

  // Obtém progresso do usuário
  Future<void> loadUserProgress({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _userProgress = await _habitsRepository.getUserProgress(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Obtém histórico de check-ins para um hábito
  Future<List<CheckInEntity>> getHabitCheckInHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _habitsRepository.getHabitCheckInHistory(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Calcula estatísticas do dia
  Map<String, dynamic> getTodayStats() {
    final totalHabits = _habits.length;
    final completedHabits = _todayCheckIns.length;
    final completionRate = totalHabits > 0 ? completedHabits / totalHabits : 0.0;

    return {
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'completionRate': completionRate,
      'pendingHabits': totalHabits - completedHabits,
    };
  }

  // Define estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Define erro
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Limpa erro
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Limpa erro manualmente (para UI)
  void clearError() {
    _clearError();
  }
} 
import 'package:flutter/foundation.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/checkin_entity.dart';
import '../../domain/usecases/usecases.dart';
import '../../core/services/notification_service.dart';

// Controlador de estado para hábitos usando Use Cases (Clean Architecture)
class HabitsController extends ChangeNotifier {
  // Use Cases de hábitos
  final CreateHabitUseCase _createHabitUseCase;
  final GetUserHabitsUseCase _getUserHabitsUseCase;
  final GetUserHabitsStreamUseCase _getUserHabitsStreamUseCase;
  final UpdateHabitUseCase _updateHabitUseCase;
  final DeleteHabitUseCase _deleteHabitUseCase;
  final CheckInHabitUseCase _checkInHabitUseCase;
  final GetTodayCheckInsUseCase _getTodayCheckInsUseCase;
  final GetHabitsProgressUseCase _getHabitsProgressUseCase;
  final GetHabitHistoryUseCase _getHabitHistoryUseCase;
  
  final NotificationService _notificationService;

  HabitsController({
    required CreateHabitUseCase createHabitUseCase,
    required GetUserHabitsUseCase getUserHabitsUseCase,
    required GetUserHabitsStreamUseCase getUserHabitsStreamUseCase,
    required UpdateHabitUseCase updateHabitUseCase,
    required DeleteHabitUseCase deleteHabitUseCase,
    required CheckInHabitUseCase checkInHabitUseCase,
    required GetTodayCheckInsUseCase getTodayCheckInsUseCase,
    required GetHabitsProgressUseCase getHabitsProgressUseCase,
    required GetHabitHistoryUseCase getHabitHistoryUseCase,
    required NotificationService notificationService,
  })  : _createHabitUseCase = createHabitUseCase,
        _getUserHabitsUseCase = getUserHabitsUseCase,
        _getUserHabitsStreamUseCase = getUserHabitsStreamUseCase,
        _updateHabitUseCase = updateHabitUseCase,
        _deleteHabitUseCase = deleteHabitUseCase,
        _checkInHabitUseCase = checkInHabitUseCase,
        _getTodayCheckInsUseCase = getTodayCheckInsUseCase,
        _getHabitsProgressUseCase = getHabitsProgressUseCase,
        _getHabitHistoryUseCase = getHabitHistoryUseCase,
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

  // Carrega hábitos do usuário usando Use Case
  Future<void> loadUserHabits(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _habits = await _getUserHabitsUseCase.call(userId);
      
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

  // Stream dos hábitos do usuário
  Stream<List<HabitEntity>> getUserHabitsStream(String userId) {
    return _getUserHabitsStreamUseCase.call(userId);
  }

  // Carrega check-ins de hoje usando Use Case
  Future<void> _loadTodayCheckIns(String userId) async {
    try {
      final allTodayCheckIns = await _getTodayCheckInsUseCase.call(userId);
      
      // Filtra apenas check-ins de hábitos que ainda existem
      final habitIds = _habits.map((h) => h.id).toSet();
      _todayCheckIns = allTodayCheckIns.where((checkIn) => 
        habitIds.contains(checkIn.habitId)
      ).toList();
    } catch (e) {
      // Silently handle error - check-ins remain empty
      _todayCheckIns = [];
    }
  }

  // Cria um novo hábito usando Use Case
  Future<void> createHabit({
    required String userId,
    required String name,
    required HabitFrequency frequency,
    String? recommendedTime,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final params = CreateHabitParams(
        userId: userId,
        name: name,
        frequency: frequency,
        recommendedTime: recommendedTime,
      );

      final createdHabit = await _createHabitUseCase.call(params);
      
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

  // Atualiza um hábito existente usando Use Case
  Future<void> updateHabit(HabitEntity habit) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedHabit = await _updateHabitUseCase.call(habit);
      
      // Atualiza na lista local
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = updatedHabit;
      }
      
      // Atualiza notificação
      if (updatedHabit.recommendedTime != null) {
        await _notificationService.rescheduleHabitReminder(updatedHabit);
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

  // Remove um hábito usando Use Case
  Future<void> deleteHabit(String habitId) async {
    try {
      _setLoading(true);
      _clearError();

      await _deleteHabitUseCase.call(habitId);
      
      // Remove da lista local
      _habits.removeWhere((h) => h.id == habitId);
      
      // Remove check-ins órfãos deste hábito da lista de hoje
      _todayCheckIns.removeWhere((checkIn) => checkIn.habitId == habitId);
      
      // Cancela notificação
      await _notificationService.cancelHabitReminder(habitId);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Registra check-in para um hábito usando Use Case
  Future<void> checkInHabit({
    required String habitId,
    required String userId,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Verifica se já existe check-in para este hábito hoje
      final existingCheckIn = _todayCheckIns.where((checkIn) => checkIn.habitId == habitId).firstOrNull;
      if (existingCheckIn != null) {
        // Já foi feito check-in hoje para este hábito
        return;
      }

      final params = CheckInHabitParams(
        habitId: habitId,
        userId: userId,
        notes: notes,
      );

      final createdCheckIn = await _checkInHabitUseCase.call(params);
      
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

  // Obtém progresso do usuário usando Use Case
  Future<void> loadUserProgress({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final params = GetProgressParams(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      _userProgress = await _getHabitsProgressUseCase.call(params);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Obtém histórico de check-ins para um hábito usando Use Case
  Future<List<CheckInEntity>> getHabitCheckInHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = GetHabitHistoryParams(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );

      return await _getHabitHistoryUseCase.call(params);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Calcula estatísticas do dia
  Map<String, dynamic> getTodayStats() {
    final totalHabits = _habits.length;
    
    // Conta apenas hábitos que existem na lista atual e têm check-in hoje
    final completedHabits = _habits.where((habit) => 
      _todayCheckIns.any((checkIn) => checkIn.habitId == habit.id)
    ).length;
    
    final pendingHabits = totalHabits - completedHabits;
    final completionRate = totalHabits > 0 ? completedHabits / totalHabits : 0.0;

    return {
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'completionRate': completionRate,
      'pendingHabits': pendingHabits,
    };
  }

  // Calcula dias ativos baseado nos check-ins reais
  Future<int> getActiveDays(String userId) async {
    try {
      // Busca todo o progresso do usuário desde sempre
      final params = GetProgressParams(
        userId: userId,
        startDate: DateTime(2020), // Data bem antiga para pegar todos os dados
        endDate: DateTime.now(),
      );

      final progress = await _getHabitsProgressUseCase.call(params);
      final dailyProgress = progress['dailyProgress'] as Map<String, int>? ?? {};
      
      // Conta quantos dias únicos o usuário fez pelo menos 1 check-in
      return dailyProgress.keys.length;
    } catch (e) {
      // Em caso de erro, retorna 0
      return 0;
    }
  }

  // Obtém dados reais do histórico semanal
  Future<List<Map<String, dynamic>>> getWeeklyHistoryData(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Segunda-feira
      
      final params = GetProgressParams(
        userId: userId,
        startDate: weekStart,
        endDate: now,
      );

      final progress = await _getHabitsProgressUseCase.call(params);
      final dailyProgress = progress['dailyProgress'] as Map<String, int>? ?? {};
      
      // Gera dados para os últimos 7 dias
      final weekData = <Map<String, dynamic>>[];
      
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final checkInsCount = dailyProgress[dateKey] ?? 0;
        
        // Calcula porcentagem baseada no número de hábitos do dia
        final totalHabitsOnDate = _habits.where((habit) => 
          habit.createdAt.isBefore(date.add(const Duration(days: 1)))
        ).length;
        
        final progressPercent = totalHabitsOnDate > 0 
          ? (checkInsCount / totalHabitsOnDate * 100).clamp(0, 100).toDouble()
          : 0.0;
        
        weekData.add({
          'day': i,
          'date': date,
          'progress': progressPercent,
          'checkIns': checkInsCount,
          'totalHabits': totalHabitsOnDate,
        });
      }
      
      return weekData;
    } catch (e) {
      // Em caso de erro, retorna dados vazios
      return List.generate(7, (index) => {
        'day': index,
        'date': DateTime.now().subtract(Duration(days: 6 - index)),
        'progress': 0.0,
        'checkIns': 0,
        'totalHabits': 0,
      });
    }
  }

  // Obtém dados reais do histórico mensal
  Future<List<Map<String, dynamic>>> getMonthlyHistoryData(String userId, DateTime month) async {
    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      
      final params = GetProgressParams(
        userId: userId,
        startDate: firstDay,
        endDate: lastDay,
      );

      final progress = await _getHabitsProgressUseCase.call(params);
      final dailyProgress = progress['dailyProgress'] as Map<String, int>? ?? {};
      
      // Gera dados para todos os dias do mês
      final monthData = <Map<String, dynamic>>[];
      
      for (int day = 1; day <= lastDay.day; day++) {
        final date = DateTime(month.year, month.month, day);
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final checkInsCount = dailyProgress[dateKey] ?? 0;
        
        // Calcula porcentagem baseada no número de hábitos do dia
        final totalHabitsOnDate = _habits.where((habit) => 
          habit.createdAt.isBefore(date.add(const Duration(days: 1)))
        ).length;
        
        final progressPercent = totalHabitsOnDate > 0 
          ? (checkInsCount / totalHabitsOnDate * 100).clamp(0, 100).toDouble()
          : 0.0;
        
        monthData.add({
          'day': day,
          'date': date,
          'progress': progressPercent,
          'checkIns': checkInsCount,
          'totalHabits': totalHabitsOnDate,
        });
      }
      
      return monthData;
    } catch (e) {
      // Em caso de erro, retorna dados vazios
      final lastDay = DateTime(month.year, month.month + 1, 0);
      return List.generate(lastDay.day, (index) => {
        'day': index + 1,
        'date': DateTime(month.year, month.month, index + 1),
        'progress': 0.0,
        'checkIns': 0,
        'totalHabits': 0,
      });
    }
  }

  // Obtém estatísticas reais de um hábito específico
  Future<Map<String, dynamic>> getHabitRealStats(String habitId) async {
    try {
      // Busca histórico de check-ins do hábito
      final history = await getHabitCheckInHistory(habitId: habitId);
      
      if (history.isEmpty) {
        return {
          'totalCheckIns': 0,
          'currentStreak': 0,
          'longestStreak': 0,
          'completionRate': 0.0,
        };
      }
      
      // Calcula sequência atual
      int currentStreak = 0;
      final today = DateTime.now();
      var currentDate = DateTime(today.year, today.month, today.day);
      
      // Verifica se tem check-in hoje
      final hasCheckInToday = history.any((checkIn) {
        final checkInDate = DateTime(checkIn.date.year, checkIn.date.month, checkIn.date.day);
        return checkInDate.isAtSameMomentAs(currentDate);
      });
      
      if (hasCheckInToday) {
        currentStreak = 1;
        currentDate = currentDate.subtract(const Duration(days: 1));
        
        // Conta dias consecutivos para trás
        while (history.any((checkIn) {
          final checkInDate = DateTime(checkIn.date.year, checkIn.date.month, checkIn.date.day);
          return checkInDate.isAtSameMomentAs(currentDate);
        })) {
          currentStreak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        }
      }
      
      // Calcula maior sequência (implementação simplificada)
      int longestStreak = currentStreak;
      
      // Calcula taxa de conclusão (últimos 30 dias)
      final thirtyDaysAgo = today.subtract(const Duration(days: 30));
      final recentHistory = history.where((checkIn) => 
        checkIn.date.isAfter(thirtyDaysAgo)
      ).toList();
      
      final completionRate = recentHistory.length / 30.0 * 100;
      
      return {
        'totalCheckIns': history.length,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'completionRate': completionRate.clamp(0, 100),
      };
    } catch (e) {
      return {
        'totalCheckIns': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'completionRate': 0.0,
      };
    }
  }

  // Remove check-in de um hábito (desfazer)
  Future<void> undoCheckIn({
    required String habitId,
    required String userId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Encontra o check-in de hoje para este hábito
      final checkInToRemove = _todayCheckIns
          .where((checkIn) => checkIn.habitId == habitId)
          .firstOrNull;

      if (checkInToRemove == null) {
        return; // Não há check-in para remover
      }

      // Remove do Firestore (se tiver método no Use Case)
      // Por enquanto, apenas remove da lista local
      _todayCheckIns.removeWhere((checkIn) => 
        checkIn.habitId == habitId && checkIn.id == checkInToRemove.id
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
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

  // Verifica e solicita permissões de notificação
  Future<bool> checkNotificationPermissions() async {
    try {
      final hasPermissions = await _notificationService.requestPermission();
      if (!hasPermissions) {
        _setError('Permissões de notificação são necessárias para lembretes de hábitos');
      }
      return hasPermissions;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  // Verifica se pode usar alarmes exatos
  Future<bool> canUseExactAlarms() async {
    try {
      return await _notificationService.canScheduleExactAlarms();
    } catch (e) {
      debugPrint('Error checking exact alarms capability: $e');
      return false;
    }
  }
} 
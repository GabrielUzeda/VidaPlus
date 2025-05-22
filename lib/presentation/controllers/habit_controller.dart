// Controller de hábitos com ChangeNotifier
import 'package:flutter/foundation.dart';
import 'package:vida_plus/domain/entities/habit.dart';
import 'package:vida_plus/domain/usecases/habit/get_habits.dart';
import 'package:vida_plus/domain/usecases/habit/manage_habit.dart';

enum HabitStatus {
  initial,
  loading,
  success,
  error,
}

class HabitController extends ChangeNotifier {
  final GetHabits _getHabits;
  final GetHabitsByFrequency _getHabitsByFrequency;
  final CreateHabit _createHabit;
  final UpdateHabit _updateHabit;
  final DeleteHabit _deleteHabit;

  HabitStatus _status = HabitStatus.initial;
  List<Habit> _habits = [];
  String? _errorMessage;
  
  HabitController({
    required GetHabits getHabits,
    required GetHabitsByFrequency getHabitsByFrequency,
    required CreateHabit createHabit,
    required UpdateHabit updateHabit,
    required DeleteHabit deleteHabit,
  })  : _getHabits = getHabits,
        _getHabitsByFrequency = getHabitsByFrequency,
        _createHabit = createHabit,
        _updateHabit = updateHabit,
        _deleteHabit = deleteHabit;

  HabitStatus get status => _status;
  List<Habit> get habits => _habits;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == HabitStatus.loading;

  Future<void> loadHabits(String userId) async {
    try {
      _status = HabitStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _habits = await _getHabits(userId);
      _status = HabitStatus.success;
    } catch (e) {
      _status = HabitStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadHabitsByFrequency(String userId, Frequency frequency) async {
    try {
      _status = HabitStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _habits = await _getHabitsByFrequency(userId, frequency);
      _status = HabitStatus.success;
    } catch (e) {
      _status = HabitStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> createHabit({
    required String userId,
    required String name,
    required String description,
    required Frequency frequency,
    required TimeOfDay preferredTime,
  }) async {
    try {
      _status = HabitStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final habit = await _createHabit(
        userId: userId,
        name: name,
        description: description,
        frequency: frequency,
        preferredTime: preferredTime,
      );
      
      _habits = [..._habits, habit];
      _status = HabitStatus.success;
    } catch (e) {
      _status = HabitStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateHabit({
    required String id,
    String? name,
    String? description,
    Frequency? frequency,
    TimeOfDay? preferredTime,
    bool? active,
  }) async {
    try {
      _status = HabitStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final updatedHabit = await _updateHabit(
        id: id,
        name: name,
        description: description,
        frequency: frequency,
        preferredTime: preferredTime,
        active: active,
      );
      
      _habits = _habits.map((habit) => 
        habit.id == id ? updatedHabit : habit
      ).toList();
      
      _status = HabitStatus.success;
    } catch (e) {
      _status = HabitStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      _status = HabitStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _deleteHabit(id);
      
      // Remove o hábito da lista local
      _habits = _habits.where((habit) => habit.id != id).toList();
      _status = HabitStatus.success;
    } catch (e) {
      _status = HabitStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
} 
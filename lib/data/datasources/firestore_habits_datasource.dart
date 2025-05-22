import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';
import '../models/checkin_model.dart';

// Datasource para operações de hábitos e check-ins com Firestore
class FirestoreHabitsDatasource {
  final FirebaseFirestore _firestore;

  FirestoreHabitsDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Obtém todos os hábitos ativos do usuário
  Future<List<HabitModel>> getUserHabits(String userId) async {
    final snapshot = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => HabitModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Stream dos hábitos do usuário
  Stream<List<HabitModel>> getUserHabitsStream(String userId) {
    return _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => HabitModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Cria um novo hábito
  Future<HabitModel> createHabit(HabitModel habit) async {
    final docRef = await _firestore.collection('habits').add(habit.toMap());
    return habit.copyWith(id: docRef.id);
  }

  // Atualiza um hábito existente
  Future<HabitModel> updateHabit(HabitModel habit) async {
    final updatedHabit = habit.copyWith(updatedAt: DateTime.now());
    
    await _firestore
        .collection('habits')
        .doc(habit.id)
        .update(updatedHabit.toMap());
    
    return updatedHabit;
  }

  // Remove um hábito (marca como inativo)
  Future<void> deleteHabit(String habitId) async {
    await _firestore.collection('habits').doc(habitId).update({
      'isActive': false,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Obtém um hábito por ID
  Future<HabitModel?> getHabitById(String habitId) async {
    final doc = await _firestore.collection('habits').doc(habitId).get();
    
    if (!doc.exists) return null;
    
    return HabitModel.fromMap(doc.data()!, doc.id);
  }

  // Registra um check-in para um hábito
  Future<CheckInModel> createCheckIn(CheckInModel checkIn) async {
    // Normaliza a data para o início do dia
    final normalizedDate = DateTime(
      checkIn.date.year,
      checkIn.date.month,
      checkIn.date.day,
    );

    final checkInWithNormalizedDate = checkIn.copyWith(date: normalizedDate);
    
    final docRef = await _firestore
        .collection('checkins')
        .add(checkInWithNormalizedDate.toMap());
    
    return checkInWithNormalizedDate.copyWith(id: docRef.id);
  }

  // Obtém check-ins por hábito e data
  Future<List<CheckInModel>> getCheckInsForHabitAndDate({
    required String habitId,
    required DateTime date,
  }) async {
    // Normaliza a data para o início do dia
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final nextDay = normalizedDate.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('checkins')
        .where('habitId', isEqualTo: habitId)
        .where('date', isGreaterThanOrEqualTo: normalizedDate.millisecondsSinceEpoch)
        .where('date', isLessThan: nextDay.millisecondsSinceEpoch)
        .get();

    return snapshot.docs
        .map((doc) => CheckInModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Obtém check-ins por usuário e data
  Future<List<CheckInModel>> getCheckInsForUserAndDate({
    required String userId,
    required DateTime date,
  }) async {
    // Normaliza a data para o início do dia
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final nextDay = normalizedDate.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('checkins')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: normalizedDate.millisecondsSinceEpoch)
        .where('date', isLessThan: nextDay.millisecondsSinceEpoch)
        .get();

    return snapshot.docs
        .map((doc) => CheckInModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Obtém histórico de check-ins para um hábito
  Future<List<CheckInModel>> getHabitCheckInHistory({
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore
        .collection('checkins')
        .where('habitId', isEqualTo: habitId);

    if (startDate != null) {
      final normalizedStartDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      query = query.where('date', 
          isGreaterThanOrEqualTo: normalizedStartDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      final normalizedEndDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      ).add(const Duration(days: 1)); // Inclui o dia completo
      query = query.where('date', 
          isLessThan: normalizedEndDate.millisecondsSinceEpoch);
    }

    query = query.orderBy('date', descending: true);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => CheckInModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Obtém estatísticas de progresso para um usuário
  Future<Map<String, dynamic>> getUserProgress({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Define período padrão se não fornecido (últimos 30 dias)
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 30));

    // Normaliza as datas
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day)
        .add(const Duration(days: 1));

    // Busca hábitos do usuário
    final habitsSnapshot = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .get();

    final habits = habitsSnapshot.docs
        .map((doc) => HabitModel.fromMap(doc.data(), doc.id))
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
    final checkInsSnapshot = await _firestore
        .collection('checkins')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: normalizedStart.millisecondsSinceEpoch)
        .where('date', isLessThan: normalizedEnd.millisecondsSinceEpoch)
        .get();

    final checkIns = checkInsSnapshot.docs
        .map((doc) => CheckInModel.fromMap(doc.data(), doc.id))
        .toList();

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
      final habitCheckIns = checkIns
          .where((c) => c.habitId == habit.id)
          .toList();

      habitProgress[habit.id] = {
        'name': habit.name,
        'frequency': habit.frequency.name,
        'totalCheckIns': habitCheckIns.length,
        'checkInDates': habitCheckIns
            .map((c) => DateFormat('yyyy-MM-dd').format(c.date))
            .toList(),
      };
    }

    // Calcula taxa de conclusão aproximada
    final daysDifference = normalizedEnd.difference(normalizedStart).inDays;
    final expectedCheckIns = habits.length * daysDifference;
    final completionRate = expectedCheckIns > 0 
        ? (totalCheckIns / expectedCheckIns).clamp(0.0, 1.0)
        : 0.0;

    return {
      'totalHabits': habits.length,
      'totalCheckIns': totalCheckIns,
      'completionRate': completionRate,
      'dailyProgress': dailyProgress,
      'habitProgress': habitProgress,
    };
  }
} 
// Fonte de dados para check-ins com Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:vida_plus/data/models/checkin_model.dart';

abstract class FirestoreCheckInDatasource {
  Future<List<CheckInModel>> getCheckInsByUserAndDate(String userId, DateTime date);
  Future<List<CheckInModel>> getCheckInsByHabit(String habitId, {DateTime? startDate, DateTime? endDate});
  Future<CheckInModel> createCheckIn({
    required String habitId,
    required String userId,
    required DateTime date,
    required bool completed,
    String? note,
  });
  Future<CheckInModel> updateCheckIn({
    required String id,
    bool? completed,
    String? note,
  });
  Future<void> deleteCheckIn(String id);
}

class FirestoreCheckInDatasourceImpl implements FirestoreCheckInDatasource {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'checkins';
  final Uuid _uuid = const Uuid();

  FirestoreCheckInDatasourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  @override
  Future<List<CheckInModel>> getCheckInsByUserAndDate(String userId, DateTime date) async {
    try {
      // Normaliza a data para comparar apenas dia/mês/ano
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
          .get();

      return querySnapshot.docs
          .map((doc) => CheckInModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar check-ins: $e');
    }
  }

  @override
  Future<List<CheckInModel>> getCheckInsByHabit(String habitId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      Query<Map<String, dynamic>> query = _collection.where('habitId', isEqualTo: habitId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate.toIso8601String());
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => CheckInModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar check-ins por hábito: $e');
    }
  }

  @override
  Future<CheckInModel> createCheckIn({
    required String habitId,
    required String userId,
    required DateTime date,
    required bool completed,
    String? note,
  }) async {
    try {
      final now = DateTime.now();
      final checkInId = _uuid.v4();
      
      final checkInData = {
        'habitId': habitId,
        'userId': userId,
        'date': date.toIso8601String(),
        'completed': completed,
        'note': note,
        'createdAt': now.toIso8601String(),
      };

      await _collection.doc(checkInId).set(checkInData);

      return CheckInModel.fromJson({
        'id': checkInId,
        ...checkInData,
      });
    } catch (e) {
      throw Exception('Erro ao criar check-in: $e');
    }
  }

  @override
  Future<CheckInModel> updateCheckIn({
    required String id,
    bool? completed,
    String? note,
  }) async {
    try {
      // Obtém o documento atual para manter os dados não atualizados
      final checkInDoc = await _collection.doc(id).get();
      if (!checkInDoc.exists) {
        throw Exception('Check-in não encontrado');
      }
      
      final checkInData = checkInDoc.data()!;
      final updateData = {
        if (completed != null) 'completed': completed,
        if (note != null) 'note': note,
      };

      await _collection.doc(id).update(updateData);

      return CheckInModel.fromJson({
        'id': id,
        ...checkInData,
        ...updateData,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar check-in: $e');
    }
  }

  @override
  Future<void> deleteCheckIn(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir check-in: $e');
    }
  }
} 
// Fonte de dados para hábitos com Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:vida_plus/data/models/habit_model.dart';

abstract class FirestoreHabitDatasource {
  Future<List<HabitModel>> getHabits(String userId);
  Future<HabitModel> getHabitById(String id);
  Future<List<HabitModel>> getHabitsByFrequency(String userId, String frequency);
  Future<HabitModel> createHabit({
    required String userId,
    required String name,
    required String description,
    required String frequency,
    required Map<String, dynamic> preferredTime,
  });
  Future<HabitModel> updateHabit({
    required String id,
    String? name,
    String? description,
    String? frequency,
    Map<String, dynamic>? preferredTime,
    bool? active,
  });
  Future<void> deleteHabit(String id);
}

class FirestoreHabitDatasourceImpl implements FirestoreHabitDatasource {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'habits';
  final Uuid _uuid = const Uuid();

  FirestoreHabitDatasourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  @override
  Future<List<HabitModel>> getHabits(String userId) async {
    try {
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('active', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HabitModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar hábitos: $e');
    }
  }

  @override
  Future<HabitModel> getHabitById(String id) async {
    try {
      final documentSnapshot = await _collection.doc(id).get();
      if (!documentSnapshot.exists) {
        throw Exception('Hábito não encontrado');
      }

      return HabitModel.fromJson({
        'id': documentSnapshot.id,
        ...documentSnapshot.data()!,
      });
    } catch (e) {
      throw Exception('Erro ao buscar hábito: $e');
    }
  }

  @override
  Future<List<HabitModel>> getHabitsByFrequency(String userId, String frequency) async {
    try {
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('frequency', isEqualTo: frequency)
          .where('active', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HabitModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar hábitos por frequência: $e');
    }
  }

  @override
  Future<HabitModel> createHabit({
    required String userId,
    required String name,
    required String description,
    required String frequency,
    required Map<String, dynamic> preferredTime,
  }) async {
    try {
      final now = DateTime.now();
      final habitId = _uuid.v4();
      
      final habitData = {
        'userId': userId,
        'name': name,
        'description': description,
        'frequency': frequency,
        'preferredTime': preferredTime,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'active': true,
      };

      await _collection.doc(habitId).set(habitData);

      return HabitModel.fromJson({
        'id': habitId,
        ...habitData,
      });
    } catch (e) {
      throw Exception('Erro ao criar hábito: $e');
    }
  }

  @override
  Future<HabitModel> updateHabit({
    required String id,
    String? name,
    String? description,
    String? frequency,
    Map<String, dynamic>? preferredTime,
    bool? active,
  }) async {
    try {
      final now = DateTime.now();
      
      // Obtém o documento atual para manter os dados não atualizados
      final habitDoc = await _collection.doc(id).get();
      if (!habitDoc.exists) {
        throw Exception('Hábito não encontrado');
      }
      
      final habitData = habitDoc.data()!;
      final updateData = {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (frequency != null) 'frequency': frequency,
        if (preferredTime != null) 'preferredTime': preferredTime,
        if (active != null) 'active': active,
        'updatedAt': now.toIso8601String(),
      };

      await _collection.doc(id).update(updateData);

      return HabitModel.fromJson({
        'id': id,
        ...habitData,
        ...updateData,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar hábito: $e');
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      // Soft delete - apenas marca como inativo
      await _collection.doc(id).update({
        'active': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao excluir hábito: $e');
    }
  }
} 
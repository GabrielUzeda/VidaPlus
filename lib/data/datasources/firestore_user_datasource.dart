// Fonte de dados para usuários com Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vida_plus/data/models/user_model.dart';

abstract class FirestoreUserDatasource {
  Future<UserModel> getUserById(String id);
  Future<UserModel> createUser({
    required String id,
    required String email,
    required String name,
    String? photoUrl,
  });
  Future<UserModel> updateUser({
    required String id,
    String? name,
    String? photoUrl,
  });
  Future<void> deleteUser(String id);
}

class FirestoreUserDatasourceImpl implements FirestoreUserDatasource {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'users';

  FirestoreUserDatasourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final documentSnapshot = await _collection.doc(id).get();
      if (!documentSnapshot.exists) {
        throw Exception('Usuário não encontrado');
      }

      final data = documentSnapshot.data();
      if (data == null) {
        throw Exception('Dados do usuário não encontrados');
      }

      return UserModel.fromJson({
        'id': documentSnapshot.id,
        ...data,
      });
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  @override
  Future<UserModel> createUser({
    required String id,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    try {
      final now = DateTime.now();
      final userData = {
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      await _collection.doc(id).set(userData);

      return UserModel(
        id: id,
        email: email,
        name: name,
        photoUrl: photoUrl,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Erro ao criar usuário: $e');
    }
  }

  @override
  Future<UserModel> updateUser({
    required String id,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final now = DateTime.now();
      
      // Obtém o documento atual para manter os dados não atualizados
      final userDoc = await _collection.doc(id).get();
      if (!userDoc.exists) {
        throw Exception('Usuário não encontrado');
      }
      
      final userData = userDoc.data()!;
      final updateData = {
        if (name != null) 'name': name,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': now.toIso8601String(),
      };

      await _collection.doc(id).update(updateData);

      return UserModel(
        id: id,
        email: userData['email'] as String,
        name: name ?? userData['name'] as String,
        photoUrl: photoUrl ?? userData['photoUrl'] as String?,
        createdAt: DateTime.parse(userData['createdAt'] as String),
        updatedAt: now,
      );
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir usuário: $e');
    }
  }
} 
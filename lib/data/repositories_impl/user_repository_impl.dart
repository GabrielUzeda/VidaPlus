// Implementação do repositório de usuários
import 'package:vida_plus/data/datasources/firestore_user_datasource.dart';
import 'package:vida_plus/domain/entities/user.dart';
import 'package:vida_plus/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirestoreUserDatasource _userDatasource;

  UserRepositoryImpl({
    required FirestoreUserDatasource userDatasource,
  }) : _userDatasource = userDatasource;

  @override
  Future<User> getUserById(String id) async {
    try {
      return await _userDatasource.getUserById(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> createUser({
    required String id,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    try {
      // Na implementação real, isso nunca deve ser chamado diretamente
      // já que o usuário é criado durante o signup no AuthRepository
      throw UnimplementedError('Este método não deve ser chamado diretamente');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> updateUser({
    required String id,
    String? name,
    String? photoUrl,
  }) async {
    try {
      return await _userDatasource.updateUser(
        id: id,
        name: name,
        photoUrl: photoUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _userDatasource.deleteUser(id);
    } catch (e) {
      rethrow;
    }
  }
} 
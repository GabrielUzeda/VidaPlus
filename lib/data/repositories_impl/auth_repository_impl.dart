// Implementação do repositório de autenticação
import 'package:vida_plus/data/datasources/firebase_auth_datasource.dart';
import 'package:vida_plus/data/datasources/firestore_user_datasource.dart';
import 'package:vida_plus/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _authDatasource;
  final FirestoreUserDatasource _userDatasource;

  AuthRepositoryImpl({
    required FirebaseAuthDatasource authDatasource,
    required FirestoreUserDatasource userDatasource,
  })  : _authDatasource = authDatasource,
        _userDatasource = userDatasource;

  @override
  Future<String> signIn(String email, String password) async {
    try {
      return await _authDatasource.signIn(email, password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  @override
  Future<String> signUp(String email, String password, String name) async {
    try {
      // Primeiro, cria o usuário na autenticação
      final userId = await _authDatasource.signUp(email, password);

      // Em seguida, cria o perfil do usuário no Firestore
      await _userDatasource.createUser(
        id: userId,
        email: email,
        name: name,
      );

      return userId;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authDatasource.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    try {
      return await _authDatasource.getCurrentUserId();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      return await _authDatasource.isSignedIn();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _authDatasource.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }
} 
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

// Implementação do repositório de autenticação (SOLID - Dependency Inversion)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _datasource;

  AuthRepositoryImpl({
    required FirebaseAuthDatasource datasource,
  }) : _datasource = datasource;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userModel = await _datasource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _datasource.authStateChanges.map((userModel) => userModel?.toEntity());
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userModel = await _datasource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    final userModel = await _datasource.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await _datasource.signOut();
  }

  @override
  Future<UserEntity> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    final userModel = await _datasource.updateProfile(
      name: name,
      profileImageUrl: profileImageUrl,
    );
    return userModel.toEntity();
  }

  @override
  Future<String> uploadProfileImage(String filePath) async {
    return await _datasource.uploadProfileImage(filePath);
  }
} 
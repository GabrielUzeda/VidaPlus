import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_auth_datasource.dart';

// Implementação do repositório de autenticação local (SOLID - Dependency Inversion)
class LocalAuthRepositoryImpl implements AuthRepository {
  final LocalAuthDatasource _datasource;

  LocalAuthRepositoryImpl({
    required LocalAuthDatasource datasource,
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

  // Método adicional para login como convidado
  Future<UserEntity> signInAsGuest() async {
    final userModel = await _datasource.signInAsGuest();
    return userModel.toEntity();
  }

  // Método adicional para login com Google
  Future<UserEntity> signInWithGoogle() async {
    final userModel = await _datasource.signInWithGoogle();
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

  // Método adicional para verificar se é convidado
  Future<bool> isGuest() async {
    return await _datasource.isGuest();
  }

  // Método adicional para limpar dados (para testes)
  Future<void> clearAllData() async {
    await _datasource.clearAllData();
  }
} 
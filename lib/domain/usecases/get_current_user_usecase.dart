import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'base_usecase.dart';

// Caso de uso para obter o usuário atual
class GetCurrentUserUseCase implements NoParamsUseCase<UserEntity?> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<UserEntity?> call() async {
    return await _authRepository.getCurrentUser();
  }
}

// Caso de uso para stream do estado de autenticação
class GetAuthStateUseCase implements NoParamsStreamUseCase<UserEntity?> {
  final AuthRepository _authRepository;

  GetAuthStateUseCase(this._authRepository);

  @override
  Stream<UserEntity?> call() {
    return _authRepository.authStateChanges;
  }
} 
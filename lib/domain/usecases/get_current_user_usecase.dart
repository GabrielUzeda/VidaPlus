import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'base_usecase.dart';

class GetCurrentUserUseCase implements NoParamsUseCase<UserEntity?> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<UserEntity?> call() async {
    return await _authRepository.getCurrentUser();
  }
}

class GetAuthStateUseCase implements NoParamsStreamUseCase<UserEntity?> {
  final AuthRepository _authRepository;

  GetAuthStateUseCase(this._authRepository);

  @override
  Stream<UserEntity?> call() {
    return _authRepository.authStateChanges;
  }
} 
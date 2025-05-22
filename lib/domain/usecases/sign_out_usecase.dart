import '../repositories/auth_repository.dart';
import 'base_usecase.dart';

// Caso de uso para logout do usuário
class SignOutUseCase implements NoParamsUseCase<void> {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  @override
  Future<void> call() async {
    await _authRepository.signOut();
  }
} 
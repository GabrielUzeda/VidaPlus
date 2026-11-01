import '../repositories/auth_repository.dart';
import 'base_usecase.dart';

class SignOutUseCase implements NoParamsUseCase<void> {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  @override
  Future<void> call() async {
    await _authRepository.signOut();
  }
} 
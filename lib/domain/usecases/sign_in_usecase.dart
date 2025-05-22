import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'base_usecase.dart';

// Caso de uso para login do usuário
class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  @override
  Future<UserEntity> call(SignInParams params) async {
    // Valida os parâmetros de entrada
    if (params.email.isEmpty) {
      throw Exception('Email é obrigatório');
    }
    
    if (params.password.isEmpty) {
      throw Exception('Senha é obrigatória');
    }

    if (!_isValidEmail(params.email)) {
      throw Exception('Email inválido');
    }

    if (params.password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    // Executa o login
    return await _authRepository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }

  // Validação de email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

// Parâmetros para o caso de uso de login
class SignInParams {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });
} 
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'base_usecase.dart';

// Caso de uso para cadastro do usuário
class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  @override
  Future<UserEntity> call(SignUpParams params) async {
    // Valida os parâmetros de entrada
    if (params.email.isEmpty) {
      throw Exception('Email é obrigatório');
    }
    
    if (params.password.isEmpty) {
      throw Exception('Senha é obrigatória');
    }

    if (params.name.isEmpty) {
      throw Exception('Nome é obrigatório');
    }

    if (!_isValidEmail(params.email)) {
      throw Exception('Email inválido');
    }

    if (params.password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    if (params.name.length < 2) {
      throw Exception('Nome deve ter pelo menos 2 caracteres');
    }

    // Executa o cadastro
    return await _authRepository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }

  // Validação de email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

// Parâmetros para o caso de uso de cadastro
class SignUpParams {
  final String email;
  final String password;
  final String name;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
} 
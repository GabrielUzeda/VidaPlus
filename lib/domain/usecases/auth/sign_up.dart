// Caso de uso para fazer cadastro
import '../../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository _authRepository;

  SignUp(this._authRepository);

  Future<String> call({
    required String email,
    required String password,
    required String name,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Email inválido');
    }

    if (password.isEmpty || password.length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    if (name.isEmpty) {
      throw Exception('Nome não pode estar vazio');
    }

    try {
      return await _authRepository.signUp(email, password, name);
    } catch (e) {
      throw Exception('Erro ao criar conta: ${e.toString()}');
    }
  }
} 
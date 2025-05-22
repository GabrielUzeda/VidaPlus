// Caso de uso para fazer login
import '../../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository _authRepository;

  SignIn(this._authRepository);

  Future<String> call({required String email, required String password}) async {
    if (email.isEmpty) {
      throw Exception('Email não pode estar vazio');
    }

    if (password.isEmpty) {
      throw Exception('Senha não pode estar vazia');
    }

    try {
      return await _authRepository.signIn(email, password);
    } catch (e) {
      throw Exception('Erro ao fazer login: ${e.toString()}');
    }
  }
} 
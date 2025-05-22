// Caso de uso para obter o usuário atual
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';

class GetCurrentUser {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  GetCurrentUser(this._authRepository, this._userRepository);

  Future<User?> call() async {
    final userId = await _authRepository.getCurrentUserId();
    if (userId == null) {
      return null;
    }
    try {
      return await _userRepository.getUserById(userId);
    } catch (e) {
      throw Exception('Erro ao obter usuário atual: ${e.toString()}');
    }
  }
} 
import '../entities/user_entity.dart';

// Interface para o repositório de autenticação (SOLID - Dependency Inversion)
abstract class AuthRepository {
  // Obtém o usuário atualmente autenticado
  Future<UserEntity?> getCurrentUser();
  
  // Stream do estado de autenticação
  Stream<UserEntity?> get authStateChanges;
  
  // Realiza login com email e senha
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  // Registra novo usuário com email e senha
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });
  
  // Realiza logout
  Future<void> signOut();
  
  // Atualiza o perfil do usuário
  Future<UserEntity> updateProfile({
    String? name,
    String? profileImageUrl,
  });
  
  // Faz upload da imagem de perfil
  Future<String> uploadProfileImage(String filePath);
} 
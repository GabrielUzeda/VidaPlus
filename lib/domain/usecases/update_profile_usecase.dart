import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'base_usecase.dart';

// Caso de uso para atualizar perfil do usuário
class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository _authRepository;

  UpdateProfileUseCase(this._authRepository);

  @override
  Future<UserEntity> call(UpdateProfileParams params) async {
    // Valida os parâmetros
    if (params.name != null && params.name!.length < 2) {
      throw Exception('Nome deve ter pelo menos 2 caracteres');
    }

    String? profileImageUrl;
    
    // Faz upload da imagem se fornecida
    if (params.profileImagePath != null) {
      profileImageUrl = await _authRepository.uploadProfileImage(params.profileImagePath!);
    }

    // Atualiza o perfil
    return await _authRepository.updateProfile(
      name: params.name,
      profileImageUrl: profileImageUrl ?? params.profileImageUrl,
    );
  }
}

// Parâmetros para atualização de perfil
class UpdateProfileParams {
  final String? name;
  final String? profileImagePath;
  final String? profileImageUrl;

  const UpdateProfileParams({
    this.name,
    this.profileImagePath,
    this.profileImageUrl,
  });
} 
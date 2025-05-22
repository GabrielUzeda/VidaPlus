import '../../domain/entities/user_entity.dart';

// Model para conversão de dados do usuário entre Firebase e entidade do domínio
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.profileImageUrl,
    required super.createdAt,
    super.updatedAt,
  });

  // Cria um UserModel a partir de um Map (Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] as String,
      name: map['name'] as String,
      profileImageUrl: map['profileImageUrl'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
    );
  }

  // Converte UserModel para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // Cria um UserModel a partir de uma UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      profileImageUrl: entity.profileImageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Converte UserModel para UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Cria uma cópia do model com campos atualizados
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
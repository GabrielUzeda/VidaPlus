import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';

part 'local_user_model.g.dart';

@HiveType(typeId: 0)
class LocalUserModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String name;

  @HiveField(3)
  String? profileImageUrl;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  @HiveField(6)
  bool isGuest;

  LocalUserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.isGuest = false,
  });

  // Cria um LocalUserModel a partir de um Map
  factory LocalUserModel.fromMap(Map<String, dynamic> map, String id) {
    return LocalUserModel(
      id: id,
      email: map['email'] as String,
      name: map['name'] as String,
      profileImageUrl: map['profileImageUrl'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      isGuest: map['isGuest'] as bool? ?? false,
    );
  }

  // Converte LocalUserModel para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isGuest': isGuest,
    };
  }

  // Cria um LocalUserModel a partir de uma UserEntity
  factory LocalUserModel.fromEntity(UserEntity entity, {bool isGuest = false}) {
    return LocalUserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      profileImageUrl: entity.profileImageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isGuest: isGuest,
    );
  }

  // Converte LocalUserModel para UserEntity
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

  // Cria um usuário guest padrão
  factory LocalUserModel.guest() {
    final now = DateTime.now();
    return LocalUserModel(
      id: 'guest_user',
      email: 'guest@vidaplus.local',
      name: 'Convidado(a)',
      profileImageUrl: 'assets/images/default_avatar.svg',
      createdAt: now,
      updatedAt: now,
      isGuest: true,
    );
  }

  // Cria uma cópia do model com campos atualizados
  LocalUserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isGuest,
  }) {
    return LocalUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  String toString() {
    return 'LocalUserModel(id: $id, email: $email, name: $name, isGuest: $isGuest)';
  }
} 
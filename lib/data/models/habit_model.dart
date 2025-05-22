import '../../domain/entities/habit_entity.dart';

// Model para conversão de dados do hábito entre Firebase e entidade do domínio
class HabitModel extends HabitEntity {
  const HabitModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.frequency,
    super.recommendedTime,
    required super.createdAt,
    super.updatedAt,
    super.isActive = true,
  });

  // Cria um HabitModel a partir de um Map (Firestore)
  factory HabitModel.fromMap(Map<String, dynamic> map, String id) {
    return HabitModel(
      id: id,
      userId: map['userId'] as String,
      name: map['name'] as String,
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
      ),
      recommendedTime: map['recommendedTime'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  // Converte HabitModel para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'frequency': frequency.name,
      'recommendedTime': recommendedTime,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  // Cria um HabitModel a partir de uma HabitEntity
  factory HabitModel.fromEntity(HabitEntity entity) {
    return HabitModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      frequency: entity.frequency,
      recommendedTime: entity.recommendedTime,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
    );
  }

  // Converte HabitModel para HabitEntity
  HabitEntity toEntity() {
    return HabitEntity(
      id: id,
      userId: userId,
      name: name,
      frequency: frequency,
      recommendedTime: recommendedTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  // Cria uma cópia do model com campos atualizados
  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    HabitFrequency? frequency,
    String? recommendedTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      recommendedTime: recommendedTime ?? this.recommendedTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
} 
import 'package:hive/hive.dart';
import '../../domain/entities/habit_entity.dart';

part 'local_habit_model.g.dart';

@HiveType(typeId: 1)
class LocalHabitModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String userId;

  @HiveField(2)
  late String name;

  @HiveField(3)
  late String frequency; // 'daily' or 'weekly'

  @HiveField(4)
  String? recommendedTime;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  DateTime? updatedAt;

  @HiveField(7)
  bool isActive;

  LocalHabitModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.frequency,
    this.recommendedTime,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  // Cria um LocalHabitModel a partir de um Map
  factory LocalHabitModel.fromMap(Map<String, dynamic> map, String id) {
    return LocalHabitModel(
      id: id,
      userId: map['userId'] as String,
      name: map['name'] as String,
      frequency: map['frequency'] as String,
      recommendedTime: map['recommendedTime'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  // Converte LocalHabitModel para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'frequency': frequency,
      'recommendedTime': recommendedTime,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  // Cria um LocalHabitModel a partir de uma HabitEntity
  factory LocalHabitModel.fromEntity(HabitEntity entity) {
    return LocalHabitModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      frequency: entity.frequency.name,
      recommendedTime: entity.recommendedTime,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
    );
  }

  // Converte LocalHabitModel para HabitEntity
  HabitEntity toEntity() {
    return HabitEntity(
      id: id,
      userId: userId,
      name: name,
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.name == frequency,
      ),
      recommendedTime: recommendedTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  // Cria uma cópia do model com campos atualizados
  LocalHabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? frequency,
    String? recommendedTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return LocalHabitModel(
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

  @override
  String toString() {
    return 'LocalHabitModel(id: $id, name: $name, frequency: $frequency, isActive: $isActive)';
  }
} 
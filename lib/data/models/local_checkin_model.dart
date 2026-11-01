import 'package:hive/hive.dart';
import '../../domain/entities/checkin_entity.dart';

part 'local_checkin_model.g.dart';

@HiveType(typeId: 2)
class LocalCheckInModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String habitId;

  @HiveField(2)
  late String userId;

  @HiveField(3)
  late DateTime completedAt;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  String? notes;

  LocalCheckInModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    required this.date,
    this.notes,
  });

  // Cria um LocalCheckInModel a partir de um Map
  factory LocalCheckInModel.fromMap(Map<String, dynamic> map, String id) {
    return LocalCheckInModel(
      id: id,
      habitId: map['habitId'] as String,
      userId: map['userId'] as String,
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      notes: map['notes'] as String?,
    );
  }

  // Converte LocalCheckInModel para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'userId': userId,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  // Cria um LocalCheckInModel a partir de uma CheckInEntity
  factory LocalCheckInModel.fromEntity(CheckInEntity entity) {
    return LocalCheckInModel(
      id: entity.id,
      habitId: entity.habitId,
      userId: entity.userId,
      completedAt: entity.completedAt,
      date: entity.date,
      notes: entity.notes,
    );
  }

  // Converte LocalCheckInModel para CheckInEntity
  CheckInEntity toEntity() {
    return CheckInEntity(
      id: id,
      habitId: habitId,
      userId: userId,
      completedAt: completedAt,
      date: date,
      notes: notes,
    );
  }

  // Cria uma cópia do model com campos atualizados
  LocalCheckInModel copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? completedAt,
    DateTime? date,
    String? notes,
  }) {
    return LocalCheckInModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'LocalCheckInModel(id: $id, habitId: $habitId, date: $date)';
  }
} 
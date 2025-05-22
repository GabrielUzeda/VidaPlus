import '../../domain/entities/checkin_entity.dart';

// Model para conversão de dados do check-in entre Firebase e entidade do domínio
class CheckInModel extends CheckInEntity {
  const CheckInModel({
    required super.id,
    required super.habitId,
    required super.userId,
    required super.completedAt,
    required super.date,
    super.notes,
  });

  // Cria um CheckInModel a partir de um Map (Firestore)
  factory CheckInModel.fromMap(Map<String, dynamic> map, String id) {
    return CheckInModel(
      id: id,
      habitId: map['habitId'] as String,
      userId: map['userId'] as String,
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      notes: map['notes'] as String?,
    );
  }

  // Converte CheckInModel para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'userId': userId,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  // Cria um CheckInModel a partir de uma CheckInEntity
  factory CheckInModel.fromEntity(CheckInEntity entity) {
    return CheckInModel(
      id: entity.id,
      habitId: entity.habitId,
      userId: entity.userId,
      completedAt: entity.completedAt,
      date: entity.date,
      notes: entity.notes,
    );
  }

  // Converte CheckInModel para CheckInEntity
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
  @override
  CheckInModel copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? completedAt,
    DateTime? date,
    String? notes,
  }) {
    return CheckInModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
} 
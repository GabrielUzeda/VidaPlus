// Entidade que representa um check-in de hábito
class CheckInEntity {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final DateTime date; // Data do check-in normalizada (sem horário)
  final String? notes; // Notas opcionais do usuário

  const CheckInEntity({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    required this.date,
    this.notes,
  });

  // Cria uma cópia da entidade com campos atualizados
  CheckInEntity copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? completedAt,
    DateTime? date,
    String? notes,
  }) {
    return CheckInEntity(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckInEntity &&
        other.id == id &&
        other.habitId == habitId &&
        other.userId == userId &&
        other.completedAt == completedAt &&
        other.date == date &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        habitId.hashCode ^
        userId.hashCode ^
        completedAt.hashCode ^
        date.hashCode ^
        notes.hashCode;
  }
} 
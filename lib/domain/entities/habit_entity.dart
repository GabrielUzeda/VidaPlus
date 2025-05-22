// Enumerador que define a frequência de um hábito
enum HabitFrequency {
  daily,  // Diário
  weekly; // Semanal

  // Converte o enum para string em português
  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Diário';
      case HabitFrequency.weekly:
        return 'Semanal';
    }
  }
}

// Entidade que representa um hábito no domínio da aplicação
class HabitEntity {
  final String id;
  final String userId;
  final String name;
  final HabitFrequency frequency;
  final String? recommendedTime; // Horário recomendado (formato: "08:00")
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const HabitEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.frequency,
    this.recommendedTime,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  // Cria uma cópia da entidade com campos atualizados
  HabitEntity copyWith({
    String? id,
    String? userId,
    String? name,
    HabitFrequency? frequency,
    String? recommendedTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return HabitEntity(
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitEntity &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.frequency == frequency &&
        other.recommendedTime == recommendedTime &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        frequency.hashCode ^
        recommendedTime.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isActive.hashCode;
  }
} 
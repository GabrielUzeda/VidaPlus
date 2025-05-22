// Entidade Habit para a camada de domínio

enum Frequency {
  daily,
  weekly,
  custom
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({
    required this.hour,
    required this.minute,
  });

  @override
  String toString() {
    final hourString = hour.toString().padLeft(2, '0');
    final minuteString = minute.toString().padLeft(2, '0');
    return '$hourString:$minuteString';
  }
}

class Habit {
  final String id;
  final String userId;
  final String name;
  final String description;
  final Frequency frequency;
  final TimeOfDay preferredTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;

  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.frequency,
    required this.preferredTime,
    required this.createdAt, 
    required this.updatedAt,
    this.active = true,
  });
} 
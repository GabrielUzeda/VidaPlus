// Modelo Habit para a camada de dados
import '../../domain/entities/habit.dart';

class HabitModel extends Habit {
  HabitModel({
    required String id,
    required String userId,
    required String name,
    required String description,
    required Frequency frequency,
    required TimeOfDay preferredTime,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool active = true,
  }) : super(
          id: id,
          userId: userId,
          name: name,
          description: description,
          frequency: frequency,
          preferredTime: preferredTime,
          createdAt: createdAt,
          updatedAt: updatedAt,
          active: active,
        );

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      frequency: _frequencyFromString(json['frequency']),
      preferredTime: TimeOfDayModel.fromJson(json['preferredTime']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      active: json['active'] ?? true,
    );
  }

  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      userId: habit.userId,
      name: habit.name,
      description: habit.description,
      frequency: habit.frequency,
      preferredTime: habit.preferredTime,
      createdAt: habit.createdAt,
      updatedAt: habit.updatedAt,
      active: habit.active,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'frequency': _frequencyToString(frequency),
      'preferredTime': (preferredTime is TimeOfDayModel)
          ? (preferredTime as TimeOfDayModel).toJson()
          : TimeOfDayModel(hour: preferredTime.hour, minute: preferredTime.minute).toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'active': active,
    };
  }

  static String _frequencyToString(Frequency frequency) {
    switch (frequency) {
      case Frequency.daily:
        return 'daily';
      case Frequency.weekly:
        return 'weekly';
      case Frequency.custom:
        return 'custom';
      default:
        return 'daily';
    }
  }

  static Frequency _frequencyFromString(String frequency) {
    switch (frequency) {
      case 'daily':
        return Frequency.daily;
      case 'weekly':
        return Frequency.weekly;
      case 'custom':
        return Frequency.custom;
      default:
        return Frequency.daily;
    }
  }
}

class TimeOfDayModel extends TimeOfDay {
  const TimeOfDayModel({
    required int hour,
    required int minute,
  }) : super(hour: hour, minute: minute);

  factory TimeOfDayModel.fromJson(Map<String, dynamic> json) {
    return TimeOfDayModel(
      hour: json['hour'],
      minute: json['minute'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }
} 
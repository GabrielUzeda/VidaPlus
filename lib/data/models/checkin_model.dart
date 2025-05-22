// Modelo CheckIn para a camada de dados
import '../../domain/entities/checkin.dart';

class CheckInModel extends CheckIn {
  CheckInModel({
    required String id,
    required String habitId,
    required String userId,
    required DateTime date,
    required bool completed,
    String? note,
    required DateTime createdAt,
  }) : super(
          id: id,
          habitId: habitId,
          userId: userId,
          date: date,
          completed: completed,
          note: note,
          createdAt: createdAt,
        );

  factory CheckInModel.fromJson(Map<String, dynamic> json) {
    return CheckInModel(
      id: json['id'],
      habitId: json['habitId'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      completed: json['completed'],
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  factory CheckInModel.fromEntity(CheckIn checkIn) {
    return CheckInModel(
      id: checkIn.id,
      habitId: checkIn.habitId,
      userId: checkIn.userId,
      date: checkIn.date,
      completed: checkIn.completed,
      note: checkIn.note,
      createdAt: checkIn.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'userId': userId,
      'date': date.toIso8601String(),
      'completed': completed,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 
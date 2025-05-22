// Entidade CheckIn para a camada de domínio

class CheckIn {
  final String id;
  final String habitId;
  final String userId;
  final DateTime date;
  final bool completed;
  final String? note;
  final DateTime createdAt;

  const CheckIn({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.date,
    required this.completed,
    this.note,
    required this.createdAt,
  });
} 
import 'package:flutter_test/flutter_test.dart';
import 'package:vida_plus/domain/entities/habit.dart';

void main() {
  group('Habit Entity', () {
    test('should create a valid Habit with all required properties', () {
      // Arrange
      final now = DateTime.now();
      final preferredTime = const CustomTimeOfDay(hour: 8, minute: 0);
      
      // Act
      final habit = Habit(
        id: 'habit_id_1',
        userId: 'user_id_1',
        name: 'Beber água',
        description: 'Beber 2 litros de água por dia',
        frequency: Frequency.daily,
        preferredTime: preferredTime,
        createdAt: now,
        updatedAt: now,
      );
      
      // Assert
      expect(habit.id, 'habit_id_1');
      expect(habit.userId, 'user_id_1');
      expect(habit.name, 'Beber água');
      expect(habit.description, 'Beber 2 litros de água por dia');
      expect(habit.frequency, Frequency.daily);
      expect(habit.preferredTime.hour, 8);
      expect(habit.preferredTime.minute, 0);
      expect(habit.createdAt, now);
      expect(habit.updatedAt, now);
      expect(habit.active, true); // Default value
    });
    
    test('should create a valid Habit with active set to false', () {
      // Arrange
      final now = DateTime.now();
      final preferredTime = const CustomTimeOfDay(hour: 8, minute: 0);
      
      // Act
      final habit = Habit(
        id: 'habit_id_1',
        userId: 'user_id_1',
        name: 'Beber água',
        description: 'Beber 2 litros de água por dia',
        frequency: Frequency.daily,
        preferredTime: preferredTime,
        createdAt: now,
        updatedAt: now,
        active: false,
      );
      
      // Assert
      expect(habit.active, false);
    });
    
    test('CustomTimeOfDay should format time correctly', () {
      // Arrange
      final time1 = const CustomTimeOfDay(hour: 8, minute: 5);
      final time2 = const CustomTimeOfDay(hour: 18, minute: 30);
      
      // Act & Assert
      expect(time1.toString(), '08:05');
      expect(time2.toString(), '18:30');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:vidaplus/domain/entities/user_entity.dart';
import 'package:vidaplus/domain/repositories/auth_repository.dart';
import 'package:vidaplus/domain/usecases/usecases.dart';
import 'package:vidaplus/core/services/notification_service.dart';
import 'package:vidaplus/presentation/controllers/auth_controller.dart';

// Simple fake implementations for testing
class FakeAuthRepository implements AuthRepository {
  UserEntity? _currentUser;
  bool _shouldThrowError = false;
  String _errorMessage = '';

  @override
  Future<UserEntity?> getCurrentUser() async => _currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(_currentUser);

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    _currentUser = UserEntity(
      id: 'test_user_id',
      email: email,
      name: 'Test User',
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    _currentUser = UserEntity(
      id: 'test_user_id',
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<UserEntity> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
      updatedAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<String> uploadProfileImage(String filePath) async {
    return 'https://example.com/uploaded-image.jpg';
  }

  // Helper methods for testing
  void setError(String message) {
    _shouldThrowError = true;
    _errorMessage = message;
  }

  void clearError() {
    _shouldThrowError = false;
    _errorMessage = '';
  }
}

class FakeNotificationService implements NotificationService {
  bool _notificationsEnabled = true;

  @override
  Future<void> initialize() async {
    // No-op for testing
  }

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> canScheduleExactAlarms() async => true;

  @override
  Future<void> scheduleHabitReminder(habit) async {}

  @override
  Future<void> rescheduleHabitReminder(habit) async {}

  @override
  Future<void> cancelHabitReminder(String habitId) async {}

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<void> scheduleDailyCheckInReminder() async {}

  @override
  Future<bool> getNotificationsEnabled() async => _notificationsEnabled;

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {}
}

void main() {
  group('AuthController Tests', () {
    late AuthController authController;
    late FakeAuthRepository fakeAuthRepository;
    late FakeNotificationService fakeNotificationService;
    
    // Use Cases
    late SignInUseCase signInUseCase;
    late SignUpUseCase signUpUseCase;
    late SignOutUseCase signOutUseCase;
    late GetCurrentUserUseCase getCurrentUserUseCase;
    late GetAuthStateUseCase getAuthStateUseCase;
    late UpdateProfileUseCase updateProfileUseCase;

    setUp(() {
      fakeAuthRepository = FakeAuthRepository();
      fakeNotificationService = FakeNotificationService();
      
      // Cria Use Cases com o repositório fake
      signInUseCase = SignInUseCase(fakeAuthRepository);
      signUpUseCase = SignUpUseCase(fakeAuthRepository);
      signOutUseCase = SignOutUseCase(fakeAuthRepository);
      getCurrentUserUseCase = GetCurrentUserUseCase(fakeAuthRepository);
      getAuthStateUseCase = GetAuthStateUseCase(fakeAuthRepository);
      updateProfileUseCase = UpdateProfileUseCase(fakeAuthRepository);
      
      authController = AuthController(
        signInUseCase: signInUseCase,
        signUpUseCase: signUpUseCase,
        signOutUseCase: signOutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        getAuthStateUseCase: getAuthStateUseCase,
        updateProfileUseCase: updateProfileUseCase,
        notificationService: fakeNotificationService,
      );
    });

    tearDown(() {
      authController.dispose();
    });

    test('should initialize with null user and not loading', () {
      expect(authController.user, isNull);
      expect(authController.isLoading, isFalse);
      expect(authController.error, isNull);
      expect(authController.isAuthenticated, isFalse);
    });

    test('should handle sign in success', () async {
      // Act
      await authController.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(authController.user, isNotNull);
      expect(authController.user?.email, equals('test@example.com'));
      expect(authController.isAuthenticated, isTrue);
      expect(authController.error, isNull);
      expect(authController.isLoading, isFalse);
    });

    test('should handle sign in error', () async {
      // Arrange
      fakeAuthRepository.setError('Invalid credentials');

      // Act
      await authController.signIn(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      // Assert
      expect(authController.user, isNull);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.error, contains('Invalid credentials'));
      expect(authController.isLoading, isFalse);
    });

    test('should handle sign up success', () async {
      // Act
      await authController.signUp(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      );

      // Assert
      expect(authController.user, isNotNull);
      expect(authController.user?.email, equals('test@example.com'));
      expect(authController.user?.name, equals('Test User'));
      expect(authController.isAuthenticated, isTrue);
      expect(authController.error, isNull);
      expect(authController.isLoading, isFalse);
    });

    test('should handle sign up error', () async {
      // Arrange
      fakeAuthRepository.setError('Email already in use');

      // Act
      await authController.signUp(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
      );

      // Assert
      expect(authController.user, isNull);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.error, contains('Email already in use'));
      expect(authController.isLoading, isFalse);
    });

    test('should handle sign out', () async {
      // Arrange - first sign in
      await authController.signIn(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(authController.isAuthenticated, isTrue);

      // Act
      await authController.signOut();

      // Assert
      expect(authController.user, isNull);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.error, isNull);
      expect(authController.isLoading, isFalse);
    });

    test('should clear error when clearError is called', () async {
      // Arrange - create an error first
      fakeAuthRepository.setError('Test error');
      await authController.signIn(
        email: 'test@example.com',
        password: 'wrongpassword',
      );
      expect(authController.error, isNotNull);

      // Act
      authController.clearError();

      // Assert
      expect(authController.error, isNull);
    });

    test('should update profile successfully', () async {
      // Arrange - first sign in
      await authController.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Act
      await authController.updateProfile(
        name: 'Updated Name',
        profileImagePath: '/path/to/image.jpg',
      );

      // Assert
      expect(authController.user?.name, equals('Updated Name'));
      expect(authController.user?.profileImageUrl, equals('https://example.com/uploaded-image.jpg'));
      expect(authController.error, isNull);
      expect(authController.isLoading, isFalse);
    });

    test('should handle update profile error when not authenticated', () async {
      // Act - try to update profile without being authenticated
      await authController.updateProfile(
        name: 'Updated Name',
      );

      // Assert
      expect(authController.error, contains('User not authenticated'));
      expect(authController.isLoading, isFalse);
    });
  });
} 
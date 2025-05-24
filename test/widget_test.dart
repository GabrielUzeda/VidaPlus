// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vidaplus/domain/entities/user_entity.dart';
import 'package:vidaplus/domain/repositories/auth_repository.dart';
import 'package:vidaplus/domain/usecases/usecases.dart';
import 'package:vidaplus/core/services/notification_service.dart';
import 'package:vidaplus/presentation/controllers/auth_controller.dart';

import 'package:vidaplus/presentation/pages/auth/login_page.dart';
import 'package:vidaplus/presentation/pages/home/home_page.dart';

// Simple fake implementations for widget testing
class FakeAuthRepository implements AuthRepository {
  UserEntity? _currentUser;

  @override
  Future<UserEntity?> getCurrentUser() async => _currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(_currentUser);

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
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
}

class FakeHabitsRepository implements AuthRepository {
  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(null);

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<UserEntity> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String> uploadProfileImage(String filePath) async {
    throw UnimplementedError();
  }
}

class FakeNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

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
  Future<bool> getNotificationsEnabled() async => true;

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {}

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {}

  @override
  Future<void> debugNotifications() async {}

  @override
  Future<void> resetNotifications() async {}
}

// Helper function to create AuthController with Use Cases
AuthController createAuthController(
  FakeAuthRepository fakeAuthRepository,
  FakeNotificationService fakeNotificationService,
) {
  return AuthController(
    signInUseCase: SignInUseCase(fakeAuthRepository),
    signUpUseCase: SignUpUseCase(fakeAuthRepository),
    signOutUseCase: SignOutUseCase(fakeAuthRepository),
    getCurrentUserUseCase: GetCurrentUserUseCase(fakeAuthRepository),
    getAuthStateUseCase: GetAuthStateUseCase(fakeAuthRepository),
    updateProfileUseCase: UpdateProfileUseCase(fakeAuthRepository),
    notificationService: fakeNotificationService,
  );
}

void main() {
  testWidgets('VidaPlus login page test', (WidgetTester tester) async {
    // Create fake dependencies
    final fakeAuthRepository = FakeAuthRepository();
    final fakeNotificationService = FakeNotificationService();

    // Build the app with providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: fakeAuthRepository),
          Provider<NotificationService>.value(value: fakeNotificationService),
          ChangeNotifierProvider<AuthController>(
            create: (context) => createAuthController(
              fakeAuthRepository,
              fakeNotificationService,
            ),
          ),
        ],
        child: MaterialApp(
          home: Consumer<AuthController>(
            builder: (context, authController, _) {
              if (authController.isAuthenticated) {
                return const HomePage();
              }
              return const LoginPage();
            },
          ),
        ),
      ),
    );

    // Verify that the login page is displayed
    expect(find.text('Vida+'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);

    // Test form interaction
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Login button
  });

  testWidgets('VidaPlus navigation test', (WidgetTester tester) async {
    // Create fake dependencies
    final fakeAuthRepository = FakeAuthRepository();
    final fakeNotificationService = FakeNotificationService();

    // Build the app with providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: fakeAuthRepository),
          Provider<NotificationService>.value(value: fakeNotificationService),
          ChangeNotifierProvider<AuthController>(
            create: (context) => createAuthController(
              fakeAuthRepository,
              fakeNotificationService,
            ),
          ),
        ],
        child: MaterialApp(
          home: Consumer<AuthController>(
            builder: (context, authController, _) {
              if (authController.isAuthenticated) {
                return const HomePage();
              }
              return const LoginPage();
            },
          ),
        ),
      ),
    );

    // Should start at login page
    expect(find.text('Vida+'), findsOneWidget);
    expect(find.text('Entre na sua conta'), findsOneWidget);

    // Test toggle to signup
    await tester.tap(find.text('Não tem uma conta? Cadastre-se'));
    await tester.pumpAndSettle();

    expect(find.text('Crie sua conta'), findsOneWidget);
    expect(find.text('Nome completo'), findsOneWidget);
  });
}

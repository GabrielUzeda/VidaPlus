import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vida_plus/domain/entities/user.dart';
import 'package:vida_plus/domain/repositories/auth_repository.dart';
import 'package:vida_plus/domain/usecases/auth/sign_in.dart';
import 'package:vida_plus/domain/usecases/auth/sign_up.dart';
import 'package:vida_plus/domain/usecases/user/get_current_user.dart';
import 'package:vida_plus/presentation/controllers/auth_controller.dart';

import 'auth_controller_test.mocks.dart';

@GenerateMocks([AuthRepository, SignIn, SignUp, GetCurrentUser])
void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSignIn mockSignIn;
  late MockSignUp mockSignUp;
  late MockGetCurrentUser mockGetCurrentUser;
  late AuthController authController;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSignIn = MockSignIn();
    mockSignUp = MockSignUp();
    mockGetCurrentUser = MockGetCurrentUser();
    authController = AuthController(
      signIn: mockSignIn,
      signUp: mockSignUp,
      getCurrentUser: mockGetCurrentUser,
      authRepository: mockAuthRepository,
    );
  });

  group('AuthController', () {
    final testUser = User(
      id: 'user_id_1',
      email: 'test@example.com',
      name: 'Test User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('initial state should be AuthStatus.initial', () {
      // Assert
      expect(authController.status, AuthStatus.initial);
      expect(authController.currentUser, null);
      expect(authController.errorMessage, null);
      expect(authController.isAuthenticated, false);
    });

    test('checkAuthStatus should update state to authenticated when user is signed in', () async {
      // Arrange
      when(mockAuthRepository.isSignedIn()).thenAnswer((_) async => true);
      when(mockGetCurrentUser()).thenAnswer((_) async => testUser);

      // Act
      await authController.checkAuthStatus();

      // Assert
      expect(authController.status, AuthStatus.authenticated);
      expect(authController.currentUser, testUser);
      expect(authController.isAuthenticated, true);
      verify(mockAuthRepository.isSignedIn()).called(1);
      verify(mockGetCurrentUser()).called(1);
    });

    test('checkAuthStatus should update state to unauthenticated when user is not signed in', () async {
      // Arrange
      when(mockAuthRepository.isSignedIn()).thenAnswer((_) async => false);

      // Act
      await authController.checkAuthStatus();

      // Assert
      expect(authController.status, AuthStatus.unauthenticated);
      expect(authController.currentUser, null);
      expect(authController.isAuthenticated, false);
      verify(mockAuthRepository.isSignedIn()).called(1);
      verifyNever(mockGetCurrentUser());
    });

    test('signIn should update state to authenticated on success', () async {
      // Arrange
      when(mockSignIn(email: 'test@example.com', password: 'password123'))
          .thenAnswer((_) async => 'user_id_1');
      when(mockGetCurrentUser()).thenAnswer((_) async => testUser);

      // Act
      await authController.signIn(email: 'test@example.com', password: 'password123');

      // Assert
      expect(authController.status, AuthStatus.authenticated);
      expect(authController.currentUser, testUser);
      expect(authController.isAuthenticated, true);
      verify(mockSignIn(email: 'test@example.com', password: 'password123')).called(1);
      verify(mockGetCurrentUser()).called(1);
    });

    test('signIn should update state to error when exception occurs', () async {
      // Arrange
      when(mockSignIn(email: 'test@example.com', password: 'password123'))
          .thenThrow(Exception('Invalid credentials'));

      // Act
      await authController.signIn(email: 'test@example.com', password: 'password123');

      // Assert
      expect(authController.status, AuthStatus.error);
      expect(authController.errorMessage, 'Exception: Invalid credentials');
      expect(authController.isAuthenticated, false);
      verify(mockSignIn(email: 'test@example.com', password: 'password123')).called(1);
      verifyNever(mockGetCurrentUser());
    });

    test('signOut should update state to unauthenticated on success', () async {
      // Arrange
      when(mockAuthRepository.signOut()).thenAnswer((_) async => {});

      // Act
      await authController.signOut();

      // Assert
      expect(authController.status, AuthStatus.unauthenticated);
      expect(authController.currentUser, null);
      expect(authController.isAuthenticated, false);
      verify(mockAuthRepository.signOut()).called(1);
    });
  });
} 
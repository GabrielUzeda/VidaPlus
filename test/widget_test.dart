// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:vida_plus/domain/repositories/auth_repository.dart';
import 'package:vida_plus/domain/usecases/auth/sign_in.dart';
import 'package:vida_plus/domain/usecases/auth/sign_up.dart';
import 'package:vida_plus/domain/usecases/user/get_current_user.dart';
import 'package:vida_plus/presentation/controllers/auth_controller.dart';
import 'package:vida_plus/presentation/pages/login_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<bool> isSignedIn() => super.noSuchMethod(
        Invocation.method(#isSignedIn, []),
        returnValue: Future.value(false),
      ) as Future<bool>;
}

class MockSignIn extends Mock implements SignIn {}
class MockSignUp extends Mock implements SignUp {}
class MockGetCurrentUser extends Mock implements GetCurrentUser {}

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

  testWidgets('App should display login page', (WidgetTester tester) async {
    // Mock the initial auth state
    when(mockAuthRepository.isSignedIn()).thenAnswer((_) async => false);
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthController>(
          create: (_) => authController,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: LoginPage(),
              );
            },
          ),
        ),
      ),
    );

    // Verify that the login page is displayed
    expect(find.byType(LoginPage), findsOneWidget);
    
    // Check for email and password fields
    expect(find.byType(TextFormField), findsNWidgets(2));
    
    // Check for login button
    expect(find.byType(ElevatedButton), findsAtLeast(1));
    expect(find.text('Entrar'), findsOneWidget);
    
    // Check for signup text button (it might be a TextButton instead of ElevatedButton)
    expect(find.byType(TextButton), findsAtLeast(1));
  });
}

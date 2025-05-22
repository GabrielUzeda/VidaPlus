// Controller de autenticação com ChangeNotifier
import 'package:flutter/foundation.dart';
import 'package:vida_plus/domain/entities/user.dart';
import 'package:vida_plus/domain/repositories/auth_repository.dart';
import 'package:vida_plus/domain/usecases/auth/sign_in.dart';
import 'package:vida_plus/domain/usecases/auth/sign_up.dart';
import 'package:vida_plus/domain/usecases/user/get_current_user.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthController extends ChangeNotifier {
  final SignIn _signIn;
  final SignUp _signUp;
  final GetCurrentUser _getCurrentUser;
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String? _errorMessage;

  AuthController({
    required SignIn signIn,
    required SignUp signUp,
    required GetCurrentUser getCurrentUser,
    required AuthRepository authRepository,
  })  : _signIn = signIn,
        _signUp = signUp,
        _getCurrentUser = getCurrentUser,
        _authRepository = authRepository;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthStatus() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final isSignedIn = await _authRepository.isSignedIn();
      if (isSignedIn) {
        final user = await _getCurrentUser();
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _signIn(email: email, password: password);
      _currentUser = await _getCurrentUser();
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _signUp(
        email: email,
        password: password,
        name: name,
      );
      _currentUser = await _getCurrentUser();
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      await _authRepository.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.resetPassword(email);
      _status = _status == AuthStatus.authenticated
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

} 
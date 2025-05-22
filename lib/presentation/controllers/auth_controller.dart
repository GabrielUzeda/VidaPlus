import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/usecases.dart';
import '../../core/services/notification_service.dart';

// Controlador de estado para autenticação usando Use Cases (Clean Architecture)
class AuthController extends ChangeNotifier {
  // Use Cases de autenticação
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetAuthStateUseCase _getAuthStateUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  
  final NotificationService _notificationService;

  AuthController({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required GetAuthStateUseCase getAuthStateUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required NotificationService notificationService,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getAuthStateUseCase = getAuthStateUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _notificationService = notificationService {
    _init();
  }

  UserEntity? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Inicializa o controlador
  void _init() {
    // Escuta mudanças no estado de autenticação
    _getAuthStateUseCase.call().listen((user) {
      _user = user;
      notifyListeners();
      
      // Se usuário logou, inicializa notificações
      if (user != null) {
        _notificationService.initialize();
        _notificationService.scheduleDailyCheckInReminder();
      }
    });
    
    // Carrega usuário atual
    _loadCurrentUser();
  }

  // Carrega o usuário atualmente autenticado
  Future<void> _loadCurrentUser() async {
    try {
      _user = await _getCurrentUserUseCase.call();
      notifyListeners();
    } catch (e) {
      // Silently handle error - user will remain null
    }
  }

  // Realiza login usando Use Case
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final params = SignInParams(
        email: email,
        password: password,
      );

      final user = await _signInUseCase.call(params);
      _user = user;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Realiza cadastro usando Use Case
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final params = SignUpParams(
        email: email,
        password: password,
        name: name,
      );

      final user = await _signUpUseCase.call(params);
      _user = user;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Realiza logout usando Use Case
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _signOutUseCase.call();
      _user = null;
      
      // Cancela todas as notificações ao fazer logout
      await _notificationService.cancelAllNotifications();
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Atualiza perfil do usuário usando Use Case
  Future<void> updateProfile({
    String? name,
    String? profileImagePath,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final params = UpdateProfileParams(
        name: name,
        profileImagePath: profileImagePath,
      );

      final updatedUser = await _updateProfileUseCase.call(params);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Define estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Define erro
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Limpa erro
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Limpa erro manualmente (para UI)
  void clearError() {
    _clearError();
  }
} 
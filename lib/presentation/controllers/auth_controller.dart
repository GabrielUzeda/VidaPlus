import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/services/notification_service.dart';

// Controlador de estado para autenticação (SOLID - Single Responsibility)
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;

  AuthController({
    required AuthRepository authRepository,
    required NotificationService notificationService,
  })  : _authRepository = authRepository,
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
    _authRepository.authStateChanges.listen((user) {
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
      _user = await _authRepository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // Silently handle error - user will remain null
    }
  }

  // Realiza login
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = user;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Realiza cadastro
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      _user = user;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Realiza logout
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authRepository.signOut();
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

  // Atualiza perfil do usuário
  Future<void> updateProfile({
    String? name,
    String? profileImagePath,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      String? profileImageUrl;
      
      // Faz upload da imagem se fornecida
      if (profileImagePath != null) {
        profileImageUrl = await _authRepository.uploadProfileImage(profileImagePath);
      }

      final updatedUser = await _authRepository.updateProfile(
        name: name,
        profileImageUrl: profileImageUrl,
      );

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
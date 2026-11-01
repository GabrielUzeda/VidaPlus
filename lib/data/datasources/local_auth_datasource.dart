import 'dart:async';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/local_user_model.dart';

class LocalAuthDatasource {
  static const String _userBoxName = 'users';
  static const String _currentUserKey = 'current_user_id';
  static const String _isGuestKey = 'is_guest';
  static const String _imagesFolder = 'profile_images';
  
  late Box<LocalUserModel> _userBox;
  late SharedPreferences _prefs;
  final _authController = StreamController<LocalUserModel?>.broadcast();
  final _uuid = const Uuid();
  
  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  LocalAuthDatasource();

  // Inicializa o datasource
  Future<void> initialize() async {
    _userBox = await Hive.openBox<LocalUserModel>(_userBoxName);
    _prefs = await SharedPreferences.getInstance();
  }

  // Stream do estado de autenticação
  Stream<LocalUserModel?> get authStateChanges => _authController.stream;

  // Obtém o usuário atualmente autenticado
  Future<LocalUserModel?> getCurrentUser() async {
    try {
      final currentUserId = _prefs.getString(_currentUserKey);
      if (currentUserId == null) return null;

      final user = _userBox.get(currentUserId);
      if (user != null) {
        _authController.add(user);
      }
      return user;
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      return null;
    }
  }

  // Realiza login com email e senha (simulado localmente)
  Future<LocalUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Busca usuário por email
      final existingUser = _userBox.values.firstWhere(
        (user) => user.email == email && !user.isGuest,
        orElse: () => throw Exception('Email não encontrado'),
      );

      // Em um sistema real, verificaria a senha com hash
      // Para este exemplo, aceita qualquer senha não-vazia
      if (password.isEmpty) {
        throw Exception('Senha não pode estar vazia');
      }

      // Define como usuário atual
      await _prefs.setString(_currentUserKey, existingUser.id);
      await _prefs.setBool(_isGuestKey, false);
      
      _authController.add(existingUser);
      
      debugPrint('✅ Login successful for: ${existingUser.email}');
      return existingUser;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      throw _handleAuthException(e.toString());
    }
  }

  // Registra novo usuário
  Future<LocalUserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Verifica se email já existe
      final existsUser = _userBox.values.any(
        (user) => user.email == email && !user.isGuest,
      );
      
      if (existsUser) {
        throw Exception('Este email já possui uma conta');
      }

      // Validações
      if (password.length < 6) {
        throw Exception('Senha deve ter pelo menos 6 caracteres');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Email inválido');
      }

      // Cria novo usuário
      final now = DateTime.now();
      final userId = _uuid.v4();
      
      final newUser = LocalUserModel(
        id: userId,
        email: email,
        name: name,
        createdAt: now,
        updatedAt: now,
        isGuest: false,
      );

      // Salva no Hive
      await _userBox.put(userId, newUser);
      
      // Define como usuário atual
      await _prefs.setString(_currentUserKey, userId);
      await _prefs.setBool(_isGuestKey, false);
      
      _authController.add(newUser);
      
      debugPrint('✅ Sign up successful for: $email');
      return newUser;
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      throw _handleAuthException(e.toString());
    }
  }

  // Realiza login como convidado/visitante
  Future<LocalUserModel> signInAsGuest() async {
    try {
      const guestUserId = 'guest_user';
      
      // Verifica se já existe usuário convidado
      final existingUser = _userBox.get(guestUserId);
      if (existingUser != null) {
        _authController.add(existingUser);
        debugPrint('👤 Guest user already exists, signing in');
        return existingUser;
      }

      // Cria novo usuário convidado
      final now = DateTime.now();
      final guestUser = LocalUserModel(
        id: guestUserId,
        email: 'guest@vidaplus.local',
        name: 'Convidado(a)',
        profileImageUrl: 'guest_avatar', // Use identifier instead of file path
        createdAt: now,
        updatedAt: now,
        isGuest: true,
      );

      await _userBox.put(guestUserId, guestUser);
      _authController.add(guestUser);

      debugPrint('✅ Guest user created and signed in');
      debugPrint('👤 User ID: ${guestUser.id}');
      debugPrint('👤 Name: ${guestUser.name}');
      debugPrint('👤 Email: ${guestUser.email}');

      return guestUser;
    } catch (e) {
      debugPrint('❌ Error signing in as guest: $e');
      throw Exception('Erro ao entrar como convidado: $e');
    }
  }

  // Realiza login com Google
  Future<LocalUserModel> signInWithGoogle() async {
    try {
      debugPrint('🔐 Starting Google Sign In...');
      
      // Faz logout do Google primeiro para forçar seleção de conta
      await _googleSignIn.signOut();
      
      // Inicia o processo de login
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Login cancelado pelo usuário');
      }
      
      debugPrint('✅ Google account selected: ${googleUser.email}');
      
      // Obtém os dados básicos
      final email = googleUser.email;
      final name = googleUser.displayName ?? 'Usuário Google';
      final photoUrl = googleUser.photoUrl;
      
      debugPrint('👤 User info - Name: $name, Email: $email');
      debugPrint('📸 Photo URL: $photoUrl');
      
      // Verifica se usuário já existe
      LocalUserModel? existingUser;
      try {
        existingUser = _userBox.values.firstWhere(
          (user) => user.email == email && !user.isGuest,
        );
        debugPrint('👤 Existing user found');
      } catch (e) {
        debugPrint('👤 New Google user');
      }
      
      String? localImagePath;
      
      // Baixa a foto de perfil se disponível
      if (photoUrl != null) {
        try {
          localImagePath = await _downloadProfileImage(photoUrl, email);
          debugPrint('📸 Profile image downloaded: $localImagePath');
        } catch (e) {
          debugPrint('❌ Error downloading profile image: $e');
          // Continua sem foto se não conseguir baixar
        }
      }
      
      final now = DateTime.now();
      LocalUserModel user;
      
      if (existingUser != null) {
        // Atualiza usuário existente com novos dados
        user = existingUser.copyWith(
          name: name,
          profileImageUrl: localImagePath ?? existingUser.profileImageUrl,
          updatedAt: now,
        );
        debugPrint('🔄 Updating existing user');
      } else {
        // Cria novo usuário
        final userId = _uuid.v4();
        user = LocalUserModel(
          id: userId,
          email: email,
          name: name,
          profileImageUrl: localImagePath,
          createdAt: now,
          updatedAt: now,
          isGuest: false,
        );
        debugPrint('✨ Creating new user');
      }
      
      // Salva no Hive
      await _userBox.put(user.id, user);
      
      // Define como usuário atual
      await _prefs.setString(_currentUserKey, user.id);
      await _prefs.setBool(_isGuestKey, false);
      
      _authController.add(user);
      
      debugPrint('✅ Google sign in successful for: $email');
      return user;
      
    } catch (e) {
      debugPrint('❌ Google sign in error: $e');
      // Faz logout do Google em caso de erro
      await _googleSignIn.signOut();
      throw _handleGoogleAuthException(e.toString());
    }
  }

  // Baixa e salva a foto de perfil do Google
  Future<String?> _downloadProfileImage(String photoUrl, String email) async {
    try {
      debugPrint('📥 Downloading profile image from: $photoUrl');
      
      // Cria diretório de imagens se não existir
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/$_imagesFolder');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      // Faz download da imagem
      final response = await http.get(Uri.parse(photoUrl));
      
      if (response.statusCode == 200) {
        // Cria nome único para a imagem
        final fileName = 'google_profile_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '${imagesDir.path}/$fileName';
        
        // Salva a imagem
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        debugPrint('✅ Profile image saved to: $filePath');
        return filePath;
      } else {
        debugPrint('❌ Failed to download image, status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error downloading profile image: $e');
      return null;
    }
  }

  // Realiza logout
  Future<void> signOut() async {
    try {
      // Faz logout do Google se estava logado
      await _googleSignIn.signOut();
      
      await _prefs.remove(_currentUserKey);
      await _prefs.remove(_isGuestKey);
      _authController.add(null);
      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  // Atualiza perfil do usuário
  Future<LocalUserModel> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    try {
      final currentUserId = _prefs.getString(_currentUserKey);
      if (currentUserId == null) {
        throw Exception('Usuário não autenticado');
      }

      final currentUser = _userBox.get(currentUserId);
      if (currentUser == null) {
        throw Exception('Usuário não encontrado');
      }

      final updatedUser = currentUser.copyWith(
        name: name,
        profileImageUrl: profileImageUrl,
        updatedAt: DateTime.now(),
      );

      await _userBox.put(currentUserId, updatedUser);
      _authController.add(updatedUser);
      
      debugPrint('✅ Profile updated successfully');
      return updatedUser;
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  // Faz upload da imagem de perfil (salva localmente)
  Future<String> uploadProfileImage(String filePath) async {
    try {
      final currentUserId = _prefs.getString(_currentUserKey);
      if (currentUserId == null) {
        throw Exception('Usuário não autenticado');
      }

      debugPrint('📤 Starting local profile image upload...');
      debugPrint('📤 User ID: $currentUserId');
      debugPrint('📤 File path: $filePath');

      final file = File(filePath);
      
      // Verifica se o arquivo existe
      if (!await file.exists()) {
        throw Exception('Arquivo não encontrado: $filePath');
      }
      
      // Cria diretório de imagens se não existir
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/$_imagesFolder');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      // Cria nome único para a imagem
      final extension = filePath.split('.').last;
      final fileName = 'profile_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final newPath = '${imagesDir.path}/$fileName';
      
      // Copia o arquivo
      await file.copy(newPath);
      
      debugPrint('✅ Local upload successful! Path: $newPath');
      
      return newPath;
    } catch (e) {
      debugPrint('❌ Local upload error: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  // Limpa todos os dados (para testes)
  Future<void> clearAllData() async {
    try {
      await _userBox.clear();
      await _prefs.clear();
      _authController.add(null);
      debugPrint('✅ All data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }

  // Verifica se está em modo guest
  Future<bool> isGuest() async {
    return _prefs.getBool(_isGuestKey) ?? false;
  }

  // Fecha o datasource
  Future<void> dispose() async {
    await _authController.close();
  }

  // Tratamento de erros de autenticação com mensagens amigáveis
  String _handleAuthException(String error) {
    if (error.contains('Email não encontrado')) {
      return 'Este email não está cadastrado. Verifique o email ou crie uma conta.';
    } else if (error.contains('Senha não pode estar vazia')) {
      return 'Senha não pode estar vazia.';
    } else if (error.contains('Este email já possui uma conta')) {
      return 'Este email já possui uma conta. Faça login ou use outro email.';
    } else if (error.contains('Senha deve ter pelo menos 6 caracteres')) {
      return 'Senha deve ter pelo menos 6 caracteres.';
    } else if (error.contains('Email inválido')) {
      return 'Email inválido. Verifique o formato do email.';
    } else {
      return 'Erro inesperado. Tente novamente ou entre em contato com o suporte.';
    }
  }

  // Tratamento de erros específicos do Google Sign In
  Exception _handleGoogleAuthException(String error) {
    if (error.contains('Login cancelado pelo usuário')) {
      return Exception('Login cancelado. Tente novamente se desejar entrar.');
    } else if (error.contains('network')) {
      return Exception('Erro de conexão. Verifique sua internet e tente novamente.');
    } else if (error.contains('sign_in_failed')) {
      return Exception('Falha no login com Google. Tente novamente.');
    } else if (error.contains('account_exists_with_different_credential')) {
      return Exception('Já existe uma conta com este email. Use outro método de login.');
    } else {
      return Exception('Erro ao entrar com Google. Tente novamente ou use outro método.');
    }
  }
} 
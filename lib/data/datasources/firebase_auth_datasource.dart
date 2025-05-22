import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/user_model.dart';

// Datasource para operações de autenticação com Firebase
class FirebaseAuthDatasource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseAuthDatasource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Obtém o usuário atualmente autenticado
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    // Busca dados adicionais do usuário no Firestore
    final userDoc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!userDoc.exists) return null;

    return UserModel.fromMap(userDoc.data()!, firebaseUser.uid);
  }

  // Stream do estado de autenticação
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) return null;

        return UserModel.fromMap(userDoc.data()!, firebaseUser.uid);
          } catch (e) {
      // Return null on error
      return null;
    }
    });
  }

  // Realiza login com email e senha
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Falha na autenticação');
      }

      // Busca dados do usuário no Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Dados do usuário não encontrados');
      }

      return UserModel.fromMap(userDoc.data()!, user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registra novo usuário
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Falha ao criar usuário');
      }

      // Cria documento do usuário no Firestore
      final now = DateTime.now();
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Realiza logout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Atualiza perfil do usuário
  Future<UserModel> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    if (name != null) {
      updates['name'] = name;
    }
    if (profileImageUrl != null) {
      updates['profileImageUrl'] = profileImageUrl;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update(updates);

    // Retorna o usuário atualizado
    final updatedUser = await getCurrentUser();
    if (updatedUser == null) {
      throw Exception('Erro ao obter usuário atualizado');
    }

    return updatedUser;
  }

  // Faz upload da imagem de perfil
  Future<String> uploadProfileImage(String filePath) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final file = File(filePath);
    final fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    final ref = _storage.ref().child('profile_images').child(fileName);
    
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    
    return await snapshot.ref.getDownloadURL();
  }

  // Tratamento de erros de autenticação com mensagens amigáveis
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Este email não está cadastrado. Verifique o email ou crie uma conta.';
      case 'wrong-password':
        return 'Senha incorreta. Verifique sua senha e tente novamente.';
      case 'invalid-credential':
        return 'Email ou senha incorretos. Verifique seus dados e tente novamente.';
      case 'email-already-in-use':
        return 'Este email já possui uma conta. Faça login ou use outro email.';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres.';
      case 'invalid-email':
        return 'Email inválido. Verifique o formato do email.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada. Entre em contato com o suporte.';
      case 'too-many-requests':
        return 'Muitas tentativas de login. Aguarde alguns minutos e tente novamente.';
      case 'operation-not-allowed':
        return 'Operação não permitida. Entre em contato com o suporte.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet e tente novamente.';
      default:
        return 'Erro inesperado. Tente novamente ou entre em contato com o suporte.';
    }
  }
} 
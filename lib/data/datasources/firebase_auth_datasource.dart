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
        print('Erro ao obter dados do usuário: $e');
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

  // Trata exceções de autenticação do Firebase
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Este email já está em uso';
      case 'weak-password':
        return 'A senha é muito fraca';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuário desabilitado';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'operation-not-allowed':
        return 'Operação não permitida';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
} 
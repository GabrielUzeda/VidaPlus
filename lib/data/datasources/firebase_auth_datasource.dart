// Fonte de dados para autenticação com Firebase
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

abstract class FirebaseAuthDatasource {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<bool> isSignedIn();
  Future<String?> getCurrentUserId();
}

class FirebaseAuthDatasourceImpl implements FirebaseAuthDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthDatasourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  @override
  Future<String> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Usuário não encontrado');
        case 'wrong-password':
          throw Exception('Senha incorreta');
        case 'user-disabled':
          throw Exception('Conta desativada');
        default:
          throw Exception('Erro de autenticação: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro ao fazer login: ${e.toString()}');
    }
  }

  @override
  Future<String> signUp(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Este email já está em uso');
        case 'weak-password':
          throw Exception('Senha fraca');
        default:
          throw Exception('Erro ao criar conta: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro ao criar conta: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Erro ao sair: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Usuário não encontrado');
        default:
          throw Exception('Erro ao redefinir senha: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro ao redefinir senha: ${e.toString()}');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _firebaseAuth.currentUser?.uid;
  }
} 
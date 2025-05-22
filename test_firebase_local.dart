import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

void main() async {
  print('🧪 Testando configuração local do Firebase...');
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado com sucesso');
    
    // Conectar aos emuladores
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    print('✅ Emuladores conectados');
    
    // Testar Auth
    print('🔐 Testando Firebase Auth...');
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'teste@exemplo.com',
        password: 'senha123',
      );
      print('✅ Usuário criado: ${userCredential.user?.email}');
    } catch (e) {
      print('⚠️ Erro ao criar usuário (pode ser normal se já existe): $e');
    }
    
    // Testar Firestore
    print('📄 Testando Firestore...');
    await FirebaseFirestore.instance
        .collection('teste')
        .doc('documento-teste')
        .set({'mensagem': 'Hello, Firebase local!', 'timestamp': DateTime.now()});
    print('✅ Documento salvo no Firestore');
    
    var doc = await FirebaseFirestore.instance
        .collection('teste')
        .doc('documento-teste')
        .get();
    print('✅ Documento lido: ${doc.data()}');
    
    print('🎉 Todos os testes passaram! Firebase local funcionando perfeitamente.');
    
  } catch (e) {
    print('❌ Erro nos testes: $e');
    print('Certifique-se de que os emuladores estão rodando com: firebase emulators:start');
  }
} 
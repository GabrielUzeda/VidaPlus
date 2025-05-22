import 'package:flutter/material.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Inicializando Firebase com emuladores locais...');
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Sempre usar emuladores locais para desenvolvimento
  await _connectToFirebaseEmulator();
  
  runApp(const VidaPlusApp());
}

Future<void> _connectToFirebaseEmulator() async {
  try {
    print('Conectando aos emuladores Firebase...');
    
    // Conectar ao emulador do Firebase Auth (porta 9099)
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    print('✅ Conectado ao emulador do Firebase Auth na porta 9099');
    
    // Conectar ao emulador do Firestore (porta 8080)
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    print('✅ Conectado ao emulador do Firestore na porta 8080');
    
    print('🎉 Todos os emuladores Firebase conectados com sucesso!');
  } catch (e) {
    print('❌ Erro ao conectar aos emuladores Firebase: $e');
    print('Certifique-se de que os emuladores estão rodando com: firebase emulators:start');
  }
}

class VidaPlusApp extends StatelessWidget {
  const VidaPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vida+',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core
import 'core/services/notification_service.dart';

// Data Layer
import 'data/datasources/firebase_auth_datasource.dart';
import 'data/datasources/firestore_habits_datasource.dart';
import 'data/repositories_impl/auth_repository_impl.dart';
import 'data/repositories_impl/habits_repository_impl.dart';

// Presentation Layer
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/habits_controller.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home/home_page.dart';

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
    // Configura os providers (Dependency Injection)
    return MultiProvider(
      providers: [
        // Services
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
        
        // Datasources
        Provider<FirebaseAuthDatasource>(
          create: (_) => FirebaseAuthDatasource(),
        ),
        Provider<FirestoreHabitsDatasource>(
          create: (_) => FirestoreHabitsDatasource(),
        ),
        
        // Repositories
        Provider<AuthRepositoryImpl>(
          create: (context) => AuthRepositoryImpl(
            datasource: context.read<FirebaseAuthDatasource>(),
          ),
        ),
        Provider<HabitsRepositoryImpl>(
          create: (context) => HabitsRepositoryImpl(
            datasource: context.read<FirestoreHabitsDatasource>(),
          ),
        ),
        
        // Controllers
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            authRepository: context.read<AuthRepositoryImpl>(),
            notificationService: context.read<NotificationService>(),
          ),
        ),
        ChangeNotifierProvider<HabitsController>(
          create: (context) => HabitsController(
            habitsRepository: context.read<HabitsRepositoryImpl>(),
            notificationService: context.read<NotificationService>(),
          ),
        ),
      ],
      child: Consumer<AuthController>(
        builder: (context, authController, _) {
          return MaterialApp(
            title: 'Vida+',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: ThemeMode.system,
            home: _buildHomePage(authController),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  // Constrói a página inicial baseada no estado de autenticação
  Widget _buildHomePage(AuthController authController) {
    if (authController.isLoading) {
      return const SplashPage();
    }
    
    if (authController.isAuthenticated) {
      return const HomePage();
    }
    
    return const LoginPage();
  }

  // Tema claro
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Tema escuro
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vida_plus/core/config/firebase_config.dart';
import 'package:vida_plus/core/services/dependency_injection.dart' as di;
import 'package:vida_plus/presentation/controllers/auth_controller.dart';
import 'package:vida_plus/presentation/controllers/habit_controller.dart';
import 'package:vida_plus/presentation/pages/login_page.dart';
import 'package:vida_plus/presentation/pages/home_page.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: FirebaseConfig.apiKey,
        appId: FirebaseConfig.appId,
        messagingSenderId: FirebaseConfig.messagingSenderId,
        projectId: FirebaseConfig.projectId,
        storageBucket: FirebaseConfig.storageBucket,
        authDomain: FirebaseConfig.authDomain,
      ),
    );
  }
  
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.serviceLocator<AuthController>()..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.serviceLocator<HabitController>(),
        ),
      ],
      child: MaterialApp(
        title: 'Vida+',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    switch (authController.status) {
      case AuthStatus.authenticated:
        return const HomePage();
      case AuthStatus.unauthenticated:
        return const LoginPage();
      case AuthStatus.loading:
      case AuthStatus.initial:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.error:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ocorreu um erro'),
                Text(authController.errorMessage ?? 'Erro desconhecido'),
                ElevatedButton(
                  onPressed: () => authController.checkAuthStatus(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        );
    }
  }
}

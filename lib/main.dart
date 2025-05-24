import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

// Core
import 'core/services/notification_service.dart';

// Data Layer
import 'data/datasources/firebase_auth_datasource.dart';
import 'data/datasources/firestore_habits_datasource.dart';
import 'data/repositories_impl/auth_repository_impl.dart';
import 'data/repositories_impl/habits_repository_impl.dart';

// Domain Layer - Use Cases
import 'domain/usecases/usecases.dart';

// Presentation Layer
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/habits_controller.dart';
import 'presentation/controllers/theme_controller.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home/home_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa dados de localização para formatação de datas em português
  await initializeDateFormatting('pt_BR', null);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Conectar aos emuladores em desenvolvimento
  await _connectToFirebaseEmulator();
  
  runApp(const VidaPlusApp());
}

Future<void> _connectToFirebaseEmulator() async {
  try {
    // Para emuladores Android, usar 10.0.2.2 (IP do host no emulador)
    // Para outras plataformas, usar localhost
    String host = 'localhost';
    
    // Detectar se está rodando no emulador Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      host = '10.0.2.2';
    }
    
    // Conectar ao emulador do Firebase Auth (porta 9099)
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    
    // Conectar ao emulador do Firestore (porta 8080)
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    
    // Conectar ao emulador do Storage (porta 9199)
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
    
    debugPrint('✅ Conectado aos emuladores Firebase:');
    debugPrint('   🔐 Auth: $host:9099');
    debugPrint('   📄 Firestore: $host:8080');
    debugPrint('   📦 Storage: $host:9199');
  } catch (e) {
    // Em produção, falha silenciosa - conectará ao Firebase real
    // Em desenvolvimento, pode indicar que emuladores não estão rodando
    debugPrint('Erro ao conectar aos emuladores Firebase: $e');
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
        
        // Controllers
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController()..initialize(),
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
        
        // Auth Use Cases
        Provider<SignInUseCase>(
          create: (context) => SignInUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider<SignUpUseCase>(
          create: (context) => SignUpUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider<SignOutUseCase>(
          create: (context) => SignOutUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider<GetCurrentUserUseCase>(
          create: (context) => GetCurrentUserUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider<GetAuthStateUseCase>(
          create: (context) => GetAuthStateUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider<UpdateProfileUseCase>(
          create: (context) => UpdateProfileUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        
        // Habits Use Cases
        Provider<CreateHabitUseCase>(
          create: (context) => CreateHabitUseCase(
            context.read<HabitsRepositoryImpl>(),
          ),
        ),
        Provider<GetUserHabitsUseCase>(
          create: (context) => GetUserHabitsUseCase(
            context.read<HabitsRepositoryImpl>(),
          ),
        ),
        Provider<GetUserHabitsStreamUseCase>(
          create: (context) => GetUserHabitsStreamUseCase(
            context.read<HabitsRepositoryImpl>(),
          ),
        ),
        Provider<UpdateHabitUseCase>(
          create: (context) => UpdateHabitUseCase(
            context.read<HabitsRepositoryImpl>(),
          ),
        ),
        Provider<DeleteHabitUseCase>(
          create: (context) => DeleteHabitUseCase(
            context.read<HabitsRepositoryImpl>(),
          ),
        ),
        Provider<CheckInHabitUseCase>(
          create: (context) => CheckInHabitUseCase(
            context.read<HabitsRepositoryImpl>(),
          ),
        ),
        Provider<GetTodayCheckInsUseCase>(
          create: (context) => GetTodayCheckInsUseCase(
            context.read<HabitsRepositoryImpl>(),
          ),
        ),
        Provider<GetHabitsProgressUseCase>(
          create: (context) => GetHabitsProgressUseCase(
            context.read<HabitsRepositoryImpl>(),
          ),
        ),
        Provider<GetHabitHistoryUseCase>(
          create: (context) => GetHabitHistoryUseCase(
            context.read<HabitsRepositoryImpl>(),
          ),
        ),
        
        // Controllers
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            signInUseCase: context.read<SignInUseCase>(),
            signUpUseCase: context.read<SignUpUseCase>(),
            signOutUseCase: context.read<SignOutUseCase>(),
            getCurrentUserUseCase: context.read<GetCurrentUserUseCase>(),
            getAuthStateUseCase: context.read<GetAuthStateUseCase>(),
            updateProfileUseCase: context.read<UpdateProfileUseCase>(),
            notificationService: context.read<NotificationService>(),
          ),
        ),
        ChangeNotifierProvider<HabitsController>(
          create: (context) => HabitsController(
            createHabitUseCase: context.read<CreateHabitUseCase>(),
            getUserHabitsUseCase: context.read<GetUserHabitsUseCase>(),
            getUserHabitsStreamUseCase: context.read<GetUserHabitsStreamUseCase>(),
            updateHabitUseCase: context.read<UpdateHabitUseCase>(),
            deleteHabitUseCase: context.read<DeleteHabitUseCase>(),
            checkInHabitUseCase: context.read<CheckInHabitUseCase>(),
            getTodayCheckInsUseCase: context.read<GetTodayCheckInsUseCase>(),
            getHabitsProgressUseCase: context.read<GetHabitsProgressUseCase>(),
            getHabitHistoryUseCase: context.read<GetHabitHistoryUseCase>(),
            notificationService: context.read<NotificationService>(),
          ),
        ),
      ],
      child: Consumer2<AuthController, ThemeController>(
        builder: (context, authController, themeController, _) {
          return MaterialApp(
            title: 'Vida+',
            theme: _buildLightTheme(themeController.primaryColor.color),
            darkTheme: _buildDarkTheme(themeController.primaryColor.color),
            themeMode: themeController.materialThemeMode,
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
  ThemeData _buildLightTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor, // Usa cor dinâmica
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
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  // Tema escuro
  ThemeData _buildDarkTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor, // Usa cor dinâmica
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
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

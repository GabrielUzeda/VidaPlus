import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/services/notification_service.dart';

import 'data/datasources/local_auth_datasource.dart';
import 'data/datasources/local_habits_datasource.dart';
import 'data/repositories_impl/local_auth_repository_impl.dart';
import 'data/repositories_impl/local_habits_repository_impl.dart';

import 'data/models/local_user_model.dart';
import 'data/models/local_habit_model.dart';
import 'data/models/local_checkin_model.dart';

import 'domain/usecases/usecases.dart';

import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/habits_controller.dart';
import 'presentation/controllers/theme_controller.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa dados de localização para formatação de datas em português
  await initializeDateFormatting('pt_BR', null);
  
  // Inicializa Hive para armazenamento local
  await _initializeHive();
  
  runApp(const VidaPlusApp());
}

late LocalAuthDatasource _authDatasource;
late LocalHabitsDatasource _habitsDatasource;

Future<void> _initializeHive() async {
  try {
    // Inicializa Hive Flutter
    await Hive.initFlutter();
    
    // Registra adapters dos modelos
    Hive.registerAdapter(LocalUserModelAdapter());
    Hive.registerAdapter(LocalHabitModelAdapter());
    Hive.registerAdapter(LocalCheckInModelAdapter());
    
    // Inicializa datasources
    _authDatasource = LocalAuthDatasource();
    await _authDatasource.initialize();
    
    _habitsDatasource = LocalHabitsDatasource();
    await _habitsDatasource.initialize();
    
    debugPrint('✅ Hive initialized successfully');
    debugPrint('   📦 Local Storage: Ready');
    debugPrint('   🔒 User data: Stored locally');
    debugPrint('   📋 Habits data: Stored locally');
    debugPrint('   ✅ Check-ins data: Stored locally');
  } catch (e) {
    debugPrint('❌ Error initializing Hive: $e');
  }
}

class VidaPlusApp extends StatefulWidget {
  const VidaPlusApp({super.key});

  @override
  State<VidaPlusApp> createState() => _VidaPlusAppState();
}

class _VidaPlusAppState extends State<VidaPlusApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Controllers
        ChangeNotifierProvider(
          create: (context) => ThemeController()..initialize(),
        ),
        
                         // Auth Controller with Local Dependencies
        ChangeNotifierProvider(
          create: (context) {
            // Use pre-initialized datasources
            final authRepository = LocalAuthRepositoryImpl(datasource: _authDatasource);
           
            // Create use cases
            final signInUseCase = SignInUseCase(authRepository);
            final signUpUseCase = SignUpUseCase(authRepository);
            final signOutUseCase = SignOutUseCase(authRepository);
            final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
            final getAuthStateUseCase = GetAuthStateUseCase(authRepository);
            final updateProfileUseCase = UpdateProfileUseCase(authRepository);
           
           // Create notification service
           final notificationService = NotificationService();
           
           return AuthController(
             signInUseCase: signInUseCase,
             signUpUseCase: signUpUseCase,
             signOutUseCase: signOutUseCase,
             getCurrentUserUseCase: getCurrentUserUseCase,
             getAuthStateUseCase: getAuthStateUseCase,
             updateProfileUseCase: updateProfileUseCase,
             notificationService: notificationService,
             localAuthRepository: authRepository,
           );
         },
       ),
        
                // Habits Controller with Local Dependencies
        ChangeNotifierProxyProvider<AuthController, HabitsController>(
          create: (context) {
            // Use pre-initialized datasources
            final habitsRepository = LocalHabitsRepositoryImpl(datasource: _habitsDatasource);
           
            // Create use cases
            final createHabitUseCase = CreateHabitUseCase(habitsRepository);
            final getUserHabitsUseCase = GetUserHabitsUseCase(habitsRepository);
            final getUserHabitsStreamUseCase = GetUserHabitsStreamUseCase(habitsRepository);
            final updateHabitUseCase = UpdateHabitUseCase(habitsRepository);
            final deleteHabitUseCase = DeleteHabitUseCase(habitsRepository);
            final checkInHabitUseCase = CheckInHabitUseCase(habitsRepository);
            final getTodayCheckInsUseCase = GetTodayCheckInsUseCase(habitsRepository);
            final getHabitsProgressUseCase = GetHabitsProgressUseCase(habitsRepository);
            final getHabitHistoryUseCase = GetHabitHistoryUseCase(habitsRepository);
           
           // Create notification service
           final notificationService = NotificationService();
           
           return HabitsController(
             createHabitUseCase: createHabitUseCase,
             getUserHabitsUseCase: getUserHabitsUseCase,
             getUserHabitsStreamUseCase: getUserHabitsStreamUseCase,
             updateHabitUseCase: updateHabitUseCase,
             deleteHabitUseCase: deleteHabitUseCase,
             checkInHabitUseCase: checkInHabitUseCase,
             getTodayCheckInsUseCase: getTodayCheckInsUseCase,
             getHabitsProgressUseCase: getHabitsProgressUseCase,
             getHabitHistoryUseCase: getHabitHistoryUseCase,
             notificationService: notificationService,
           );
         },
          update: (context, authController, habitsController) => habitsController!,
        ),
      ],
      child: Consumer2<ThemeController, AuthController>(
        builder: (context, themeController, authController, child) {
          // Escuta mudanças de autenticação para navegação automática
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!authController.isAuthenticated && _navigatorKey.currentState != null) {
              _navigatorKey.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
            }
          });

          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Vida+ Offline',
            debugShowCheckedModeBanner: false,
            themeMode: themeController.materialThemeMode,
            theme: _buildTheme(
              brightness: Brightness.light,
              primaryColor: themeController.primaryColor.color,
            ),
            darkTheme: _buildTheme(
              brightness: Brightness.dark,
              primaryColor: themeController.primaryColor.color,
            ),
            home: const SplashPage(),
            routes: {
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
            },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color primaryColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      fontFamily: 'Inter', // Fonte moderna
      
      // AppBar theme moderno
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      
      // Card theme melhorado
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      ),
      
      // Botões modernos
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input decoration melhorado
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // FAB moderno
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom navigation melhorado
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Dialog theme moderno
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: colorScheme.surface,
      ),
      
      // Snackbar moderno
      snackBarTheme: SnackBarThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Lista tile moderna
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

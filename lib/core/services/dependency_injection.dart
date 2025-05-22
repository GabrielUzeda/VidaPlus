// Configuração da injeção de dependência
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:vida_plus/data/datasources/firebase_auth_datasource.dart';
import 'package:vida_plus/data/datasources/firestore_habit_datasource.dart';
import 'package:vida_plus/data/datasources/firestore_user_datasource.dart';
import 'package:vida_plus/data/repositories_impl/auth_repository_impl.dart';
import 'package:vida_plus/data/repositories_impl/habit_repository_impl.dart';
import 'package:vida_plus/data/repositories_impl/user_repository_impl.dart';
import 'package:vida_plus/domain/repositories/auth_repository.dart';
import 'package:vida_plus/domain/repositories/habit_repository.dart';
import 'package:vida_plus/domain/repositories/user_repository.dart';
import 'package:vida_plus/domain/usecases/auth/sign_in.dart';
import 'package:vida_plus/domain/usecases/auth/sign_up.dart';
import 'package:vida_plus/domain/usecases/habit/get_habits.dart';
import 'package:vida_plus/domain/usecases/habit/manage_habit.dart';
import 'package:vida_plus/domain/usecases/user/get_current_user.dart';
import 'package:vida_plus/presentation/controllers/auth_controller.dart';
import 'package:vida_plus/presentation/controllers/habit_controller.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> init() async {
  // Firebase
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  serviceLocator.registerLazySingleton(() => firebaseAuth);
  serviceLocator.registerLazySingleton(() => firestore);

  // Data sources
  serviceLocator.registerLazySingleton<FirebaseAuthDatasource>(
    () => FirebaseAuthDatasourceImpl(
      firebaseAuth: serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton<FirestoreUserDatasource>(
    () => FirestoreUserDatasourceImpl(
      firestore: serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton<FirestoreHabitDatasource>(
    () => FirestoreHabitDatasourceImpl(
      firestore: serviceLocator(),
    ),
  );

  // Repositories
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authDatasource: serviceLocator(),
      userDatasource: serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      userDatasource: serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(
      habitDatasource: serviceLocator(),
    ),
  );

  // Use cases - Auth
  serviceLocator.registerLazySingleton(
    () => SignIn(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => SignUp(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => GetCurrentUser(serviceLocator(), serviceLocator()),
  );

  // Use cases - Habit
  serviceLocator.registerLazySingleton(
    () => GetHabits(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => GetHabitsByFrequency(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => CreateHabit(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => UpdateHabit(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => DeleteHabit(serviceLocator()),
  );

  // Controllers
  serviceLocator.registerFactory(
    () => AuthController(
      signIn: serviceLocator(),
      signUp: serviceLocator(),
      getCurrentUser: serviceLocator(),
      authRepository: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => HabitController(
      getHabits: serviceLocator(),
      getHabitsByFrequency: serviceLocator(),
      createHabit: serviceLocator(),
      updateHabit: serviceLocator(),
      deleteHabit: serviceLocator(),
    ),
  );
} 
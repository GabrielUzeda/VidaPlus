import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../domain/entities/habit_entity.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _scheduledNotificationsKey = 'scheduled_notifications';
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;
  Set<String> _scheduledHabits = {};

  // Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Inicializa timezone
      tz.initializeTimeZones();
      
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // Configurações para Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configurações para iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin!.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Carrega hábitos já agendados
      await _loadScheduledHabits();

      _isInitialized = true;
    } catch (e) {
      // Se a inicialização falhar, marca como não inicializado
      // mas não lança exceção para não quebrar o app
      debugPrint('Error initializing notifications: $e');
      _isInitialized = false;
      _flutterLocalNotificationsPlugin = null;
    }
  }

  // Trata o tap na notificação
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap - could implement navigation based on payload
  }

  // Solicita permissão para notificações (Android 13+)
  Future<bool> requestPermission() async {
    if (!_isInitialized || _flutterLocalNotificationsPlugin == null) {
      debugPrint('NotificationService not initialized, cannot request permissions');
      return false;
    }

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      try {
        // 1. Solicita permissão para notificações
        bool? notificationGranted = await androidImplementation.requestNotificationsPermission();
        debugPrint('🔔 Notification permission: $notificationGranted');
        
        // Se não conseguiu, tenta de novo de forma mais insistente
        if (notificationGranted != true) {
          debugPrint('⚠️ Trying notification permission again...');
          await Future.delayed(const Duration(milliseconds: 500));
          notificationGranted = await androidImplementation.requestNotificationsPermission();
        }
        
        // 2. Solicita permissão para alarmes exatos (Android 13+)
        bool? exactAlarmsGranted = await androidImplementation.requestExactAlarmsPermission();
        debugPrint('⏰ Exact alarms permission: $exactAlarmsGranted');
        
        // Se não conseguiu, tenta de novo
        if (exactAlarmsGranted != true) {
          debugPrint('⚠️ Trying exact alarms permission again...');
          await Future.delayed(const Duration(milliseconds: 500));
          exactAlarmsGranted = await androidImplementation.requestExactAlarmsPermission();
        }
        
        // 3. Verifica se pode criar canais de notificação
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'habit_reminders',
            'Lembretes de Hábitos',
            description: 'Notificações para lembrar de realizar hábitos',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            ledColor: Color.fromARGB(255, 255, 0, 0),
          ),
        );
        
        // 4. Verifica capacidades finais
        final canScheduleExact = await canScheduleExactAlarms();
        debugPrint('✅ Final status - Notifications: ${notificationGranted ?? false}, Exact alarms: $canScheduleExact');
        
        return (notificationGranted ?? false);
      } catch (e) {
        debugPrint('❌ Error requesting permissions: $e');
        return false;
      }
    }
    return true; // Para outras plataformas
  }

  // Verifica se pode agendar alarmes exatos
  Future<bool> canScheduleExactAlarms() async {
    if (!_isInitialized || _flutterLocalNotificationsPlugin == null) {
      return false;
    }

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      try {
        return await androidImplementation.canScheduleExactNotifications() ?? false;
      } catch (e) {
        debugPrint('Error checking exact alarms capability: $e');
        return false;
      }
    }
    return true; // Para outras plataformas
  }

  // Agenda notificação para lembrete de hábito
  Future<void> scheduleHabitReminder(HabitEntity habit) async {
    try {
      await _ensureInitialized();
      
      debugPrint('🎯 Starting to schedule habit: ${habit.name}');
      
      final isEnabled = await getNotificationsEnabled();
      if (!isEnabled) {
        debugPrint('❌ Notifications disabled in app settings');
        return;
      }

      if (habit.recommendedTime == null) {
        debugPrint('❌ No recommended time for habit: ${habit.name}');
        return;
      }

      // Verifica permissões antes de agendar
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        debugPrint('❌ No notification permissions granted');
        return;
      }

      // Cancela notificação anterior se existir para evitar duplicatas
      await cancelHabitReminder(habit.id);

      // Parse do horário recomendado (formato: "08:00")
      final timeParts = habit.recommendedTime!.split(':');
      if (timeParts.length != 2) {
        debugPrint('❌ Invalid time format: ${habit.recommendedTime}');
        return;
      }

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null || minute == null) {
        debugPrint('❌ Could not parse time: ${habit.recommendedTime}');
        return;
      }

      // Calcula o próximo horário da notificação
      final now = DateTime.now();
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Se o horário já passou hoje, agenda para amanhã
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        debugPrint('📅 Time already passed today, scheduling for tomorrow: $scheduledDate');
      } else {
        debugPrint('📅 Scheduling for today: $scheduledDate');
      }

      // Converte para timezone
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );
      
      debugPrint('🕐 Scheduled timezone: $scheduledTZ');

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'habit_reminders',
        'Lembretes de Hábitos',
        channelDescription: 'Notificações para lembrar de realizar hábitos',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        // Configurações adicionais para melhor funcionamento
        enableLights: true,
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500,
        autoCancel: true,
        ongoing: false,
        showWhen: true,
        when: scheduledTZ.millisecondsSinceEpoch,
        usesChronometer: false,
        chronometerCountDown: false,
        channelShowBadge: true,
        onlyAlertOnce: false,
        visibility: NotificationVisibility.public,
        // Configurações adicionais para garantir que apareça
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
        interruptionLevel: InterruptionLevel.active,
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iosPlatformChannelSpecifics,
          );

      // Verifica se pode usar alarmes exatos
      final canUseExactAlarms = await canScheduleExactAlarms();
      debugPrint('🔒 Can schedule exact alarms: $canUseExactAlarms');
      
      final notificationId = habit.id.hashCode;
      debugPrint('🆔 Notification ID: $notificationId');
      
      if (canUseExactAlarms) {
        // Agenda a notificação para o horário específico (exact alarm)
        await _flutterLocalNotificationsPlugin!.zonedSchedule(
          notificationId, // ID único para o hábito
          'Hora do seu hábito! 🌟',
          'Não se esqueça de: ${habit.name}',
          scheduledTZ,
          platformChannelSpecifics,
          payload: habit.id,
          matchDateTimeComponents: DateTimeComponents.time, // Repete diariamente no mesmo horário
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        debugPrint('✅ Scheduled EXACT alarm for habit: ${habit.name} at ${habit.recommendedTime} (next: $scheduledTZ)');
      } else {
        // Solicita permissão para alarmes exatos
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin?.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          await androidImplementation.requestExactAlarmsPermission();
        }

        // Usa agendamento inexato como fallback
        await _flutterLocalNotificationsPlugin!.zonedSchedule(
          notificationId, // ID único para o hábito
          'Hora do seu hábito! 🌟',
          'Não se esqueça de: ${habit.name}',
          scheduledTZ,
          platformChannelSpecifics,
          payload: habit.id,
          matchDateTimeComponents: DateTimeComponents.time,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        debugPrint('⚠️ Scheduled INEXACT alarm for habit: ${habit.name} at ${habit.recommendedTime} (exact alarms not available)');
      }

      // Marca como agendado
      await _markHabitAsScheduled(habit.id);
      
      // Verifica se foi realmente agendado
      final pendingNotifications = await _flutterLocalNotificationsPlugin!.pendingNotificationRequests();
      final isScheduled = pendingNotifications.any((n) => n.id == notificationId);
      debugPrint('🔍 Verification - Notification scheduled: $isScheduled');
      
    } catch (e) {
      // Log detalhado do erro
      debugPrint('❌ Error scheduling habit reminder for ${habit.name}: $e');
    }
  }

  // Cancela notificação de um hábito específico
  Future<void> cancelHabitReminder(String habitId) async {
    try {
      await _ensureInitialized();
      await _flutterLocalNotificationsPlugin!.cancel(habitId.hashCode);
      
      // Remove da lista de agendados
      await _removeHabitFromScheduled(habitId);
    } catch (e) {
      // Silently handle errors during notification cancellation
      debugPrint('Error canceling habit reminder: $e');
    }
  }

  // Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    try {
      // Verifica se o serviço está inicializado antes de tentar cancelar
      if (!_isInitialized || _flutterLocalNotificationsPlugin == null) {
        debugPrint('NotificationService not initialized, skipping notification cancellation');
        return;
      }
      
      await _flutterLocalNotificationsPlugin!.cancelAll();
      
      // Limpa a lista de hábitos agendados
      _scheduledHabits.clear();
      await _saveScheduledHabits();
      
      debugPrint('✅ All notifications canceled successfully');
    } catch (e) {
      // Silently handle errors during notification cancellation
      // This prevents crashes during logout or app termination
      debugPrint('Error canceling notifications: $e');
    }
  }

  // Agenda notificação diária para check-in
  Future<void> scheduleDailyCheckInReminder() async {
    try {
      await _ensureInitialized();
      
      final isEnabled = await getNotificationsEnabled();
      if (!isEnabled) return;

      // Agenda para as 20:00 todos os dias
      DateTime scheduledDate = DateTime.now();
      scheduledDate = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        20, // 20:00
        0,
      );

      // Se já passou das 20:00 hoje, agenda para amanhã
      if (scheduledDate.isBefore(DateTime.now())) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'daily_checkin',
        'Check-in Diário',
        channelDescription: 'Lembrete para revisar o progresso do dia',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      // Para simplificar, usando notificação simples
      await _flutterLocalNotificationsPlugin!.show(
        999999, // ID fixo para o check-in diário
        'Como foi seu dia? 📊',
        'Vamos revisar seu progresso com os hábitos hoje!',
        platformChannelSpecifics,
        payload: 'daily_checkin',
      );
    } catch (e) {
      // Silently handle errors during notification scheduling
      debugPrint('Error scheduling daily check-in reminder: $e');
    }
  }

  // Obtém configuração de notificações ativadas
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  // Define configuração de notificações
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);

    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  // Força o reagendamento de um hábito (útil quando horário muda)
  Future<void> rescheduleHabitReminder(HabitEntity habit) async {
    // Remove da lista de agendados para forçar reagendamento
    await _removeHabitFromScheduled(habit.id);
    // Cancela a notificação atual
    await cancelHabitReminder(habit.id);
    // Agenda novamente
    await scheduleHabitReminder(habit);
  }

  // Envia notificação imediata
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _ensureInitialized();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'instant_notifications',
        'Notificações Instantâneas',
        channelDescription: 'Notificações imediatas do app',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin!.show(
        DateTime.now().millisecondsSinceEpoch % 100000, // ID único
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      // Silently handle errors during notification display
      debugPrint('Error showing notification: $e');
    }
  }

  // Garante que o serviço está inicializado antes de usar
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Se ainda não conseguiu inicializar, lança exceção
    if (!_isInitialized || _flutterLocalNotificationsPlugin == null) {
      throw Exception('NotificationService failed to initialize');
    }
  }

  // Carrega hábitos já agendados
  Future<void> _loadScheduledHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledList = prefs.getStringList(_scheduledNotificationsKey) ?? [];
      _scheduledHabits = scheduledList.toSet();
    } catch (e) {
      debugPrint('Error loading scheduled habits: $e');
      _scheduledHabits = {};
    }
  }

  // Salva hábitos agendados
  Future<void> _saveScheduledHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_scheduledNotificationsKey, _scheduledHabits.toList());
    } catch (e) {
      debugPrint('Error saving scheduled habits: $e');
    }
  }

  // Marca um hábito como agendado
  Future<void> _markHabitAsScheduled(String habitId) async {
    _scheduledHabits.add(habitId);
    await _saveScheduledHabits();
  }

  // Remove um hábito da lista de agendados
  Future<void> _removeHabitFromScheduled(String habitId) async {
    _scheduledHabits.remove(habitId);
    await _saveScheduledHabits();
  }

  // Métodos para depuração
  Future<void> debugNotifications() async {
    try {
      await _ensureInitialized();
      
      // Lista notificações pendentes
      final pendingNotifications = await _flutterLocalNotificationsPlugin!.pendingNotificationRequests();
      debugPrint('📋 Pending notifications: ${pendingNotifications.length}');
      
      for (final notification in pendingNotifications) {
        debugPrint('  - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
      }
      
      // Verifica permissões
      final canSchedule = await canScheduleExactAlarms();
      debugPrint('🔔 Can schedule exact alarms: $canSchedule');
      
      // Lista hábitos agendados
      debugPrint('📅 Scheduled habits: ${_scheduledHabits.length}');
      for (final habitId in _scheduledHabits) {
        debugPrint('  - Habit ID: $habitId');
      }
      
    } catch (e) {
      debugPrint('❌ Error debugging notifications: $e');
    }
  }

  // Limpa todas as notificações e redefine estado
  Future<void> resetNotifications() async {
    try {
      await _ensureInitialized();
      await cancelAllNotifications();
      _scheduledHabits.clear();
      await _saveScheduledHabits();
      debugPrint('🔄 Notifications reset completed');
    } catch (e) {
      debugPrint('❌ Error resetting notifications: $e');
    }
  }
} 
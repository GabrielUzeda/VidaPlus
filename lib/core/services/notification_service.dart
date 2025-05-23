import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../domain/entities/habit_entity.dart';

// Serviço para gerenciar notificações locais
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
      print('Error initializing notifications: $e');
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
    await _ensureInitialized();

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin?.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    return true; // Para outras plataformas
  }

  // Agenda notificação para lembrete de hábito
  Future<void> scheduleHabitReminder(HabitEntity habit) async {
    try {
      await _ensureInitialized();
      
      final isEnabled = await getNotificationsEnabled();
      if (!isEnabled) return;

      if (habit.recommendedTime == null) return;

      // Verifica se já está agendado para evitar reagendamento desnecessário
      if (_isHabitScheduled(habit.id)) return;

      // Parse do horário recomendado (formato: "08:00")
      final timeParts = habit.recommendedTime!.split(':');
      if (timeParts.length != 2) return;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null || minute == null) return;

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
      }

      // Converte para timezone
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'habit_reminders',
        'Lembretes de Hábitos',
        channelDescription: 'Notificações para lembrar de realizar hábitos',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      // Agenda a notificação para o horário específico
      await _flutterLocalNotificationsPlugin!.zonedSchedule(
        habit.id.hashCode, // ID único para o hábito
        'Hora do seu hábito! 🌟',
        'Não se esqueça de: ${habit.name}',
        scheduledTZ,
        platformChannelSpecifics,
        payload: habit.id,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repete diariamente no mesmo horário
      );

      // Marca como agendado
      await _markHabitAsScheduled(habit.id);
    } catch (e) {
      // Silently handle errors during notification scheduling
      print('Error scheduling habit reminder: $e');
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
      print('Error canceling habit reminder: $e');
    }
  }

  // Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    try {
      await _ensureInitialized();
      await _flutterLocalNotificationsPlugin!.cancelAll();
      
      // Limpa a lista de hábitos agendados
      _scheduledHabits.clear();
      await _saveScheduledHabits();
    } catch (e) {
      // Silently handle errors during notification cancellation
      // This prevents crashes during logout or app termination
      print('Error canceling notifications: $e');
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
      print('Error scheduling daily check-in reminder: $e');
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
      print('Error showing notification: $e');
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
      print('Error loading scheduled habits: $e');
      _scheduledHabits = {};
    }
  }

  // Salva hábitos agendados
  Future<void> _saveScheduledHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_scheduledNotificationsKey, _scheduledHabits.toList());
    } catch (e) {
      print('Error saving scheduled habits: $e');
    }
  }

  // Verifica se um hábito já está agendado
  bool _isHabitScheduled(String habitId) {
    return _scheduledHabits.contains(habitId);
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
} 
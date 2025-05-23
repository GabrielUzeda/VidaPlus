import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system('Automático'),
  light('Claro'),
  dark('Escuro');

  const AppThemeMode(this.label);
  final String label;
}

class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  AppThemeMode _themeMode = AppThemeMode.system;
  
  AppThemeMode get themeMode => _themeMode;
  
  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Inicializa o tema salvo
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        _themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == savedTheme,
          orElse: () => AppThemeMode.system,
        );
        notifyListeners();
      }
    } catch (e) {
      // Se houver erro, usa o tema padrão (sistema)
      print('Erro ao carregar tema: $e');
    }
  }

  // Altera o tema
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    
    try {
      _themeMode = mode;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.name);
    } catch (e) {
      print('Erro ao salvar tema: $e');
    }
  }

  // Cicla entre os temas (para botão de alternância)
  Future<void> toggleTheme() async {
    final currentIndex = AppThemeMode.values.indexOf(_themeMode);
    final nextIndex = (currentIndex + 1) % AppThemeMode.values.length;
    await setThemeMode(AppThemeMode.values[nextIndex]);
  }
} 
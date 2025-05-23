import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system('Automático'),
  light('Claro'),
  dark('Escuro');

  const AppThemeMode(this.label);
  final String label;
}

enum AppPrimaryColor {
  green('Verde', Colors.green),
  blue('Azul', Colors.blue),
  purple('Roxo', Colors.purple),
  orange('Laranja', Colors.orange),
  red('Vermelho', Colors.red),
  pink('Rosa', Colors.pink),
  teal('Verde-azulado', Colors.teal),
  indigo('Índigo', Colors.indigo);

  const AppPrimaryColor(this.label, this.color);
  final String label;
  final Color color;
}

class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _colorKey = 'app_primary_color';
  
  AppThemeMode _themeMode = AppThemeMode.system;
  AppPrimaryColor _primaryColor = AppPrimaryColor.green;
  
  AppThemeMode get themeMode => _themeMode;
  AppPrimaryColor get primaryColor => _primaryColor;
  
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

  // Inicializa o tema e cor salvos
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Carrega tema
      final savedTheme = prefs.getString(_themeKey);
      if (savedTheme != null) {
        _themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == savedTheme,
          orElse: () => AppThemeMode.system,
        );
      }
      
      // Carrega cor
      final savedColor = prefs.getString(_colorKey);
      if (savedColor != null) {
        _primaryColor = AppPrimaryColor.values.firstWhere(
          (color) => color.name == savedColor,
          orElse: () => AppPrimaryColor.green,
        );
      }
      
      notifyListeners();
    } catch (e) {
      // Se houver erro, usa as configurações padrão
      print('Erro ao carregar tema/cor: $e');
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

  // Altera a cor primária
  Future<void> setPrimaryColor(AppPrimaryColor color) async {
    if (_primaryColor == color) return;
    
    try {
      _primaryColor = color;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_colorKey, color.name);
    } catch (e) {
      print('Erro ao salvar cor: $e');
    }
  }

  // Cicla entre os temas (para botão de alternância)
  Future<void> toggleTheme() async {
    final currentIndex = AppThemeMode.values.indexOf(_themeMode);
    final nextIndex = (currentIndex + 1) % AppThemeMode.values.length;
    await setThemeMode(AppThemeMode.values[nextIndex]);
  }
} 
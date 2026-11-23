import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modo de apariencia elegido por el usuario: automático, claro u oscuro.
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  /// Lee la preferencia guardada. Se llama una vez al iniciar la app.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getString(_key);

    _mode = ThemeMode.values.firstWhere(
      (modo) => modo.name == guardado,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) {
      return;
    }

    _mode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
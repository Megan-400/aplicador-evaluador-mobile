import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart';

/// Botón de la barra superior para elegir el modo claro, oscuro o automático.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key, required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return PopupMenuButton<ThemeMode>(
          tooltip: 'Apariencia',
          icon: const Icon(Icons.brightness_6_outlined),
          initialValue: controller.mode,
          onSelected: controller.setMode,
          itemBuilder: (context) => const [
            PopupMenuItem(value: ThemeMode.system, child: Text('Automático')),
            PopupMenuItem(value: ThemeMode.light, child: Text('Claro')),
            PopupMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
          ],
        );
      },
    );
  }
}
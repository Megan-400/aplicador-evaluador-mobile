import 'package:flutter/material.dart';
import 'presentation/navigation/teacher_root.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const TeacherApp());
}

class TeacherApp extends StatelessWidget {
  const TeacherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicador/Evaluador - Docente',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const TeacherRoot(),
    );
  }
}
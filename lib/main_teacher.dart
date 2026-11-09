import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/teacher/auth/teacher_login_screen.dart';

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
      home: const TeacherLoginScreen(),
    );
  }
}
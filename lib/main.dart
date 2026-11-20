import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/remote/student_dashboard_remote_data_source.dart';
import 'data/repositories/student_dashboard_repository_impl.dart';
import 'domain/usecases/load_student_dashboard.dart';
import 'presentation/screens/student/access/student_access_screen.dart';
import 'presentation/state/student_dashboard_controller.dart';
import 'presentation/navigation/student_app_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StudentDashboardRemoteDataSource _remoteDataSource;
  late final StudentDashboardController _controller;

  @override
  void initState() {
    super.initState();

    _remoteDataSource = StudentDashboardRemoteDataSource();

    final repository = StudentDashboardRepositoryImpl(
      remoteDataSource: _remoteDataSource,
    );

    _controller = StudentDashboardController(
      loadDashboard: LoadStudentDashboard(repository: repository),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _remoteDataSource.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicador/Evaluador de Exámenes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final dashboard = _controller.dashboard;

          if (dashboard == null) {
            return StudentAccessScreen(controller: _controller);
          }

          return StudentAppShell(
            dashboard: dashboard,
            onSignOut: _controller.signOut,
          );
        },
      ),
    );
  }
}

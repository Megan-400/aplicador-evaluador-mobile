import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/exams_repository_impl.dart';
import '../../data/repositories/groups_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/exams_repository.dart';
import '../../domain/repositories/groups_repository.dart';
import '../screens/teacher/auth/teacher_login_screen.dart';
import 'teacher_app_shell.dart';

/// Decide si se muestra el inicio de sesión o el portal del docente.
class TeacherRoot extends StatefulWidget {
  const TeacherRoot({super.key});

  @override
  State<TeacherRoot> createState() => _TeacherRootState();
}

class _TeacherRootState extends State<TeacherRoot> {
  final AuthRepository _authRepository = AuthRepositoryImpl();
  final GroupsRepository _groupsRepository = GroupsRepositoryImpl();
  final ExamsRepository _examsRepository = ExamsRepositoryImpl();
  Teacher? _teacher;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();

    ApiClient.configureAuth(
      tokenProvider: _authRepository.readAccessToken,
      onUnauthorized: _cerrarSesion,
    );

    _restaurarSesion();
  }

  Future<void> _restaurarSesion() async {
    final sesion = await _authRepository.restoreSession();

    if (!mounted) {
      return;
    }

    setState(() {
      _teacher = sesion?.teacher;
      _cargando = false;
    });
  }

  void _alIniciarSesion(AuthSession sesion) {
    setState(() => _teacher = sesion.teacher);
  }

  Future<void> _cerrarSesion() async {
    await _authRepository.logout();

    if (!mounted) {
      return;
    }

    setState(() => _teacher = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final teacher = _teacher;

    if (teacher == null) {
      return TeacherLoginScreen(
        authRepository: _authRepository,
        onLoggedIn: _alIniciarSesion,
      );
    }

    return TeacherAppShell(
      teacher: teacher,
      groupsRepository: _groupsRepository,
      examsRepository: _examsRepository,
      onLogout: _cerrarSesion,
    );
  }
}
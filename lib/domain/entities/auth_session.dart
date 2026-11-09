import 'teacher.dart';

/// Sesión iniciada: credenciales de acceso y docente asociado.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.teacher,
  });

  final String accessToken;
  final String refreshToken;
  final Teacher teacher;
}
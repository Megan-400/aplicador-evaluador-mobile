import '../../domain/entities/auth_session.dart';
import 'teacher_model.dart';

/// Respuesta de `POST /auth/login` convertida a objeto.
class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required super.teacher,
  });

  factory AuthSessionModel.fromLoginJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      teacher: TeacherModel.fromJson(json['docente'] as Map<String, dynamic>),
    );
  }
}
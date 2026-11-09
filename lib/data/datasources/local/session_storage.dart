import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/auth_session_model.dart';
import '../../models/teacher_model.dart';

/// Guarda la sesión del docente en almacenamiento cifrado del dispositivo.
class SessionStorage {
  SessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _teacherKey = 'teacher';

  final FlutterSecureStorage _storage;

  Future<void> save(AuthSessionModel session) async {
    final teacher = TeacherModel.fromEntity(session.teacher);

    await _storage.write(key: _accessKey, value: session.accessToken);
    await _storage.write(key: _refreshKey, value: session.refreshToken);
    await _storage.write(key: _teacherKey, value: jsonEncode(teacher.toJson()));
  }

  /// Devuelve la sesión guardada, o `null` si no hay una válida.
  Future<AuthSessionModel?> read() async {
    try {
      final access = await _storage.read(key: _accessKey);
      final refresh = await _storage.read(key: _refreshKey);
      final teacher = await _storage.read(key: _teacherKey);

      if (access == null || refresh == null || teacher == null) {
        return null;
      }

      return AuthSessionModel(
        accessToken: access,
        refreshToken: refresh,
        teacher: TeacherModel.fromJson(
          jsonDecode(teacher) as Map<String, dynamic>,
        ),
      );
    } catch (_) {
      await clear();
      return null;
    }
  }
  
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _teacherKey);
  }
}
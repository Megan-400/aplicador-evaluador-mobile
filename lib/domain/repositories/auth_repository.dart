import '../entities/auth_session.dart';

/// Contrato de autenticación que consume la capa de presentación.
abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession?> restoreSession();

  Future<String?> readAccessToken();

  Future<void> logout();
}
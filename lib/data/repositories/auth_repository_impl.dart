import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/session_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';

/// Implementación que combina la API y el almacenamiento local.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remote,
    SessionStorage? storage,
  }) : _remote = remote ?? AuthRemoteDataSource(),
       _storage = storage ?? SessionStorage();

  final AuthRemoteDataSource _remote;
  final SessionStorage _storage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _remote.login(email: email, password: password);
    await _storage.save(session);
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() => _storage.read();

  @override
  Future<String?> readAccessToken() => _storage.readAccessToken();

  @override
  Future<void> logout() => _storage.clear();
}
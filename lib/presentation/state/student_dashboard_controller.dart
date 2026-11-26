import 'package:flutter/foundation.dart';

import '../../core/network/api_exception.dart';
import '../../domain/entities/student_dashboard.dart';
import '../../domain/entities/student_session_credentials.dart';
import '../../domain/usecases/load_student_dashboard.dart';

enum StudentDashboardStatus { initial, loading, success, failure }

class StudentDashboardController extends ChangeNotifier {
  StudentDashboardController({required this.loadDashboard});

  final LoadStudentDashboard loadDashboard;

  StudentDashboardStatus _status = StudentDashboardStatus.initial;
  StudentDashboard? _dashboard;
  String? _errorMessage;

  StudentDashboardStatus get status => _status;
  StudentDashboard? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == StudentDashboardStatus.loading;

  StudentSessionCredentials? _credentials;

  StudentSessionCredentials? get credentials => _credentials;

  Future<bool> signIn({
    required String folio,
    required String accessCode,
  }) async {
    _status = StudentDashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await loadDashboard(folio: folio, accessCode: accessCode);

      _credentials = StudentSessionCredentials(
        folio: folio.trim().toUpperCase(),
        accessCode: accessCode.trim().toUpperCase(),
      );

      _status = StudentDashboardStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _dashboard = null;
      _status = StudentDashboardStatus.failure;
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _dashboard = null;
      _status = StudentDashboardStatus.failure;
      _errorMessage = 'Ocurrió un error inesperado. Inténtalo nuevamente.';
      notifyListeners();
      return false;
    }
  }

  /// Actualiza el dashboard con las credenciales de la sesión en memoria.
  /// Devuelve `false` si la sesión no contiene credenciales o si la
  /// actualización falla. Conserva el dashboard anterior cuando ocurre
  /// un error para no expulsar al alumno del portal.
  Future<bool> refresh() async {
    final credentials = _credentials;

    if (credentials == null || isLoading) {
      return false;
    }

    _status = StudentDashboardStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final refreshedDashboard = await loadDashboard(
        folio: credentials.folio,
        accessCode: credentials.accessCode,
      );

      _dashboard = refreshedDashboard;
      _status = StudentDashboardStatus.success;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on ApiException catch (error) {
      _status = StudentDashboardStatus.success;
      _errorMessage = error.message;
      notifyListeners();

      return false;
    } on FormatException catch (error) {
      _status = StudentDashboardStatus.success;
      _errorMessage = error.message;
      notifyListeners();

      return false;
    } catch (_) {
      _status = StudentDashboardStatus.success;
      _errorMessage =
          'El examen fue entregado, pero no fue posible '
          'actualizar el portal.';
      notifyListeners();

      return false;
    }
  }

  void signOut() {
    _credentials = null;
    _dashboard = null;
    _errorMessage = null;
    _status = StudentDashboardStatus.initial;
    notifyListeners();
  }
}

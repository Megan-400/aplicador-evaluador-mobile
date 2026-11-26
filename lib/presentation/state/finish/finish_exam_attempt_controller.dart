import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entities/finish/student_finished_attempt.dart';
import '../../../domain/usecases/finish/finish_student_exam_attempt.dart';

enum FinishExamAttemptStatus { initial, loading, success, failure }

/// Administra la entrega definitiva de un intento.
///
/// El token se recibe solamente al ejecutar [finish]. No se persiste,
/// registra ni expone en la interfaz.
class FinishExamAttemptController extends ChangeNotifier {
  FinishExamAttemptController({required this.finishAttempt});

  final FinishStudentExamAttempt finishAttempt;

  FinishExamAttemptStatus _status = FinishExamAttemptStatus.initial;

  StudentFinishedAttempt? _finishedAttempt;
  String? _errorMessage;

  FinishExamAttemptStatus get status => _status;

  StudentFinishedAttempt? get finishedAttempt {
    return _finishedAttempt;
  }

  String? get errorMessage => _errorMessage;

  bool get isLoading {
    return _status == FinishExamAttemptStatus.loading;
  }

  bool get isSuccess {
    return _status == FinishExamAttemptStatus.success;
  }

  /// Solicita la entrega definitiva.
  ///
  /// Devuelve `false` si ya existe una solicitud en curso.
  /// Una confirmación idempotente del backend también se considera exitosa.
  Future<bool> finish({required String sessionToken}) async {
    if (isLoading) {
      return false;
    }

    _status = FinishExamAttemptStatus.loading;
    _finishedAttempt = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _finishedAttempt = await finishAttempt(sessionToken: sessionToken);

      _status = FinishExamAttemptStatus.success;
      notifyListeners();

      return true;
    } on ApiException catch (error) {
      _status = FinishExamAttemptStatus.failure;
      _errorMessage = error.message;
      notifyListeners();

      return false;
    } on FormatException catch (error) {
      _status = FinishExamAttemptStatus.failure;
      _errorMessage = error.message;
      notifyListeners();

      return false;
    } catch (_) {
      _status = FinishExamAttemptStatus.failure;
      _errorMessage = 'Ocurrió un error inesperado al entregar el examen.';
      notifyListeners();

      return false;
    }
  }

  void reset() {
    _status = FinishExamAttemptStatus.initial;
    _finishedAttempt = null;
    _errorMessage = null;
    notifyListeners();
  }
}

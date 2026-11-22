import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entities/attempts/student_exam_attempt.dart';
import '../../../domain/usecases/attempts/start_student_exam_attempt.dart';

enum StartExamAttemptStatus { initial, loading, success, failure }

class StartExamAttemptController extends ChangeNotifier {
  StartExamAttemptController({required this.startAttempt});

  final StartStudentExamAttempt startAttempt;

  StartExamAttemptStatus _status = StartExamAttemptStatus.initial;

  StudentExamAttempt? _attempt;
  String? _errorMessage;

  StartExamAttemptStatus get status => _status;
  StudentExamAttempt? get attempt => _attempt;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == StartExamAttemptStatus.loading;

  Future<bool> start({
    required String folio,
    required String accessCode,
    required int examId,
  }) async {
    if (isLoading) {
      return false;
    }

    _status = StartExamAttemptStatus.loading;
    _attempt = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _attempt = await startAttempt(
        folio: folio,
        accessCode: accessCode,
        examId: examId,
      );

      _status = StartExamAttemptStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _status = StartExamAttemptStatus.failure;
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } on FormatException catch (error) {
      _status = StartExamAttemptStatus.failure;
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _status = StartExamAttemptStatus.failure;
      _errorMessage = 'Ocurrió un error inesperado al iniciar el examen.';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = StartExamAttemptStatus.initial;
    _attempt = null;
    _errorMessage = null;
    notifyListeners();
  }
}

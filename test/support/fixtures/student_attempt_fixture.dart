import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/attempts/student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_session_credentials.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/attempts/student_exam_attempt_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/attempts/start_student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/attempts/start_exam_attempt_controller.dart';

const testStudentCredentials = StudentSessionCredentials(
  folio: 'FOLIO123',
  accessCode: 'ABCD27',
);

StartExamAttemptController buildTestStartAttemptController() {
  return StartExamAttemptController(
    startAttempt: StartStudentExamAttempt(
      repository: _TestAttemptRepository(),
    ),
  );
}

class _TestAttemptRepository
    implements StudentExamAttemptRepository {
  @override
  Future<StudentExamAttempt> start({
    required String folio,
    required String accessCode,
    required int examId,
  }) {
    throw const ApiException(
      type: ApiFailureType.serviceUnavailable,
      message: 'Servicio de prueba no disponible.',
    );
  }
}
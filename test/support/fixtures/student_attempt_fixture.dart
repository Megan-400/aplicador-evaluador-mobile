import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/attempts/student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_session_credentials.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/attempts/student_exam_attempt_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/attempts/start_student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/attempts/start_exam_attempt_controller.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/questions/student_exam_questions_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/questions/load_student_exam_questions.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/questions/exam_questions_controller.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_exam_questions.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/answers/student_saved_answer.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/answers/student_answer_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/answers/save_student_answer.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/answers/save_answers_controller.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/finish/student_finished_attempt.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/finish/student_finish_attempt_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/finish/finish_student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/finish/finish_exam_attempt_controller.dart';

const testStudentCredentials = StudentSessionCredentials(
  folio: 'FOLIO123',
  accessCode: 'ABCD27',
);

StartExamAttemptController buildTestStartAttemptController() {
  return StartExamAttemptController(
    startAttempt: StartStudentExamAttempt(repository: _TestAttemptRepository()),
  );
}

class _TestAttemptRepository implements StudentExamAttemptRepository {
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

ExamQuestionsController buildTestQuestionsController() {
  return ExamQuestionsController(
    loadQuestions: LoadStudentExamQuestions(
      repository: _TestQuestionsRepository(),
    ),
  );
}

class _TestQuestionsRepository implements StudentExamQuestionsRepository {
  @override
  Future<StudentExamQuestions> load({required String sessionToken}) async {
    return const StudentExamQuestions(
      examName: 'Examen de prueba',
      questions: [],
      savedAnswers: {},
    );
  }
}

SaveAnswersController buildTestSaveAnswersController() {
  return SaveAnswersController(
    saveAnswer: SaveStudentAnswer(repository: _TestAnswerRepository()),
  );
}

class _TestAnswerRepository implements StudentAnswerRepository {
  @override
  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) async {
    return StudentSavedAnswer(id: 1000 + questionId, questionId: questionId);
  }
}

FinishExamAttemptController buildTestFinishAttemptController() {
  return FinishExamAttemptController(
    finishAttempt: FinishStudentExamAttempt(
      repository: _TestFinishRepository(),
    ),
  );
}

class _TestFinishRepository implements StudentFinishAttemptRepository {
  @override
  Future<StudentFinishedAttempt> finish({required String sessionToken}) async {
    return StudentFinishedAttempt(
      id: 123,
      status: 'finalizado',
      submittedAt: DateTime.parse('2026-11-23T18:30:00-06:00'),
    );
  }
}

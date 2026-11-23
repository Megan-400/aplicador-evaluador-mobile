import 'dart:async';

import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_exam_question.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_question_type.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/questions/student_exam_questions_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/questions/load_student_exam_questions.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/questions/exam_questions_controller.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_exam_questions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExamQuestionsController', () {
    test('inicia sin preguntas ni respuestas', () {
      final controller = _buildController(
        repository: _SuccessQuestionsRepository(),
      );

      expect(controller.status, ExamQuestionsStatus.initial);
      expect(controller.questions, isEmpty);
      expect(controller.currentQuestion, isNull);
      expect(controller.currentIndex, 0);
      expect(controller.totalQuestions, 0);
      expect(controller.progress, 0);
      expect(controller.progressLabel, 'Sin preguntas');
      expect(controller.localAnswers, isEmpty);
      expect(controller.isLoading, isFalse);

      controller.dispose();
    });

    test('carga las preguntas correctamente', () async {
      final repository = _SuccessQuestionsRepository();

      final controller = _buildController(repository: repository);

      final result = await controller.load(sessionToken: ' token-sintetico ');

      expect(result, isTrue);
      expect(controller.status, ExamQuestionsStatus.success);
      expect(controller.questions, hasLength(4));
      expect(controller.currentQuestion?.id, 1);
      expect(controller.currentIndex, 0);
      expect(controller.totalQuestions, 4);
      expect(controller.progress, closeTo(1 / 4, 0.001));
      expect(controller.progressLabel, 'Pregunta 1 de 4');
      expect(controller.isFirstQuestion, isTrue);
      expect(controller.isLastQuestion, isFalse);
      expect(controller.canGoPrevious, isFalse);
      expect(controller.canGoNext, isTrue);
      expect(repository.receivedToken, 'token-sintetico');

      controller.dispose();
    });

    test('notifica el estado de carga antes de completar', () async {
      final repository = _PendingQuestionsRepository();

      final controller = _buildController(repository: repository);

      final loadFuture = controller.load(sessionToken: 'token-sintetico');

      expect(controller.status, ExamQuestionsStatus.loading);
      expect(controller.isLoading, isTrue);
      expect(controller.questions, isEmpty);

      repository.complete(_questions);

      final result = await loadFuture;

      expect(result, isTrue);
      expect(controller.status, ExamQuestionsStatus.success);
      expect(controller.isLoading, isFalse);
      expect(controller.questions, hasLength(4));

      controller.dispose();
    });

    test('evita una segunda carga mientras está procesando', () async {
      final repository = _PendingQuestionsRepository();

      final controller = _buildController(repository: repository);

      final firstLoad = controller.load(sessionToken: 'token-sintetico');

      final secondResult = await controller.load(sessionToken: 'otro-token');

      expect(secondResult, isFalse);
      expect(repository.callCount, 1);

      repository.complete(_questions);

      expect(await firstLoad, isTrue);

      controller.dispose();
    });

    test('muestra estado vacío cuando no existen preguntas', () async {
      final controller = _buildController(
        repository: _SuccessQuestionsRepository(questions: const []),
      );

      final result = await controller.load(sessionToken: 'token-sintetico');

      expect(result, isTrue);
      expect(controller.status, ExamQuestionsStatus.empty);
      expect(controller.questions, isEmpty);
      expect(controller.currentQuestion, isNull);
      expect(controller.progress, 0);
      expect(controller.progressLabel, 'Sin preguntas');

      controller.dispose();
    });

    test('expone un error controlado de la API', () async {
      const exception = ApiException(
        type: ApiFailureType.examUnavailable,
        statusCode: 403,
        message: 'La sesión del examen ya no está disponible.',
      );

      final controller = _buildController(
        repository: _FailureQuestionsRepository(exception: exception),
      );

      final result = await controller.load(sessionToken: 'token-sintetico');

      expect(result, isFalse);
      expect(controller.status, ExamQuestionsStatus.failure);
      expect(controller.questions, isEmpty);
      expect(controller.currentQuestion, isNull);
      expect(
        controller.errorMessage,
        'La sesión del examen ya no está disponible.',
      );
      expect(controller.isLoading, isFalse);

      controller.dispose();
    });

    test('avanza y retrocede entre preguntas', () async {
      final controller = _buildController(
        repository: _SuccessQuestionsRepository(),
      );

      await controller.load(sessionToken: 'token-sintetico');

      expect(controller.currentQuestion?.id, 1);
      expect(controller.progressLabel, 'Pregunta 1 de 4');

      expect(controller.next(), isTrue);
      expect(controller.currentQuestion?.id, 2);
      expect(controller.currentIndex, 1);
      expect(controller.progressLabel, 'Pregunta 2 de 4');
      expect(controller.isLastQuestion, isFalse);

      expect(controller.next(), isTrue);
      expect(controller.currentQuestion?.id, 3);
      expect(controller.currentIndex, 2);
      expect(controller.progressLabel, 'Pregunta 3 de 4');
      expect(controller.isLastQuestion, isFalse);

      expect(controller.next(), isTrue);
      expect(controller.currentQuestion?.id, 4);
      expect(controller.currentIndex, 3);
      expect(controller.progressLabel, 'Pregunta 4 de 4');
      expect(controller.isLastQuestion, isTrue);
      expect(controller.canGoNext, isFalse);

      expect(controller.next(), isFalse);
      expect(controller.currentQuestion?.id, 4);

      expect(controller.previous(), isTrue);
      expect(controller.currentQuestion?.id, 3);

      expect(controller.previous(), isTrue);
      expect(controller.currentQuestion?.id, 2);

      expect(controller.previous(), isTrue);
      expect(controller.currentQuestion?.id, 1);

      expect(controller.previous(), isFalse);
      expect(controller.currentQuestion?.id, 1);

      controller.dispose();
    });

    test('navega directamente a un índice válido', () async {
      final controller = _buildController(
        repository: _SuccessQuestionsRepository(),
      );

      await controller.load(sessionToken: 'token-sintetico');

      expect(controller.goTo(2), isTrue);
      expect(controller.currentQuestion?.id, 3);

      expect(controller.goTo(3), isTrue);
      expect(controller.currentQuestion?.id, 4);
      expect(controller.isLastQuestion, isTrue);

      expect(controller.goTo(-1), isFalse);
      expect(controller.currentQuestion?.id, 4);

      expect(controller.goTo(10), isFalse);
      expect(controller.currentQuestion?.id, 4);

      controller.dispose();
    });

    test('conserva respuestas locales al navegar', () async {
      final controller = _buildController(
        repository: _SuccessQuestionsRepository(),
      );

      await controller.load(sessionToken: 'token-sintetico');

      controller.setAnswer(questionId: 1, answer: 'Respuesta abierta.');

      expect(controller.answerFor(1), 'Respuesta abierta.');
      expect(controller.currentAnswer, 'Respuesta abierta.');
      expect(controller.isAnswered(1), isTrue);
      expect(controller.answeredCount, 1);

      controller.next();

      controller.setAnswer(questionId: 2, answer: 'Primera opción');

      expect(controller.answerFor(2), 'Primera opción');
      expect(controller.answeredCount, 2);

      controller.previous();

      expect(controller.currentQuestion?.id, 1);
      expect(controller.currentAnswer, 'Respuesta abierta.');

      controller.dispose();
    });

    test('elimina una respuesta cuando queda vacía', () async {
      final controller = _buildController(
        repository: _SuccessQuestionsRepository(),
      );

      await controller.load(sessionToken: 'token-sintetico');

      controller.setAnswer(questionId: 1, answer: 'Respuesta temporal.');

      expect(controller.isAnswered(1), isTrue);

      controller.setAnswer(questionId: 1, answer: '   ');

      expect(controller.answerFor(1), '');
      expect(controller.isAnswered(1), isFalse);
      expect(controller.answeredCount, 0);
      expect(controller.localAnswers, isEmpty);

      controller.dispose();
    });

    test('ignora respuestas para preguntas inexistentes', () async {
      final controller = _buildController(
        repository: _SuccessQuestionsRepository(),
      );

      await controller.load(sessionToken: 'token-sintetico');

      controller.setAnswer(questionId: 999, answer: 'Respuesta inválida.');

      expect(controller.localAnswers, isEmpty);
      expect(controller.answeredCount, 0);

      controller.dispose();
    });

    test('reset elimina preguntas, respuestas y errores', () async {
      final controller = _buildController(
        repository: _SuccessQuestionsRepository(),
      );

      await controller.load(sessionToken: 'token-sintetico');

      controller.setAnswer(questionId: 1, answer: 'Respuesta temporal.');

      controller.next();

      controller.reset();

      expect(controller.status, ExamQuestionsStatus.initial);
      expect(controller.questions, isEmpty);
      expect(controller.currentQuestion, isNull);
      expect(controller.currentIndex, 0);
      expect(controller.localAnswers, isEmpty);
      expect(controller.errorMessage, isNull);
      expect(controller.progress, 0);

      controller.dispose();
    });

    test('restaura las respuestas guardadas por el backend', () async {
      final controller = _buildController(
        repository: _SuccessQuestionsRepository(
          savedAnswers: const {
            1: 'Respuesta abierta guardada.',
            2: 'Segunda opción',
          },
        ),
      );

      final result = await controller.load(sessionToken: 'token-sintetico');

      expect(result, isTrue);
      expect(controller.examName, 'Examen de prueba');

      expect(controller.answerFor(1), 'Respuesta abierta guardada.');

      expect(controller.answerFor(2), 'Segunda opción');

      expect(controller.answeredCount, 2);
      expect(controller.currentAnswer, 'Respuesta abierta guardada.');

      controller.dispose();
    });

    test('restaura texto abierto, selección y código guardados', () async {
      const savedCode =
          'print("México");\n'
          '// Código guardado';

      final controller = _buildController(
        repository: _SuccessQuestionsRepository(
          savedAnswers: const {
            1: 'Respuesta abierta guardada.',
            2: 'Segunda opción',
            4: savedCode,
          },
        ),
      );

      final result = await controller.load(sessionToken: 'token-sintetico');

      expect(result, isTrue);

      expect(controller.answerFor(1), 'Respuesta abierta guardada.');

      expect(controller.answerFor(2), 'Segunda opción');

      expect(controller.answerFor(4), savedCode);

      expect(controller.answeredCount, 3);

      controller.dispose();
    });
  });
}

ExamQuestionsController _buildController({
  required StudentExamQuestionsRepository repository,
}) {
  return ExamQuestionsController(
    loadQuestions: LoadStudentExamQuestions(repository: repository),
  );
}

const List<StudentExamQuestion> _questions = [
  StudentExamQuestion(
    id: 1,
    sectionId: 10,
    type: StudentQuestionType.open,
    prompt: 'Pregunta abierta sintética.',
    timeSeconds: 60,
  ),
  StudentExamQuestion(
    id: 2,
    sectionId: 10,
    type: StudentQuestionType.multipleChoice,
    prompt: 'Pregunta de opción múltiple sintética.',
    timeSeconds: 90,
    options: ['Primera opción', 'Segunda opción'],
  ),
  StudentExamQuestion(
    id: 3,
    sectionId: 11,
    type: StudentQuestionType.matching,
    prompt: 'Pregunta de relación sintética.',
    timeSeconds: 120,
  ),
  StudentExamQuestion(
    id: 4,
    sectionId: 12,
    type: StudentQuestionType.programming,
    prompt: 'Pregunta de programación sintética.',
    timeSeconds: 300,
  ),
];

class _SuccessQuestionsRepository implements StudentExamQuestionsRepository {
  _SuccessQuestionsRepository({
    List<StudentExamQuestion>? questions,
    this.savedAnswers = const {},
  }) : questions = questions ?? _questions;

  final List<StudentExamQuestion> questions;
  final Map<int, String> savedAnswers;

  String? receivedToken;
  int callCount = 0;

  @override
  Future<StudentExamQuestions> load({required String sessionToken}) async {
    callCount++;
    receivedToken = sessionToken;

    return StudentExamQuestions(
      examName: 'Examen de prueba',
      questions: questions,
      savedAnswers: savedAnswers,
    );
  }
}

class _FailureQuestionsRepository implements StudentExamQuestionsRepository {
  const _FailureQuestionsRepository({required this.exception});

  final ApiException exception;

  @override
  Future<StudentExamQuestions> load({required String sessionToken}) {
    throw exception;
  }
}

class _PendingQuestionsRepository implements StudentExamQuestionsRepository {
  final Completer<StudentExamQuestions> _completer =
      Completer<StudentExamQuestions>();

  int callCount = 0;

  @override
  Future<StudentExamQuestions> load({required String sessionToken}) {
    callCount++;
    return _completer.future;
  }

  void complete(
    List<StudentExamQuestion> questions, {
    Map<int, String> savedAnswers = const {},
  }) {
    _completer.complete(
      StudentExamQuestions(
        examName: 'Examen de prueba',
        questions: questions,
        savedAnswers: savedAnswers,
      ),
    );
  }
}

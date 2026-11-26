import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/answers/student_saved_answer.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/attempts/student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_exam_question.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_exam_questions.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_matching_pair.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_question_option.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_question_type.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_exam_summary.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/answers/student_answer_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/questions/student_exam_questions_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/answers/save_student_answer.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/questions/load_student_exam_questions.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/attempt/student_exam_attempt_screen.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/answers/save_answers_controller.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/questions/exam_questions_controller.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/finish/student_finished_attempt.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/finish/student_finish_attempt_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/finish/finish_student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/finish/finish_exam_attempt_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<_ScreenDependencies> buildScreen(
    WidgetTester tester, {
    StudentExamQuestionsRepository? questionsRepository,
    StudentAnswerRepository? answerRepository,
    StudentFinishAttemptRepository? finishRepository,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    final resolvedQuestionsRepository =
        questionsRepository ?? _SuccessQuestionsRepository();

    final resolvedAnswerRepository =
        answerRepository ?? _SuccessAnswerRepository();

    final resolvedFinishRepository =
        finishRepository ?? _SuccessFinishRepository();

    final questionsController = ExamQuestionsController(
      loadQuestions: LoadStudentExamQuestions(
        repository: resolvedQuestionsRepository,
      ),
    );

    final saveAnswersController = SaveAnswersController(
      saveAnswer: SaveStudentAnswer(repository: resolvedAnswerRepository),
    );

    final finishAttemptController = FinishExamAttemptController(
      finishAttempt: FinishStudentExamAttempt(
        repository: resolvedFinishRepository,
      ),
    );

    addTearDown(questionsController.dispose);
    addTearDown(saveAnswersController.dispose);
    addTearDown(finishAttemptController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: StudentExamAttemptScreen(
          exam: _exam,
          attempt: _attempt,
          questionsController: questionsController,
          saveAnswersController: saveAnswersController,
          finishAttemptController: finishAttemptController,
        ),
      ),
    );

    await tester.pumpAndSettle();

    return _ScreenDependencies(
      questionsController: questionsController,
      saveAnswersController: saveAnswersController,
      finishAttemptController: finishAttemptController,
      questionsRepository: resolvedQuestionsRepository,
      answerRepository: resolvedAnswerRepository,
      finishRepository: resolvedFinishRepository,
    );
  }

  Future<void> goToLastQuestion(WidgetTester tester) async {
    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byKey(const Key('next-question-button')));

      await tester.pumpAndSettle();
    }

    expect(find.text('Pregunta 4 de 4'), findsOneWidget);
  }

  testWidgets('muestra la primera pregunta y el progreso', (tester) async {
    await buildScreen(tester);

    expect(find.text('Pregunta 1 de 4'), findsOneWidget);

    expect(find.text('0/4 respondidas'), findsOneWidget);

    expect(find.text('Pregunta abierta sintética.'), findsOneWidget);

    expect(find.byKey(const Key('previous-question-button')), findsOneWidget);

    expect(find.byKey(const Key('next-question-button')), findsOneWidget);
  });

  testWidgets('avanza y retrocede entre preguntas', (tester) async {
    await buildScreen(tester);

    await tester.tap(find.byKey(const Key('next-question-button')));
    await tester.pumpAndSettle();

    expect(find.text('Pregunta 2 de 4'), findsOneWidget);

    expect(find.text('Pregunta de opción múltiple sintética.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('previous-question-button')));
    await tester.pumpAndSettle();

    expect(find.text('Pregunta 1 de 4'), findsOneWidget);
  });

  testWidgets('guarda una respuesta abierta antes de avanzar', (tester) async {
    final repository = _SuccessAnswerRepository();

    final dependencies = await buildScreen(
      tester,
      answerRepository: repository,
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('open-answer-1')),
      'Respuesta guardada desde la pantalla.',
    );

    expect(
      dependencies.saveAnswersController.stateFor(1).status,
      AnswerSaveStatus.pending,
    );

    await tester.tap(find.byKey(const Key('next-question-button')));
    await tester.pumpAndSettle();

    expect(find.text('Pregunta 2 de 4'), findsOneWidget);

    expect(repository.callCount, 1);
    expect(repository.receivedQuestionId, 1);

    expect(repository.receivedAnswer, 'Respuesta guardada desde la pantalla.');

    expect(
      dependencies.saveAnswersController.stateFor(1).status,
      AnswerSaveStatus.saved,
    );
  });

  testWidgets('conserva una respuesta local al navegar', (tester) async {
    await buildScreen(tester);

    await tester.enterText(
      find.byKey(const ValueKey<String>('open-answer-1')),
      'Respuesta local.',
    );

    await tester.tap(find.byKey(const Key('next-question-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('previous-question-button')));
    await tester.pumpAndSettle();

    expect(find.text('Respuesta local.'), findsOneWidget);

    expect(find.text('1/4 respondidas'), findsOneWidget);
  });

  testWidgets('restaura una respuesta abierta al reanudar', (tester) async {
    await buildScreen(
      tester,
      questionsRepository: _SuccessQuestionsRepository(
        savedAnswers: const {1: 'Respuesta recuperada.'},
      ),
    );

    expect(find.text('Respuesta recuperada.'), findsOneWidget);

    expect(find.text('1/4 respondidas'), findsOneWidget);
  });

  testWidgets('restaura una opción múltiple mediante su clave', (tester) async {
    await buildScreen(
      tester,
      questionsRepository: _SuccessQuestionsRepository(
        savedAnswers: const {2: 'Segunda opción'},
      ),
    );

    await tester.tap(find.byKey(const Key('next-question-button')));
    await tester.pumpAndSettle();

    expect(find.text('Pregunta 2 de 4'), findsOneWidget);

    final radioGroup = tester.widget<RadioGroup<String>>(
      find.byType(RadioGroup<String>),
    );

    expect(radioGroup.groupValue, 'Segunda opción');

    expect(find.text('Segunda opción'), findsOneWidget);

    expect(find.text('1/4 respondidas'), findsOneWidget);
  });

  testWidgets('selecciona y guarda el texto de una opción múltiple', (
    tester,
  ) async {
    final repository = _SuccessAnswerRepository();

    await buildScreen(tester, answerRepository: repository);

    await tester.tap(find.byKey(const Key('next-question-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('choice-2-1')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('next-question-button')));
    await tester.pumpAndSettle();

    expect(repository.receivedQuestionId, 2);
    expect(repository.receivedAnswer, 'Segunda opción');
    expect(repository.receivedAnswer, isNot('B'));
  });

  testWidgets('impide avanzar cuando falla el guardado', (tester) async {
    final dependencies = await buildScreen(
      tester,
      answerRepository: _FailureAnswerRepository(),
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('open-answer-1')),
      'Respuesta que no pudo guardarse.',
    );

    await tester.tap(find.byKey(const Key('next-question-button')));
    await tester.pumpAndSettle();

    expect(find.text('Pregunta 1 de 4'), findsOneWidget);

    expect(
      dependencies.saveAnswersController.stateFor(1).status,
      AnswerSaveStatus.failure,
    );

    expect(find.text('No fue posible guardar la respuesta.'), findsOneWidget);

    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('muestra Revisar en la última pregunta', (tester) async {
    await buildScreen(tester);

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byKey(const Key('next-question-button')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Pregunta 4 de 4'), findsOneWidget);

    expect(find.byKey(const Key('review-answers-button')), findsOneWidget);
  });

  testWidgets('guarda la última respuesta antes de mostrar la revisión', (
    tester,
  ) async {
    final repository = _SuccessAnswerRepository();

    await buildScreen(tester, answerRepository: repository);

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byKey(const Key('next-question-button')));
      await tester.pumpAndSettle();
    }

    const sourceCode =
        'print("México");\n'
        '// Código para guardar';

    await tester.enterText(
      find.byKey(const ValueKey<String>('programming-answer-4')),
      sourceCode,
    );

    await tester.tap(find.byKey(const Key('review-answers-button')));
    await tester.pumpAndSettle();

    expect(repository.receivedQuestionId, 4);
    expect(repository.receivedAnswer, sourceCode);

    expect(find.text('Revisión del intento'), findsOneWidget);
  });

  testWidgets('muestra el resumen de respuestas', (tester) async {
    await buildScreen(tester);

    await tester.enterText(
      find.byKey(const ValueKey<String>('open-answer-1')),
      'Respuesta local.',
    );

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byKey(const Key('next-question-button')));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byKey(const Key('review-answers-button')));
    await tester.pumpAndSettle();

    expect(find.text('Revisión del intento'), findsOneWidget);

    expect(
      find.text('1 de 4 preguntas tienen una respuesta local.'),
      findsOneWidget,
    );

    expect(find.text('Preguntas pendientes'), findsOneWidget);
  });

  testWidgets('restaura una respuesta de programación al reanudar', (
    tester,
  ) async {
    const savedCode =
        'print("México");\n'
        '// Código guardado';

    await buildScreen(
      tester,
      questionsRepository: _SuccessQuestionsRepository(
        savedAnswers: const {4: savedCode},
      ),
    );

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byKey(const Key('next-question-button')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Pregunta 4 de 4'), findsOneWidget);

    final field = tester.widget<TextField>(
      find.byKey(const ValueKey<String>('programming-answer-4')),
    );

    expect(field.controller?.text, savedCode);

    expect(find.text('1/4 respondidas'), findsOneWidget);
  });

  testWidgets('muestra un estado vacío', (tester) async {
    await buildScreen(
      tester,
      questionsRepository: _SuccessQuestionsRepository(questions: const []),
    );

    expect(find.text('Sin preguntas disponibles'), findsOneWidget);
  });

  testWidgets('muestra el error de consulta y permite reintentar', (
    tester,
  ) async {
    final repository = _FailureQuestionsRepository();

    await buildScreen(tester, questionsRepository: repository);

    expect(find.text('No fue posible cargar las preguntas'), findsOneWidget);

    expect(find.byKey(const Key('retry-questions-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('retry-questions-button')));
    await tester.pumpAndSettle();

    expect(repository.callCount, 2);
  });

  testWidgets('solicita confirmación antes de salir', (tester) async {
    await buildScreen(tester);

    await tester.tap(find.byKey(const Key('attempt-exit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Salir del examen'), findsOneWidget);

    expect(find.text('Continuar examen'), findsOneWidget);
  });

  testWidgets('advierte si existen respuestas sin guardar', (tester) async {
    await buildScreen(tester);

    await tester.enterText(
      find.byKey(const ValueKey<String>('open-answer-1')),
      'Respuesta pendiente.',
    );

    await tester.tap(find.byKey(const Key('attempt-exit-button')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Existen respuestas pendientes'),
      findsOneWidget,
    );
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildScreen(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentExamAttemptScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('advierte antes de entregar con preguntas sin responder', (
    tester,
  ) async {
    await buildScreen(tester);

    await goToLastQuestion(tester);

    await tester.tap(find.byKey(const Key('review-answers-button')));
    await tester.pumpAndSettle();

    expect(find.text('Revisión del intento'), findsOneWidget);

    expect(find.text('Preguntas pendientes'), findsOneWidget);

    await tester.tap(find.byKey(const Key('finish-exam-button')));
    await tester.pumpAndSettle();

    expect(find.text('Entregar examen'), findsOneWidget);

    expect(find.textContaining('preguntas sin responder'), findsOneWidget);

    expect(find.byKey(const Key('confirm-finish-exam-button')), findsOneWidget);
  });

  testWidgets('cancela la entrega y permite continuar respondiendo', (
    tester,
  ) async {
    final repository = _SuccessFinishRepository();

    await buildScreen(tester, finishRepository: repository);

    await goToLastQuestion(tester);

    await tester.tap(find.byKey(const Key('review-answers-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('finish-exam-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar respondiendo').last);
    await tester.pumpAndSettle();

    expect(find.text('Entregar examen'), findsNothing);

    expect(repository.callCount, 0);

    expect(find.text('Pregunta 4 de 4'), findsOneWidget);
  });

  testWidgets('entrega el examen y muestra la confirmación', (tester) async {
    final repository = _SuccessFinishRepository();

    final dependencies = await buildScreen(
      tester,
      finishRepository: repository,
    );

    await goToLastQuestion(tester);

    await tester.tap(find.byKey(const Key('review-answers-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('finish-exam-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirm-finish-exam-button')));
    await tester.pumpAndSettle();

    expect(repository.callCount, 1);

    expect(repository.receivedToken, 'token-sintetico-de-prueba');

    expect(
      dependencies.finishAttemptController.status,
      FinishExamAttemptStatus.success,
    );

    expect(find.text('Examen entregado correctamente'), findsOneWidget);

    expect(find.textContaining('23/11/2026'), findsOneWidget);

    expect(
      find.textContaining('resultado puede permanecer en revisión'),
      findsOneWidget,
    );

    expect(find.byKey(const Key('finish-exam-return-button')), findsOneWidget);
  });

  testWidgets('regresa al portal después de confirmar la entrega', (
    tester,
  ) async {
    final questionsController = ExamQuestionsController(
      loadQuestions: LoadStudentExamQuestions(
        repository: _SuccessQuestionsRepository(),
      ),
    );

    final saveAnswersController = SaveAnswersController(
      saveAnswer: SaveStudentAnswer(repository: _SuccessAnswerRepository()),
    );

    final finishAttemptController = FinishExamAttemptController(
      finishAttempt: FinishStudentExamAttempt(
        repository: _SuccessFinishRepository(),
      ),
    );

    addTearDown(questionsController.dispose);
    addTearDown(saveAnswersController.dispose);
    addTearDown(finishAttemptController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const Key('open-attempt-button'),
                  onPressed: () {
                    Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (context) {
                          return StudentExamAttemptScreen(
                            exam: _exam,
                            attempt: _attempt,
                            questionsController: questionsController,
                            saveAnswersController: saveAnswersController,
                            finishAttemptController: finishAttemptController,
                          );
                        },
                      ),
                    );
                  },
                  child: const Text('Abrir intento'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-attempt-button')));
    await tester.pumpAndSettle();

    await goToLastQuestion(tester);

    await tester.tap(find.byKey(const Key('review-answers-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('finish-exam-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirm-finish-exam-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('finish-exam-return-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('open-attempt-button')), findsOneWidget);

    expect(find.byType(StudentExamAttemptScreen), findsNothing);

    expect(questionsController.questions, isEmpty);
    expect(saveAnswersController.states, isEmpty);
  });

  testWidgets('conserva el intento cuando la entrega falla', (tester) async {
    final repository = _FailureFinishRepository();

    final dependencies = await buildScreen(
      tester,
      finishRepository: repository,
    );

    await goToLastQuestion(tester);

    await tester.tap(find.byKey(const Key('review-answers-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('finish-exam-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirm-finish-exam-button')));
    await tester.pumpAndSettle();

    expect(repository.callCount, 1);

    expect(
      dependencies.finishAttemptController.status,
      FinishExamAttemptStatus.failure,
    );

    expect(find.text('No fue posible entregar el examen.'), findsOneWidget);

    expect(find.text('Reintentar'), findsOneWidget);

    expect(find.byType(StudentExamAttemptScreen), findsOneWidget);

    expect(dependencies.questionsController.questions, isNotEmpty);
  });

  testWidgets('reintenta la entrega después de un error', (tester) async {
    final repository = _FailOnceFinishRepository();

    await buildScreen(tester, finishRepository: repository);

    await goToLastQuestion(tester);

    await tester.tap(find.byKey(const Key('review-answers-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('finish-exam-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirm-finish-exam-button')));
    await tester.pumpAndSettle();

    expect(repository.callCount, 1);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    // El reintento vuelve a solicitar la confirmación.
    expect(find.text('Entregar examen'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-finish-exam-button')));
    await tester.pumpAndSettle();

    expect(repository.callCount, 2);

    expect(find.text('Examen entregado correctamente'), findsOneWidget);
  });
}

class _ScreenDependencies {
  const _ScreenDependencies({
    required this.questionsController,
    required this.saveAnswersController,
    required this.finishAttemptController,
    required this.questionsRepository,
    required this.answerRepository,
    required this.finishRepository,
  });

  final ExamQuestionsController questionsController;

  final SaveAnswersController saveAnswersController;

  final FinishExamAttemptController finishAttemptController;

  final StudentExamQuestionsRepository questionsRepository;

  final StudentAnswerRepository answerRepository;

  final StudentFinishAttemptRepository finishRepository;
}

const _exam = StudentExamSummary(
  id: '25',
  title: 'Evaluación parcial',
  subject: 'Matemáticas',
  status: StudentExamStatus.available,
  durationMinutes: 45,
  questionCount: 4,
);

final _attempt = StudentExamAttempt(
  id: 123,
  examId: 25,
  sessionToken: 'token-sintetico-de-prueba',
  startedAt: DateTime.parse('2026-11-20T18:30:00-06:00'),
  wasResumed: false,
);

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
    options: [
      StudentQuestionOption(value: 'A', label: 'Primera opción'),
      StudentQuestionOption(value: 'B', label: 'Segunda opción'),
    ],
  ),
  StudentExamQuestion(
    id: 3,
    sectionId: 11,
    type: StudentQuestionType.matching,
    prompt: 'Pregunta de relación sintética.',
    timeSeconds: 120,
    matchingPairs: [
      StudentMatchingPair(left: 'a | b', right: 'Operador OR'),
      StudentMatchingPair(left: 'a & b', right: 'Operador AND'),
    ],
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

  @override
  Future<StudentExamQuestions> load({required String sessionToken}) async {
    return StudentExamQuestions(
      examName: 'Evaluación de prueba',
      questions: questions,
      savedAnswers: savedAnswers,
    );
  }
}

class _FailureQuestionsRepository implements StudentExamQuestionsRepository {
  int callCount = 0;

  @override
  Future<StudentExamQuestions> load({required String sessionToken}) {
    callCount++;

    throw const ApiException(
      type: ApiFailureType.requestFailed,
      statusCode: 422,
      message: 'No se pudieron cargar las preguntas.',
    );
  }
}

class _SuccessAnswerRepository implements StudentAnswerRepository {
  int callCount = 0;
  String? receivedToken;
  int? receivedQuestionId;
  String? receivedAnswer;

  @override
  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) async {
    callCount++;
    receivedToken = sessionToken;
    receivedQuestionId = questionId;
    receivedAnswer = answer;

    return StudentSavedAnswer(id: 1000 + questionId, questionId: questionId);
  }
}

class _FailureAnswerRepository implements StudentAnswerRepository {
  int callCount = 0;

  @override
  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) {
    callCount++;

    throw const ApiException(
      type: ApiFailureType.requestFailed,
      statusCode: 422,
      message: 'No fue posible guardar la respuesta.',
    );
  }
}

class _SuccessFinishRepository implements StudentFinishAttemptRepository {
  int callCount = 0;
  String? receivedToken;

  @override
  Future<StudentFinishedAttempt> finish({required String sessionToken}) async {
    callCount++;
    receivedToken = sessionToken;

    return StudentFinishedAttempt(
      id: 123,
      status: 'finalizado',
      submittedAt: DateTime.parse('2026-11-23T18:30:00-06:00'),
    );
  }
}

class _FailureFinishRepository implements StudentFinishAttemptRepository {
  int callCount = 0;

  @override
  Future<StudentFinishedAttempt> finish({required String sessionToken}) {
    callCount++;

    throw const ApiException(
      type: ApiFailureType.requestFailed,
      statusCode: 422,
      message: 'No fue posible entregar el examen.',
    );
  }
}

class _FailOnceFinishRepository implements StudentFinishAttemptRepository {
  int callCount = 0;

  @override
  Future<StudentFinishedAttempt> finish({required String sessionToken}) async {
    callCount++;

    if (callCount == 1) {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'No fue posible entregar el examen.',
      );
    }

    return StudentFinishedAttempt(
      id: 123,
      status: 'finalizado',
      submittedAt: DateTime.parse('2026-11-23T18:30:00-06:00'),
    );
  }
}

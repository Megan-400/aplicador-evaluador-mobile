import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/attempts/student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_exam_question.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_matching_pair.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_question_type.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_exam_summary.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/questions/student_exam_questions_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/questions/load_student_exam_questions.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/attempt/student_exam_attempt_screen.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/questions/exam_questions_controller.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_exam_questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<ExamQuestionsController> buildScreen(
    WidgetTester tester, {
    StudentExamQuestionsRepository? repository,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    final controller = ExamQuestionsController(
      loadQuestions: LoadStudentExamQuestions(
        repository: repository ?? _SuccessRepository(),
      ),
    );

    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: StudentExamAttemptScreen(
          exam: _exam,
          attempt: _attempt,
          questionsController: controller,
        ),
      ),
    );

    await tester.pumpAndSettle();

    return controller;
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

  testWidgets('conserva una respuesta al navegar', (tester) async {
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

  testWidgets('muestra revisar en la última pregunta', (tester) async {
    await buildScreen(tester);

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byKey(const Key('next-question-button')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Pregunta 4 de 4'), findsOneWidget);

    expect(find.byKey(const Key('review-answers-button')), findsOneWidget);
  });

  testWidgets('muestra el resumen de respuestas', (tester) async {
    await buildScreen(tester);

    await tester.enterText(
      find.byKey(const ValueKey<String>('open-answer-1')),
      'Respuesta local.',
    );

    // Pregunta 1 → 2
    await tester.tap(find.byKey(const Key('next-question-button')));
    await tester.pumpAndSettle();

    // Pregunta 2 → 3
    await tester.tap(find.byKey(const Key('next-question-button')));
    await tester.pumpAndSettle();

    // Pregunta 3 → 4
    await tester.tap(find.byKey(const Key('next-question-button')));
    await tester.pumpAndSettle();

    expect(find.text('Pregunta 4 de 4'), findsOneWidget);

    expect(find.byKey(const Key('review-answers-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('review-answers-button')));
    await tester.pumpAndSettle();

    expect(find.text('Revisión del intento'), findsOneWidget);

    expect(
      find.text('1 de 4 preguntas tienen una respuesta local.'),
      findsOneWidget,
    );

    expect(find.text('Preguntas pendientes'), findsOneWidget);
  });

  testWidgets('muestra un estado vacío', (tester) async {
    await buildScreen(
      tester,
      repository: _SuccessRepository(questions: const []),
    );

    expect(find.text('Sin preguntas disponibles'), findsOneWidget);
  });

  testWidgets('muestra el error y permite reintentar', (tester) async {
    final repository = _FailureRepository();

    await buildScreen(tester, repository: repository);

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

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildScreen(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentExamAttemptScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('restaura una respuesta guardada al reanudar', (tester) async {
    await buildScreen(
      tester,
      repository: _SuccessRepository(
        savedAnswers: const {1: 'Respuesta guardada.'},
      ),
    );

    expect(find.text('Respuesta guardada.'), findsOneWidget);

    expect(find.text('1/4 respondidas'), findsOneWidget);
  });

  testWidgets('restaura una respuesta de programación al reanudar', (
    tester,
  ) async {
    const savedCode =
        'print("México");\n'
        '// Código guardado';

    await buildScreen(
      tester,
      repository: _SuccessRepository(savedAnswers: const {4: savedCode}),
    );

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byKey(const Key('next-question-button')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Pregunta 4 de 4'), findsOneWidget);

    expect(find.text('Pregunta de programación sintética.'), findsOneWidget);

    final field = tester.widget<TextField>(
      find.byKey(const ValueKey<String>('programming-answer-4')),
    );

    expect(field.controller?.text, savedCode);

    expect(find.text('1/4 respondidas'), findsOneWidget);
  });
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
    options: ['Primera opción', 'Segunda opción'],
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

class _SuccessRepository implements StudentExamQuestionsRepository {
  _SuccessRepository({
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

class _FailureRepository implements StudentExamQuestionsRepository {
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

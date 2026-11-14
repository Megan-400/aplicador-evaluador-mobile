import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_exam_summary.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/exams/detail/student_exam_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const availableExam = StudentExamSummary(
    id: 'exam-1',
    title: 'Evaluación parcial',
    subject: 'Matemáticas',
    status: StudentExamStatus.available,
    durationMinutes: 45,
    questionCount: 20,
    instructions: ['Lee cada pregunta.', 'Revisa tus respuestas.'],
  );

  Future<void> buildScreen(
    WidgetTester tester, {
    StudentExamSummary exam = availableExam,
    StartExamCallback? onStartExam,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: StudentExamDetailScreen(
          exam: exam,
          onStartExam: onStartExam ?? (_) async => false,
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('muestra el detalle del examen', (tester) async {
    await buildScreen(tester);

    expect(find.text('Evaluación parcial'), findsOneWidget);
    expect(find.text('Matemáticas'), findsOneWidget);
    expect(find.text('45 minutos'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('Instrucciones'), findsOneWidget);
  });

  testWidgets('habilita iniciar cuando está disponible', (tester) async {
    await buildScreen(tester);

    final buttonFinder = find.byKey(const Key('start-exam-button'));

    await tester.dragUntilVisible(
      buttonFinder,
      find.byType(Scrollable).first,
      const Offset(0, -400),
    );

    final button = tester.widget<ElevatedButton>(buttonFinder);

    expect(button.onPressed, isNotNull);
    expect(find.text('Iniciar examen'), findsOneWidget);
  });

  testWidgets('solicita confirmación antes de iniciar', (tester) async {
    var wasCalled = false;

    await buildScreen(
      tester,
      onStartExam: (_) async {
        wasCalled = true;
        return false;
      },
    );

    await tester.dragUntilVisible(
      find.byKey(const Key('start-exam-button')),
      find.byType(Scrollable).first,
      const Offset(0, -400),
    );

    await tester.tap(find.byKey(const Key('start-exam-button')));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar examen'), findsWidgets);

    await tester.tap(find.text('Iniciar').last);
    await tester.pumpAndSettle();

    expect(wasCalled, isTrue);
  });

  testWidgets('deshabilita iniciar cuando está próximo', (tester) async {
    const upcomingExam = StudentExamSummary(
      id: 'exam-2',
      title: 'Evaluación final',
      subject: 'Programación',
      status: StudentExamStatus.upcoming,
      durationMinutes: 60,
      questionCount: 30,
    );

    await buildScreen(tester, exam: upcomingExam);

    await tester.dragUntilVisible(
      find.byKey(const Key('start-exam-button')),
      find.byType(Scrollable).first,
      const Offset(0, -400),
    );

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('start-exam-button')),
    );

    expect(button.onPressed, isNull);
    expect(find.text('Aún no disponible'), findsOneWidget);
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildScreen(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentExamDetailScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
  });
}

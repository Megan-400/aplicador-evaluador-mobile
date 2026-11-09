import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_exam_summary.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/exams/student_exams_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const exams = [
    StudentExamSummary(
      id: 'exam-1',
      title: 'Evaluación parcial',
      subject: 'Matemáticas',
      status: StudentExamStatus.available,
      durationMinutes: 45,
      questionCount: 20,
    ),
    StudentExamSummary(
      id: 'exam-2',
      title: 'Evaluación final',
      subject: 'Programación',
      status: StudentExamStatus.upcoming,
      durationMinutes: 60,
      questionCount: 30,
    ),
  ];

  Future<void> buildScreen(
    WidgetTester tester, {
    List<StudentExamSummary> examList = const [],
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: Scaffold(body: StudentExamsScreen(exams: examList)),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('muestra el estado vacío sin exámenes', (tester) async {
    await buildScreen(tester);

    expect(find.text('Sin exámenes disponibles'), findsOneWidget);
  });

  testWidgets('muestra los exámenes recibidos', (tester) async {
    await buildScreen(tester, examList: exams);

    expect(find.text('Evaluación parcial'), findsOneWidget);
    expect(find.text('Evaluación final'), findsOneWidget);
    expect(find.text('Matemáticas'), findsOneWidget);
    expect(find.text('Programación'), findsOneWidget);
  });

  testWidgets('filtra exámenes mediante la búsqueda', (tester) async {
    await buildScreen(tester, examList: exams);

    await tester.enterText(find.byType(TextField), 'Programación');
    await tester.pumpAndSettle();

    expect(find.text('Evaluación parcial'), findsNothing);
    expect(find.text('Evaluación final'), findsOneWidget);
  });

  testWidgets('muestra un estado sin resultados', (tester) async {
    await buildScreen(tester, examList: exams);

    await tester.enterText(find.byType(TextField), 'Historia');
    await tester.pumpAndSettle();

    expect(find.text('Sin resultados'), findsOneWidget);
    expect(find.text('Limpiar filtros'), findsWidgets);
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildScreen(tester, examList: exams, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentExamsScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Evaluación parcial'), findsOneWidget);
  });
}

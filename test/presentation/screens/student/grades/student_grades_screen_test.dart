import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_grade_summary.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/grades/student_grades_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /*
   * Datos sintéticos utilizados exclusivamente por las pruebas.
   *
   * No forman parte de la aplicación ni aparecen durante su ejecución normal.
   */
  final grades = [
    StudentGradeSummary(
      id: 'grade-1',
      examTitle: 'Evaluación parcial',
      subject: 'Matemáticas',
      score: 8.5,
      maximumScore: 10,
      result: StudentGradeResult.passed,
      publishedAt: DateTime(2026, 11, 1),
    ),
    StudentGradeSummary(
      id: 'grade-2',
      examTitle: 'Evaluación final',
      subject: 'Programación',
      score: 5,
      maximumScore: 10,
      result: StudentGradeResult.notPassed,
      publishedAt: DateTime(2026, 11, 5),
    ),
  ];

  Future<void> buildScreen(
    WidgetTester tester, {
    List<StudentGradeSummary> gradeList = const [],
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: Scaffold(body: StudentGradesScreen(grades: gradeList)),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('muestra el estado vacío sin calificaciones', (tester) async {
    await buildScreen(tester);

    expect(find.text('Sin calificaciones disponibles'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('muestra las calificaciones recibidas', (tester) async {
    await buildScreen(tester, gradeList: grades);

    final firstGrade = find.text('Evaluación parcial');

    await tester.dragUntilVisible(
      firstGrade,
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );

    expect(firstGrade, findsOneWidget);
    expect(find.text('Matemáticas'), findsOneWidget);

    final secondGrade = find.text('Evaluación final');

    await tester.dragUntilVisible(
      secondGrade,
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );

    expect(secondGrade, findsOneWidget);
    expect(find.text('Programación'), findsOneWidget);
  });

  testWidgets('filtra calificaciones con la búsqueda', (tester) async {
    await buildScreen(tester, gradeList: grades);

    await tester.enterText(find.byType(TextField), 'Programación');
    await tester.pumpAndSettle();

    expect(find.text('Evaluación parcial'), findsNothing);

    final finalExam = find.text('Evaluación final');

    await tester.dragUntilVisible(
      finalExam,
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );

    expect(finalExam, findsOneWidget);
  });

  testWidgets('muestra un estado sin resultados', (tester) async {
    await buildScreen(tester, gradeList: grades);

    await tester.enterText(find.byType(TextField), 'Historia');
    await tester.pumpAndSettle();

    final emptyResult = find.text('Sin resultados');

    await tester.dragUntilVisible(
      emptyResult,
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );

    expect(emptyResult, findsOneWidget);
    expect(find.text('Limpiar filtros'), findsWidgets);
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildScreen(tester, gradeList: grades, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentGradesScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Calificaciones'), findsOneWidget);
  });
}

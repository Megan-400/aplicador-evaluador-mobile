import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/home/student_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> buildHome(
    WidgetTester tester, {
    VoidCallback? onOpenExams,
    VoidCallback? onOpenGrades,
    VoidCallback? onOpenGroups,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: StudentHomeScreen(
          studentName: 'Alumno de prueba',
          pendingExamCount: 2,
          completedExamCount: 1,
          registeredGroupCount: 3,
          onOpenExams: onOpenExams ?? () {},
          onOpenGrades: onOpenGrades ?? () {},
          onOpenGroups: onOpenGroups ?? () {},
          onOpenProfile: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('muestra el contenido principal de Inicio', (tester) async {
    await buildHome(tester);

    expect(find.text('TU ESPACIO ACADÉMICO'), findsOneWidget);

    expect(find.text('Hola, Alumno de prueba.'), findsOneWidget);

    expect(
      find.text('Consulta tus actividades y accesos principales.'),
      findsOneWidget,
    );

    expect(find.text('Portal del alumno'), findsOneWidget);

    expect(find.text('Tu actividad'), findsOneWidget);

    expect(find.byKey(const Key('pending-exams-statistic')), findsOneWidget);

    expect(find.byKey(const Key('completed-exams-statistic')), findsOneWidget);

    expect(
      find.byKey(const Key('registered-groups-statistic')),
      findsOneWidget,
    );

    final pendingCard = find.byKey(const Key('pending-exams-statistic'));

    expect(
      find.descendant(of: pendingCard, matching: find.text('Por realizar')),
      findsOneWidget,
    );

    expect(
      find.descendant(of: pendingCard, matching: find.text('2')),
      findsOneWidget,
    );

    final completedCard = find.byKey(const Key('completed-exams-statistic'));

    expect(
      find.descendant(of: completedCard, matching: find.text('Entregados')),
      findsOneWidget,
    );

    expect(
      find.descendant(of: completedCard, matching: find.text('1')),
      findsOneWidget,
    );

    final groupsCard = find.byKey(const Key('registered-groups-statistic'));

    expect(
      find.descendant(of: groupsCard, matching: find.text('Mis grupos')),
      findsOneWidget,
    );

    expect(
      find.descendant(of: groupsCard, matching: find.text('3')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.text('Próximos exámenes'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();

    expect(find.text('Próximos exámenes'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('No hay próximos exámenes'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();

    expect(find.text('No hay próximos exámenes'), findsOneWidget);
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildHome(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentHomeScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Portal del alumno'), findsOneWidget);
  });

  testWidgets('ejecuta la acción para abrir el perfil', (tester) async {
    var wasCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StudentHomeScreen(
            studentName: 'Alumno de prueba',
            pendingExamCount: 2,
            completedExamCount: 1,
            registeredGroupCount: 3,
            onOpenExams: () {},
            onOpenGrades: () {},
            onOpenGroups: () {},
            onOpenProfile: () {
              wasCalled = true;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Perfil'));
    await tester.pump();

    expect(wasCalled, isTrue);
  });

  testWidgets('abre Exámenes desde la estadística Por realizar', (
    tester,
  ) async {
    var wasCalled = false;

    await buildHome(
      tester,
      onOpenExams: () {
        wasCalled = true;
      },
    );

    final statistic = find.byKey(const Key('pending-exams-statistic'));

    await tester.tap(statistic);
    await tester.pump();

    expect(wasCalled, isTrue);
  });

  testWidgets('abre Calificaciones desde la estadística Entregados', (
    tester,
  ) async {
    var wasCalled = false;

    await buildHome(
      tester,
      onOpenGrades: () {
        wasCalled = true;
      },
    );

    final statistic = find.byKey(const Key('completed-exams-statistic'));

    await tester.tap(statistic);
    await tester.pump();

    expect(wasCalled, isTrue);
  });

  testWidgets('abre Mis grupos desde la estadística correspondiente', (
    tester,
  ) async {
    var wasCalled = false;

    await buildHome(
      tester,
      onOpenGroups: () {
        wasCalled = true;
      },
    );

    final statistic = find.byKey(const Key('registered-groups-statistic'));

    await tester.tap(statistic);
    await tester.pump();

    expect(wasCalled, isTrue);
  });
}

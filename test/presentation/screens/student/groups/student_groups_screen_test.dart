import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_group_summary.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/groups/student_groups_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /*
   * Datos sintéticos utilizados exclusivamente durante las pruebas.
   *
   * No forman parte de la aplicación ni aparecen en la ejecución normal.
   */
  const groups = [
    StudentGroupSummary(
      id: 'group-1',
      name: 'Grupo A',
      subject: 'Matemáticas',
      period: '2026-B',
      status: StudentGroupStatus.active,
      teacherName: 'Docente de prueba',
    ),
    StudentGroupSummary(
      id: 'group-2',
      name: 'Grupo B',
      subject: 'Programación',
      period: '2026-A',
      status: StudentGroupStatus.completed,
    ),
  ];

  Future<void> buildScreen(
    WidgetTester tester, {
    List<StudentGroupSummary> groupList = const [],
    VoidCallback? onJoinGroup,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: Scaffold(
          body: StudentGroupsScreen(
            groups: groupList,
            onJoinGroup: onJoinGroup,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('muestra el estado vacío sin grupos', (tester) async {
    await buildScreen(tester);

    expect(find.text('Sin grupos asociados'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('muestra los grupos recibidos', (tester) async {
    await buildScreen(tester, groupList: groups);

    final firstGroup = find.text('Grupo A');

    await tester.dragUntilVisible(
      firstGroup,
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );

    expect(firstGroup, findsOneWidget);
    expect(find.text('Matemáticas'), findsOneWidget);

    final secondGroup = find.text('Grupo B');

    await tester.dragUntilVisible(
      secondGroup,
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );

    expect(secondGroup, findsOneWidget);
    expect(find.text('Programación'), findsOneWidget);
  });

  testWidgets('filtra grupos mediante la búsqueda', (tester) async {
    await buildScreen(tester, groupList: groups);

    await tester.enterText(find.byType(TextField), 'Programación');
    await tester.pumpAndSettle();

    expect(find.text('Grupo A'), findsNothing);

    final matchedGroup = find.text('Grupo B');

    await tester.dragUntilVisible(
      matchedGroup,
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );

    expect(matchedGroup, findsOneWidget);
  });

  testWidgets('muestra un estado sin resultados', (tester) async {
    await buildScreen(tester, groupList: groups);

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

  testWidgets('ejecuta la solicitud para unirse a un grupo', (tester) async {
    var wasCalled = false;

    await buildScreen(
      tester,
      onJoinGroup: () {
        wasCalled = true;
      },
    );

    await tester.tap(find.text('Unirse a un grupo'));
    await tester.pump();

    expect(wasCalled, isTrue);
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildScreen(tester, groupList: groups, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentGroupsScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Mis grupos'), findsOneWidget);
  });
}

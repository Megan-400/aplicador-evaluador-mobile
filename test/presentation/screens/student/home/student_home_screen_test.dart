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
          onOpenExams: onOpenExams ?? () {},
          onOpenGrades: onOpenGrades ?? () {},
          onOpenGroups: onOpenGroups ?? () {},
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('muestra el contenido principal de Inicio', (tester) async {
    await buildHome(tester);

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Portal del alumno'), findsOneWidget);
    expect(find.text('Accesos principales'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Próximos exámenes'),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );

    expect(find.text('Próximos exámenes'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('No hay próximos exámenes'),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );

    expect(find.text('No hay próximos exámenes'), findsOneWidget);
  });

  testWidgets('ejecuta el acceso a Exámenes', (tester) async {
    var wasCalled = false;

    await buildHome(
      tester,
      onOpenExams: () {
        wasCalled = true;
      },
    );

    await tester.tap(find.text('Exámenes'));
    await tester.pump();

    expect(wasCalled, isTrue);
  });

  testWidgets('ejecuta el acceso a Calificaciones', (tester) async {
    var wasCalled = false;

    await buildHome(
      tester,
      onOpenGrades: () {
        wasCalled = true;
      },
    );

    await tester.tap(find.text('Calificaciones'));
    await tester.pump();

    expect(wasCalled, isTrue);
  });

  testWidgets('ejecuta el acceso a Mis grupos', (tester) async {
    var wasCalled = false;

    await buildHome(
      tester,
      onOpenGroups: () {
        wasCalled = true;
      },
    );

    await tester.tap(find.text('Mis grupos'));
    await tester.pump();

    expect(wasCalled, isTrue);
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildHome(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentHomeScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Portal del alumno'), findsOneWidget);
  });
}

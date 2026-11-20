import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/profile/student_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures/student_dashboard_fixture.dart';

void main() {
  Future<void> buildScreen(
    WidgetTester tester, {
    required VoidCallback onSignOut,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: StudentProfileScreen(
          dashboard: emptyStudentDashboard,
          onSignOut: onSignOut,
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('muestra la información del alumno', (tester) async {
    await buildScreen(tester, onSignOut: () {});

    expect(find.text('Alumno de prueba'), findsOneWidget);
    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('ejecuta la solicitud de cierre', (tester) async {
    var wasCalled = false;

    await buildScreen(
      tester,
      onSignOut: () {
        wasCalled = true;
      },
    );

    await tester.tap(find.byKey(const Key('student-sign-out-button')));

    await tester.pump();

    expect(wasCalled, isTrue);
  });

  testWidgets('funciona con tema oscuro', (tester) async {
    await buildScreen(tester, themeMode: ThemeMode.dark, onSignOut: () {});

    final context = tester.element(find.byType(StudentProfileScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
  });
}

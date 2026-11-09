import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/presentation/navigation/student_app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> buildShell(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const StudentAppShell(),
      ),
    );

    await tester.pumpAndSettle();
  }

  Finder navigationDestination(String label) {
    return find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    );
  }

  testWidgets('muestra Inicio como destino inicial', (tester) async {
    await buildShell(tester);

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 0);
    expect(find.text('Portal del alumno'), findsOneWidget);
    expect(
      find.text('Consulta tus actividades y accesos principales.'),
      findsOneWidget,
    );
  });

  testWidgets('permite navegar a Exámenes', (tester) async {
    await buildShell(tester);

    await tester.tap(navigationDestination('Exámenes'));
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 1);
    expect(find.text('Sin exámenes cargados'), findsOneWidget);
  });

  testWidgets('permite navegar a Calificaciones', (tester) async {
    await buildShell(tester);

    await tester.tap(navigationDestination('Calificaciones'));
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 2);
    expect(find.text('Sin calificaciones disponibles'), findsOneWidget);
  });

  testWidgets('permite navegar a Mis grupos', (tester) async {
    await buildShell(tester);

    await tester.tap(navigationDestination('Mis grupos'));
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 3);
    expect(find.text('Sin grupos asociados'), findsOneWidget);
  });

  testWidgets('abre Exámenes desde el acceso rápido de Inicio', (tester) async {
    await buildShell(tester);

    final quickAccessText = find.text('Exámenes').first;
    final quickAccessCard = find.ancestor(
      of: quickAccessText,
      matching: find.byType(InkWell),
    );

    expect(quickAccessCard, findsOneWidget);

    await tester.tap(quickAccessCard);
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 1);
    expect(find.text('Sin exámenes cargados'), findsOneWidget);
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildShell(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentAppShell));
    final theme = Theme.of(context);

    expect(theme.brightness, Brightness.dark);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Portal del alumno'), findsOneWidget);
    expect(
      find.text('Consulta tus actividades y accesos principales.'),
      findsOneWidget,
    );
  });
}

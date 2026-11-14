import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/groups/join/join_group_code.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/groups/join/join_group_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> buildSheet(
    WidgetTester tester, {
    required JoinGroupSubmitCallback onSubmit,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: Scaffold(body: JoinGroupSheet(onSubmit: onSubmit)),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('muestra el formulario de código', (tester) async {
    await buildSheet(
      tester,
      onSubmit: (_) async {
        return const JoinGroupResult(
          status: JoinGroupResultStatus.success,
          message: 'Correcto.',
        );
      },
    );

    expect(find.text('Unirse a un grupo'), findsOneWidget);
    expect(find.text('Código del grupo'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets('mantiene Continuar desactivado con un código incompleto', (
    tester,
  ) async {
    await buildSheet(
      tester,
      onSubmit: (_) async {
        return const JoinGroupResult(
          status: JoinGroupResultStatus.success,
          message: 'Correcto.',
        );
      },
    );

    final fieldFinder = find.byKey(const Key('join-group-code-field'));
    final buttonFinder = find.byKey(const Key('join-group-submit-button'));

    var button = tester.widget<ElevatedButton>(buttonFinder);

    expect(button.onPressed, isNull);

    await tester.enterText(fieldFinder, 'ABC');
    await tester.pumpAndSettle();

    button = tester.widget<ElevatedButton>(buttonFinder);

    expect(button.onPressed, isNull);
    expect(find.text('Confirmar código'), findsNothing);
  });

  testWidgets('habilita Continuar cuando el código es válido', (tester) async {
    await buildSheet(
      tester,
      onSubmit: (_) async {
        return const JoinGroupResult(
          status: JoinGroupResultStatus.success,
          message: 'Correcto.',
        );
      },
    );

    final fieldFinder = find.byKey(const Key('join-group-code-field'));
    final buttonFinder = find.byKey(const Key('join-group-submit-button'));

    await tester.enterText(fieldFinder, 'abc123');
    await tester.pumpAndSettle();

    final textField = tester.widget<TextFormField>(fieldFinder);
    final button = tester.widget<ElevatedButton>(buttonFinder);

    expect(textField.controller?.text, 'ABC123');
    expect(button.onPressed, isNotNull);
  });

  testWidgets('normaliza el código antes del envío', (tester) async {
    String? submittedCode;

    await buildSheet(
      tester,
      onSubmit: (code) async {
        submittedCode = code;

        return const JoinGroupResult(
          status: JoinGroupResultStatus.success,
          message: 'Te uniste correctamente.',
        );
      },
    );

    final fieldFinder = find.byKey(const Key('join-group-code-field'));
    final buttonFinder = find.byKey(const Key('join-group-submit-button'));

    await tester.enterText(fieldFinder, 'abc123');
    await tester.pumpAndSettle();

    final textField = tester.widget<TextFormField>(fieldFinder);
    final button = tester.widget<ElevatedButton>(buttonFinder);

    expect(textField.controller?.text, 'ABC123');
    expect(button.onPressed, isNotNull);

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Confirmar código'), findsOneWidget);
    expect(
      find.text(
        '¿Deseas solicitar tu incorporación al grupo con el código '
        'ABC123?',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(submittedCode, 'ABC123');
    expect(find.text('Solicitud completada'), findsOneWidget);
    expect(find.text('Te uniste correctamente.'), findsOneWidget);
  });

  testWidgets('muestra un error devuelto por el servicio', (tester) async {
    await buildSheet(
      tester,
      onSubmit: (_) async {
        return const JoinGroupResult(
          status: JoinGroupResultStatus.invalidCode,
          message: 'El código no existe.',
        );
      },
    );

    final fieldFinder = find.byKey(const Key('join-group-code-field'));
    final buttonFinder = find.byKey(const Key('join-group-submit-button'));

    await tester.enterText(fieldFinder, 'XYZ789');
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(buttonFinder);

    expect(button.onPressed, isNotNull);

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Confirmar código'), findsOneWidget);

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('No fue posible unirse'), findsOneWidget);
    expect(find.text('El código no existe.'), findsOneWidget);
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildSheet(
      tester,
      themeMode: ThemeMode.dark,
      onSubmit: (_) async {
        return const JoinGroupResult(
          status: JoinGroupResultStatus.success,
          message: 'Correcto.',
        );
      },
    );

    final context = tester.element(find.byType(JoinGroupSheet));

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Unirse a un grupo'), findsOneWidget);
  });
}

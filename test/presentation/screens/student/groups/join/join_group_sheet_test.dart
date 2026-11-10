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

  testWidgets('muestra error con un código incompleto', (tester) async {
    await buildSheet(
      tester,
      onSubmit: (_) async {
        return const JoinGroupResult(
          status: JoinGroupResultStatus.success,
          message: 'Correcto.',
        );
      },
    );

    await tester.enterText(
      find.byKey(const Key('join-group-code-field')),
      'ABC',
    );
    await tester.tap(find.byKey(const Key('join-group-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('El código debe contener 6 caracteres.'), findsOneWidget);
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

    await tester.enterText(
      find.byKey(const Key('join-group-code-field')),
      'abc123',
    );
    await tester.tap(find.byKey(const Key('join-group-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar código'), findsOneWidget);

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(submittedCode, 'ABC123');
    expect(find.text('Solicitud completada'), findsOneWidget);
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

    await tester.enterText(
      find.byKey(const Key('join-group-code-field')),
      'XYZ789',
    );
    await tester.tap(find.byKey(const Key('join-group-submit-button')));
    await tester.pumpAndSettle();

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

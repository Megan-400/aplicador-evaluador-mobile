import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/design_system/design_system_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> buildPreview(
    WidgetTester tester, {
    required ThemeMode themeMode,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const DesignSystemPreviewScreen(),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('muestra la vista previa con el tema claro', (tester) async {
    await buildPreview(tester, themeMode: ThemeMode.light);

    expect(find.text('Sistema visual'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);

    final folioFinder = find.text('Folio');

    await tester.scrollUntilVisible(
      folioFinder,
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(folioFinder, findsOneWidget);
  });

  testWidgets('muestra la vista previa con el tema oscuro', (tester) async {
    await buildPreview(tester, themeMode: ThemeMode.dark);

    expect(find.text('Sistema visual'), findsOneWidget);
    expect(find.text('Acción secundaria'), findsOneWidget);

    final examFinder = find.text('Examen de Matemáticas');

    await tester.scrollUntilVisible(
      examFinder,
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(examFinder, findsOneWidget);
  });
}

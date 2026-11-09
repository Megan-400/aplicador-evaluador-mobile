import 'package:aplicador_evaluador_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inicia la aplicación con el sistema visual', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Sistema visual'), findsOneWidget);
    expect(find.text('Aplicador/Evaluador'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });
}

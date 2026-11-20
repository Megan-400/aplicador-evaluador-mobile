import 'package:aplicador_evaluador_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inicia en el acceso del alumno', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Portal del estudiante'), findsOneWidget);
    expect(find.text('Bienvenido a BigBitByte'), findsOneWidget);
    expect(find.text('Folio del grupo'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });
}

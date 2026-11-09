import 'package:aplicador_evaluador_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inicia la aplicación en el portal del alumno', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsWidgets);
    expect(
      find.text('Consulta tus actividades y accesos recientes.'),
      findsOneWidget,
    );
    expect(find.text('Exámenes'), findsOneWidget);
    expect(find.text('Calificaciones'), findsOneWidget);
    expect(find.text('Mis grupos'), findsOneWidget);
  });
}

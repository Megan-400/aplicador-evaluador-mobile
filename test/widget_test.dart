import 'package:aplicador_evaluador_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inicia la aplicación en el portal del alumno', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsWidgets);
    expect(
      find.text('Consulta tus actividades y accesos principales.'),
      findsOneWidget,
    );
    expect(find.text('Exámenes'), findsNWidgets(2));
    expect(find.text('Calificaciones'), findsNWidgets(2));
    expect(find.text('Mis grupos'), findsNWidgets(2));
  });
}

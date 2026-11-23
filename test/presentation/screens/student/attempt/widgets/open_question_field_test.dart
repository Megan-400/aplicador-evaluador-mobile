import 'package:aplicador_evaluador_mobile/presentation/screens/student/attempt/widgets/open_question_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra y actualiza una respuesta abierta', (tester) async {
    String? answer;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OpenQuestionField(
            questionId: 1,
            initialAnswer: 'Respuesta inicial.',
            onChanged: (value) {
              answer = value;
            },
          ),
        ),
      ),
    );

    expect(find.text('Respuesta inicial.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('open-answer-1')),
      'Nueva respuesta.',
    );

    expect(answer, 'Nueva respuesta.');
  });

  testWidgets('actualiza el campo al cambiar de pregunta', (tester) async {
    late StateSetter rebuild;

    var questionId = 1;
    var answer = 'Primera respuesta.';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;

              return OpenQuestionField(
                questionId: questionId,
                initialAnswer: answer,
                onChanged: (_) {},
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Primera respuesta.'), findsOneWidget);

    rebuild(() {
      questionId = 2;
      answer = 'Segunda respuesta.';
    });

    await tester.pump();

    expect(find.text('Segunda respuesta.'), findsOneWidget);
  });
}

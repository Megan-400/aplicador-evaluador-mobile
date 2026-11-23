import 'package:aplicador_evaluador_mobile/presentation/screens/student/attempt/widgets/programming_question_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra y actualiza una respuesta de programación', (
    tester,
  ) async {
    String? answer;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgrammingQuestionField(
            questionId: 4,
            initialAnswer: 'print("Respuesta inicial");',
            onChanged: (value) {
              answer = value;
            },
          ),
        ),
      ),
    );

    expect(find.text('print("Respuesta inicial");'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('programming-answer-4')),
      'print("México");\n'
      '// Código actualizado',
    );

    expect(
      answer,
      'print("México");\n'
      '// Código actualizado',
    );
  });

  testWidgets('restaura el código al cambiar de pregunta', (tester) async {
    late StateSetter rebuild;

    var questionId = 4;
    var answer = 'print("Primera");';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;

              return ProgrammingQuestionField(
                questionId: questionId,
                initialAnswer: answer,
                onChanged: (_) {},
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('print("Primera");'), findsOneWidget);

    rebuild(() {
      questionId = 5;
      answer = 'print("Segunda");';
    });

    await tester.pump();

    expect(find.text('print("Segunda");'), findsOneWidget);
  });

  testWidgets('preserva saltos de línea y caracteres Unicode', (tester) async {
    const sourceCode =
        'print("México");\n'
        '// Código con acentos: áéíóú';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgrammingQuestionField(
            questionId: 4,
            initialAnswer: sourceCode,
            onChanged: _ignoreAnswer,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(
      find.byKey(const ValueKey<String>('programming-answer-4')),
    );

    expect(textField.controller?.text, sourceCode);
    expect(textField.autocorrect, isFalse);
    expect(textField.enableSuggestions, isFalse);
  });

  testWidgets('no permite escribir cuando está deshabilitado', (tester) async {
    var wasCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgrammingQuestionField(
            questionId: 4,
            initialAnswer: 'Código existente',
            enabled: false,
            onChanged: (_) {
              wasCalled = true;
            },
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(
      find.byKey(const ValueKey<String>('programming-answer-4')),
    );

    expect(field.enabled, isFalse);
    expect(wasCalled, isFalse);
  });
}

void _ignoreAnswer(String value) {}

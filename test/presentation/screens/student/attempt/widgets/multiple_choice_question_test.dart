import 'package:aplicador_evaluador_mobile/presentation/screens/student/attempt/widgets/multiple_choice_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra y selecciona una opción', (tester) async {
    String? selectedAnswer;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultipleChoiceQuestion(
            questionId: 2,
            options: const ['Primera opción', 'Segunda opción'],
            selectedAnswer: '',
            onChanged: (value) {
              selectedAnswer = value;
            },
          ),
        ),
      ),
    );

    expect(find.text('Primera opción'), findsOneWidget);
    expect(find.text('Segunda opción'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('choice-2-1')));

    expect(selectedAnswer, 'Segunda opción');
  });

  testWidgets('no permite seleccionar cuando está deshabilitado', (
    tester,
  ) async {
    var wasCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultipleChoiceQuestion(
            questionId: 2,
            options: const ['Primera opción'],
            selectedAnswer: '',
            enabled: false,
            onChanged: (_) {
              wasCalled = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('choice-2-0')));

    expect(wasCalled, isFalse);
  });
}

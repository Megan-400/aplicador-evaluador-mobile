import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_question_option.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/attempt/widgets/multiple_choice_question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const options = [
    StudentQuestionOption(value: 'A', label: 'Primera opción'),
    StudentQuestionOption(value: 'B', label: 'Segunda opción'),
  ];

  testWidgets('muestra las claves y etiquetas de las opciones', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultipleChoiceQuestion(
            questionId: 2,
            options: options,
            selectedAnswer: '',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('Primera opción'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('Segunda opción'), findsOneWidget);
  });

  testWidgets('comunica el valor estable de la opción seleccionada', (
    tester,
  ) async {
    String? selectedAnswer;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultipleChoiceQuestion(
            questionId: 2,
            options: options,
            selectedAnswer: '',
            onChanged: (value) {
              selectedAnswer = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('choice-2-1')));

    expect(selectedAnswer, 'Segunda opción');
    expect(selectedAnswer, isNot('B'));
  });

  testWidgets('restaura visualmente una respuesta recibida como clave', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultipleChoiceQuestion(
            questionId: 2,
            options: options,
            selectedAnswer: 'Segunda opción',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final radioGroup = tester.widget<RadioGroup<String>>(
      find.byType(RadioGroup<String>),
    );

    expect(radioGroup.groupValue, 'Segunda opción');

    final radios = tester.widgetList<Radio<String>>(find.byType(Radio<String>));

    expect(radios.map((radio) => radio.value), [
      'Primera opción',
      'Segunda opción',
    ]);
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
            options: options,
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

  testWidgets('muestra un mensaje cuando no existen opciones', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultipleChoiceQuestion(
            questionId: 2,
            options: const [],
            selectedAnswer: '',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.text('Esta pregunta no contiene opciones disponibles.'),
      findsOneWidget,
    );
  });

  testWidgets('muestra una respuesta antigua guardada como clave', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MultipleChoiceQuestion(
            questionId: 2,
            options: options,
            selectedAnswer: 'B',
            onChanged: _ignoreAnswer,
          ),
        ),
      ),
    );

    final radioGroup = tester.widget<RadioGroup<String>>(
      find.byType(RadioGroup<String>),
    );

    expect(radioGroup.groupValue, 'Segunda opción');
  });
}

void _ignoreAnswer(String value) {}

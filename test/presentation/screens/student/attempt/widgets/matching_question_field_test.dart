import 'dart:convert';

import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_matching_pair.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/attempt/widgets/matching_question_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pairs = [
    StudentMatchingPair(left: 'a | b', right: 'Operador OR'),
    StudentMatchingPair(left: 'a & b', right: 'Operador AND'),
  ];

  testWidgets('muestra los elementos de ambas relaciones', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MatchingQuestionField(
            questionId: 3,
            pairs: pairs,
            initialAnswer: '',
            onChanged: _ignoreAnswer,
          ),
        ),
      ),
    );

    expect(find.text('a | b'), findsOneWidget);
    expect(find.text('a & b'), findsOneWidget);
  });

  testWidgets('actualiza una relación seleccionada', (tester) async {
    String? answer;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MatchingQuestionField(
            questionId: 3,
            pairs: pairs,
            initialAnswer: '',
            onChanged: (value) {
              answer = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('matching-3-0')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Operador OR').last);
    await tester.pumpAndSettle();

    final decoded = jsonDecode(answer!) as Map;

    expect(decoded['a | b'], 'Operador OR');
  });

  testWidgets('restaura las relaciones iniciales', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MatchingQuestionField(
            questionId: 3,
            pairs: pairs,
            initialAnswer: '{"a | b":"Operador OR"}',
            onChanged: _ignoreAnswer,
          ),
        ),
      ),
    );

    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byKey(const ValueKey<String>('matching-3-0')),
    );

    expect(dropdown.initialValue, 'Operador OR');
  });
}

void _ignoreAnswer(String value) {}

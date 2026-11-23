import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_exam_question.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_matching_pair.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_question_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentExamQuestion', () {
    test('representa una pregunta abierta', () {
      const question = StudentExamQuestion(
        id: 1,
        sectionId: 10,
        type: StudentQuestionType.open,
        prompt: 'Define qué es una variable.',
        timeSeconds: 60,
      );

      expect(question.id, 1);
      expect(question.sectionId, 10);
      expect(question.prompt, 'Define qué es una variable.');
      expect(question.isOpen, isTrue);
      expect(question.isMultipleChoice, isFalse);
      expect(question.isMatching, isFalse);
      expect(question.isProgramming, isFalse);
      expect(question.options, isEmpty);
      expect(question.matchingPairs, isEmpty);
      expect(question.timeMinutes, 1);
    });

    test('representa una pregunta de opción múltiple', () {
      const question = StudentExamQuestion(
        id: 2,
        sectionId: 10,
        type: StudentQuestionType.multipleChoice,
        prompt: '¿Cuál es la definición de variable?',
        timeSeconds: 90,
        options: [
          'Un valor que puede cambiar',
          'Un ciclo de repetición',
          'Una condición lógica',
        ],
      );

      expect(question.isOpen, isFalse);
      expect(question.isMultipleChoice, isTrue);
      expect(question.isMatching, isFalse);
      expect(question.isProgramming, isFalse);
      expect(question.options, hasLength(3));
      expect(question.options.first, 'Un valor que puede cambiar');
      expect(question.matchingPairs, isEmpty);
      expect(question.timeMinutes, 2);
    });

    test('representa una pregunta de relación de columnas', () {
      const question = StudentExamQuestion(
        id: 3,
        sectionId: 11,
        type: StudentQuestionType.matching,
        prompt: 'Relaciona cada expresión con su operador.',
        timeSeconds: 120,
        matchingPairs: [
          StudentMatchingPair(left: 'a | b', right: 'Operador OR'),
          StudentMatchingPair(left: 'a & b', right: 'Operador AND'),
        ],
      );

      expect(question.isOpen, isFalse);
      expect(question.isMultipleChoice, isFalse);
      expect(question.isMatching, isTrue);
      expect(question.isProgramming, isFalse);
      expect(question.options, isEmpty);
      expect(question.matchingPairs, hasLength(2));
      expect(question.matchingPairs.first.left, 'a | b');
      expect(question.matchingPairs.first.right, 'Operador OR');
      expect(question.timeMinutes, 2);
    });

    test('representa una pregunta de programación', () {
      const question = StudentExamQuestion(
        id: 4,
        sectionId: 12,
        type: StudentQuestionType.programming,
        prompt: 'Escribe un programa que imprima Hola.',
        timeSeconds: 300,
      );

      expect(question.isOpen, isFalse);
      expect(question.isMultipleChoice, isFalse);
      expect(question.isMatching, isFalse);
      expect(question.isProgramming, isTrue);
      expect(question.options, isEmpty);
      expect(question.matchingPairs, isEmpty);
      expect(question.timeMinutes, 5);
    });

    test('redondea los segundos a minutos hacia arriba', () {
      const question = StudentExamQuestion(
        id: 4,
        sectionId: 11,
        type: StudentQuestionType.open,
        prompt: 'Explica el resultado.',
        timeSeconds: 121,
      );

      expect(question.timeMinutes, 3);
    });

    test('devuelve cero minutos cuando el tiempo no es positivo', () {
      const zeroTimeQuestion = StudentExamQuestion(
        id: 5,
        sectionId: 12,
        type: StudentQuestionType.open,
        prompt: 'Pregunta sin tiempo.',
        timeSeconds: 0,
      );

      const negativeTimeQuestion = StudentExamQuestion(
        id: 6,
        sectionId: 12,
        type: StudentQuestionType.open,
        prompt: 'Pregunta con tiempo inválido.',
        timeSeconds: -1,
      );

      expect(zeroTimeQuestion.timeMinutes, 0);
      expect(negativeTimeQuestion.timeMinutes, 0);
    });
  });

  group('StudentMatchingPair', () {
    test('conserva los elementos izquierdo y derecho', () {
      const pair = StudentMatchingPair(
        left: 'a == b',
        right: 'Comparación de igualdad',
      );

      expect(pair.left, 'a == b');
      expect(pair.right, 'Comparación de igualdad');
    });
  });
}

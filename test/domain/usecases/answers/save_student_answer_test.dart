import 'package:aplicador_evaluador_mobile/domain/entities/answers/student_saved_answer.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/answers/student_answer_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/answers/save_student_answer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaveStudentAnswer', () {
    test('normaliza el token y conserva la respuesta', () async {
      final repository = _FakeAnswerRepository();

      final useCase = SaveStudentAnswer(repository: repository);

      const sourceCode =
          '  print("México");\n'
          '  // Código con espacios  ';

      final result = await useCase(
        sessionToken: '  token-sintetico  ',
        questionId: 25,
        answer: sourceCode,
      );

      expect(result.id, 123);
      expect(repository.receivedToken, 'token-sintetico');
      expect(repository.receivedQuestionId, 25);
      expect(repository.receivedAnswer, sourceCode);
    });

    test('rechaza una respuesta vacía', () {
      final useCase = SaveStudentAnswer(repository: _FakeAnswerRepository());

      expect(
        () => useCase(
          sessionToken: 'token-sintetico',
          questionId: 25,
          answer: '   ',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza más de 20,000 caracteres', () {
      final useCase = SaveStudentAnswer(repository: _FakeAnswerRepository());

      expect(
        () => useCase(
          sessionToken: 'token-sintetico',
          questionId: 25,
          answer: 'a' * 20001,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

class _FakeAnswerRepository implements StudentAnswerRepository {
  String? receivedToken;
  int? receivedQuestionId;
  String? receivedAnswer;

  @override
  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) async {
    receivedToken = sessionToken;
    receivedQuestionId = questionId;
    receivedAnswer = answer;

    return StudentSavedAnswer(id: 123, questionId: questionId);
  }
}

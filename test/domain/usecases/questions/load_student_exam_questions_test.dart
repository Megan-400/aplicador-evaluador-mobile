import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_exam_question.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_exam_questions.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/questions/student_question_type.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/questions/student_exam_questions_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/questions/load_student_exam_questions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoadStudentExamQuestions', () {
    test('normaliza el token y consulta el repositorio', () async {
      final repository = _FakeQuestionsRepository();

      final useCase = LoadStudentExamQuestions(repository: repository);

      final result = await useCase(sessionToken: '  token-sintetico  ');

      expect(result.examName, 'Examen de prueba');
      expect(result.questions, hasLength(1));
      expect(result.savedAnswers, isEmpty);
      expect(repository.receivedToken, 'token-sintetico');
    });

    test('rechaza un token vacío', () async {
      final repository = _FakeQuestionsRepository();

      final useCase = LoadStudentExamQuestions(repository: repository);

      expect(
        () => useCase(sessionToken: '   '),
        throwsA(isA<FormatException>()),
      );

      expect(repository.callCount, 0);
    });
  });
}

class _FakeQuestionsRepository implements StudentExamQuestionsRepository {
  String? receivedToken;
  int callCount = 0;

  @override
  Future<StudentExamQuestions> load({required String sessionToken}) async {
    callCount++;
    receivedToken = sessionToken;

    return const StudentExamQuestions(
      examName: 'Examen de prueba',
      questions: [
        StudentExamQuestion(
          id: 1,
          sectionId: 10,
          type: StudentQuestionType.open,
          prompt: 'Pregunta sintética.',
          timeSeconds: 60,
        ),
      ],
      savedAnswers: {},
    );
  }
}

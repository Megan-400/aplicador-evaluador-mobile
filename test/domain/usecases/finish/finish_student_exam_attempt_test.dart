import 'package:aplicador_evaluador_mobile/domain/entities/finish/student_finished_attempt.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/finish/student_finish_attempt_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/finish/finish_student_exam_attempt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinishStudentExamAttempt', () {
    test('normaliza el token y consulta el repositorio', () async {
      final repository = _FakeFinishRepository();

      final useCase = FinishStudentExamAttempt(repository: repository);

      final result = await useCase(sessionToken: '  token-sintetico  ');

      expect(result.id, 123);
      expect(result.isFinished, isTrue);
      expect(repository.receivedToken, 'token-sintetico');
      expect(repository.callCount, 1);
    });

    test('rechaza un token vacío', () {
      final repository = _FakeFinishRepository();

      final useCase = FinishStudentExamAttempt(repository: repository);

      expect(
        () => useCase(sessionToken: '   '),
        throwsA(isA<FormatException>()),
      );

      expect(repository.callCount, 0);
    });
  });
}

class _FakeFinishRepository implements StudentFinishAttemptRepository {
  String? receivedToken;
  int callCount = 0;

  @override
  Future<StudentFinishedAttempt> finish({required String sessionToken}) async {
    callCount++;
    receivedToken = sessionToken;

    return StudentFinishedAttempt(
      id: 123,
      status: 'finalizado',
      submittedAt: DateTime.parse('2026-11-23T18:30:00-06:00'),
    );
  }
}

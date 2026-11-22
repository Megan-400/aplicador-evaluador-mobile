import '../../entities/attempts/student_exam_attempt.dart';

abstract interface class StudentExamAttemptRepository {
  Future<StudentExamAttempt> start({
    required String grant,
  });
}
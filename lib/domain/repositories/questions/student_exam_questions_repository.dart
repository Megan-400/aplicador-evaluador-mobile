import '../../entities/questions/student_exam_questions.dart';

/// Contrato para consultar las preguntas de un intento.
abstract interface class StudentExamQuestionsRepository {
  Future<StudentExamQuestions> load({required String sessionToken});
}

import '../../entities/enrollment/student_enrollment.dart';

/// Contrato para crear e inscribir un perfil de alumno.
abstract interface class StudentEnrollmentRepository {
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  });
}

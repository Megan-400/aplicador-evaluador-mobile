import '../../entities/enrollment/student_enrollment.dart';
import '../../repositories/enrollment/student_enrollment_repository.dart';

/// Valida y solicita la creación de un perfil de alumno.
class CreateStudentEnrollment {
  const CreateStudentEnrollment({required this.repository});

  static final RegExp _folioPattern = RegExp(r'^[A-Z0-9]{4,20}$');

  static const int minimumNameLength = 2;
  static const int maximumNameLength = 150;

  final StudentEnrollmentRepository repository;

  Future<StudentEnrollment> call({
    required String groupFolio,
    required String studentName,
  }) {
    final normalizedFolio = groupFolio.trim().toUpperCase();

    final normalizedName = studentName.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (!_folioPattern.hasMatch(normalizedFolio)) {
      throw const FormatException(
        'El folio debe contener entre 4 y 20 '
        'letras o números.',
      );
    }

    if (normalizedName.length < minimumNameLength) {
      throw const FormatException('Escribe tu nombre completo.');
    }

    if (normalizedName.length > maximumNameLength) {
      throw const FormatException(
        'El nombre no puede superar '
        '150 caracteres.',
      );
    }

    return repository.create(
      groupFolio: normalizedFolio,
      studentName: normalizedName,
    );
  }
}

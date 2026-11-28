/// Perfil creado e inscrito en un grupo.
/// [accessCode] contiene una credencial que el backend presenta
/// únicamente durante el alta inicial.
class StudentEnrollment {
  const StudentEnrollment({
    required this.studentId,
    required this.groupId,
    required this.subject,
    required this.studentName,
    required this.status,
    required this.mode,
    required this.credentialVersion,
    required this.accessCode,
  });

  final int studentId;
  final int groupId;
  final String subject;
  final String studentName;
  final String status;
  final String mode;
  final int credentialVersion;

  /// Código personal generado por el backend.
  /// No debe persistirse, imprimirse ni enviarse a analíticas.
  final String accessCode;

  bool get isNewEnrollment {
    return mode == 'nuevo';
  }

  bool get isEnrolled {
    return status == 'inscrito';
  }
}

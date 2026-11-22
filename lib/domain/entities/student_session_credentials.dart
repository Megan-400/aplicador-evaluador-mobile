/// Credenciales mantenidas únicamente durante la sesión local.
/// No deben persistirse, registrarse ni mostrarse en la interfaz.
class StudentSessionCredentials {
  const StudentSessionCredentials({
    required this.folio,
    required this.accessCode,
  });

  final String folio;
  final String accessCode;
}

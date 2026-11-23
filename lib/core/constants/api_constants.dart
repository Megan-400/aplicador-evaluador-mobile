/// Rutas y URL base de la API REST del backend.
class ApiConstants {
  static const baseUrl = 'https://bigbitbyte-staging-api.onrender.com/api/v1';

  static const login = '/auth/login';
  static const grupos = '/teacher/groups';
  static const examenes = '/teacher/exams';

  /// Alumnos inscritos en un grupo.
  static String alumnosDeGrupo(int grupoId) {
    return '/teacher/groups/$grupoId/students';
  }

  /// Resultados por intento de un examen.
  static String resultadosDeExamen(int examenId) {
    return '/teacher/exams/$examenId/results';
  }
}
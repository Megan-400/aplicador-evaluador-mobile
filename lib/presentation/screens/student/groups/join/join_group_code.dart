/// Reglas provisionales para validar un código de grupo.
///
/// Estas reglas deberán sincronizarse con el contrato definitivo de la API.
abstract final class JoinGroupCode {
  static const int requiredLength = 6;

  static final RegExp _validPattern = RegExp(r'^[A-Z0-9]{6}$');

  /// Normaliza el valor capturado por el alumno.
  static String normalize(String value) {
    return value.trim().replaceAll(' ', '').toUpperCase();
  }

  /// Devuelve un mensaje cuando el código no cumple el formato esperado.
  static String? validate(String? value) {
    final normalized = normalize(value ?? '');

    if (normalized.isEmpty) {
      return 'Ingresa el código del grupo.';
    }

    if (normalized.length != requiredLength) {
      return 'El código debe contener $requiredLength caracteres.';
    }

    if (!_validPattern.hasMatch(normalized)) {
      return 'El código solo puede contener letras y números.';
    }

    return null;
  }

  /// Indica si el código tiene el formato local válido.
  static bool isValid(String value) {
    return validate(value) == null;
  }
}

/// Resultado devuelto al intentar unirse a un grupo.
enum JoinGroupResultStatus {
  success,
  invalidCode,
  alreadyMember,
  expiredCode,
  connectionError,
}

/// Resultado del intento de unión.
class JoinGroupResult {
  const JoinGroupResult({
    required this.status,
    required this.message,
    this.groupName,
  });

  final JoinGroupResultStatus status;
  final String message;
  final String? groupName;

  bool get isSuccess => status == JoinGroupResultStatus.success;
}

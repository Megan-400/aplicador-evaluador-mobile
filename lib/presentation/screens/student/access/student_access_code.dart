abstract final class StudentAccessCode {
  static final RegExp _folioPattern = RegExp(r'^[A-Z0-9]{4,20}$');

  static final RegExp _accessCodePattern = RegExp(r'^[A-Z]{4}[0-9]{2}$');

  static String normalize(String value) {
    return value.trim().replaceAll(' ', '').toUpperCase();
  }

  static String? validateFolio(String? value) {
    final normalized = normalize(value ?? '');

    if (normalized.isEmpty) {
      return 'Ingresa el folio del grupo.';
    }

    if (!_folioPattern.hasMatch(normalized)) {
      return 'El folio debe contener entre 4 y 20 letras o números.';
    }

    return null;
  }

  static String? validateAccessCode(String? value) {
    final normalized = normalize(value ?? '');

    if (normalized.isEmpty) {
      return 'Ingresa tu código personal.';
    }

    if (!_accessCodePattern.hasMatch(normalized)) {
      return 'El código debe contener cuatro letras y dos números.';
    }

    return null;
  }
}

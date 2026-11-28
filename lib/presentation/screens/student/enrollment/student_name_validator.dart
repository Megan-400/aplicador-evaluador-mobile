abstract final class StudentNameValidator {
  static const int minimumLength = 2;
  static const int maximumLength = 150;

  /// Letras latinas básicas y extendidas.
  /// También permite marcas Unicode combinadas usadas en algunos
  /// caracteres acentuados.
  static final RegExp _allowedCharacters = RegExp(
    r"^[A-Za-z"
    r"\u00C0-\u00D6"
    r"\u00D8-\u00F6"
    r"\u00F8-\u024F"
    r"\u0300-\u036F"
    r" '\u2019-]+$",
    unicode: true,
  );

  static final RegExp _containsLetter = RegExp(
    r"[A-Za-z"
    r"\u00C0-\u00D6"
    r"\u00D8-\u00F6"
    r"\u00F8-\u024F"
    r"\u0300-\u036F]",
    unicode: true,
  );

  static final RegExp _nameComponent = RegExp(
    r"^[A-Za-z"
    r"\u00C0-\u00D6"
    r"\u00D8-\u00F6"
    r"\u00F8-\u024F"
    r"\u0300-\u036F]+"
    r"(?:['\u2019-]"
    r"[A-Za-z"
    r"\u00C0-\u00D6"
    r"\u00D8-\u00F6"
    r"\u00F8-\u024F"
    r"\u0300-\u036F]+)*$",
    unicode: true,
  );

  static String normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String? validate(String? value) {
    final normalized = normalize(value ?? '');

    if (normalized.isEmpty) {
      return 'Escribe tu nombre completo.';
    }

    if (normalized.length < minimumLength) {
      return 'El nombre es demasiado corto.';
    }

    if (normalized.length > maximumLength) {
      return 'El nombre no puede superar 150 caracteres.';
    }

    if (!_containsLetter.hasMatch(normalized)) {
      return 'El nombre debe contener letras.';
    }

    if (!_allowedCharacters.hasMatch(normalized)) {
      return 'El nombre solo puede contener letras, espacios, '
          'guiones y apóstrofos.';
    }

    final components = normalized.split(' ');

    if (components.length < 2) {
      return 'Escribe al menos un nombre y un apellido.';
    }

    final invalidComponent = components.any(
      (component) => !_nameComponent.hasMatch(component),
    );

    if (invalidComponent) {
      return 'Revisa la escritura del nombre completo.';
    }

    return null;
  }
}

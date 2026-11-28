import 'package:flutter/services.dart';

/// Permite letras latinas, espacios, guiones y apóstrofos.
/// No modifica automáticamente mayúsculas o minúsculas.
class StudentNameInputFormatter extends TextInputFormatter {
  static final RegExp _allowedCharacters = RegExp(
    r"^[A-Za-z"
    r"\u00C0-\u00D6"
    r"\u00D8-\u00F6"
    r"\u00F8-\u024F"
    r"\u0300-\u036F"
    r" '\u2019-]*$",
    unicode: true,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_allowedCharacters.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}

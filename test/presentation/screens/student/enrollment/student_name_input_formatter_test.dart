import 'package:aplicador_evaluador_mobile/presentation/screens/student/enrollment/student_name_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentNameInputFormatter', () {
    test('acepta letras, espacios y acentos', () {
      final formatter = StudentNameInputFormatter();

      const oldValue = TextEditingValue(text: '');

      const newValue = TextEditingValue(text: 'Ana María Pérez');

      expect(formatter.formatEditUpdate(oldValue, newValue), newValue);
    });

    test('acepta guiones y apóstrofos', () {
      final formatter = StudentNameInputFormatter();

      const oldValue = TextEditingValue(text: '');

      const newValue = TextEditingValue(text: "María-José D'Angelo");

      expect(formatter.formatEditUpdate(oldValue, newValue), newValue);
    });

    test('rechaza números conservando el valor anterior', () {
      final formatter = StudentNameInputFormatter();

      const oldValue = TextEditingValue(text: 'Ana Pérez');

      const newValue = TextEditingValue(text: 'Ana Pérez1');

      expect(formatter.formatEditUpdate(oldValue, newValue), oldValue);
    });

    test('rechaza símbolos', () {
      final formatter = StudentNameInputFormatter();

      const oldValue = TextEditingValue(text: 'Ana Pérez');

      const newValue = TextEditingValue(text: 'Ana Pérez@');

      expect(formatter.formatEditUpdate(oldValue, newValue), oldValue);
    });
  });
}

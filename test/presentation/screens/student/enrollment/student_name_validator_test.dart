import 'package:aplicador_evaluador_mobile/presentation/screens/student/enrollment/student_name_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentNameValidator', () {
    test('acepta nombre y apellido', () {
      expect(StudentNameValidator.validate('Ana Pérez'), isNull);
    });

    test('acepta nombre y dos apellidos', () {
      expect(StudentNameValidator.validate('Ana Pérez López'), isNull);
    });

    test('acepta nombres compuestos', () {
      expect(StudentNameValidator.validate('Ana María Pérez López'), isNull);
    });

    test('acepta partículas del apellido', () {
      expect(StudentNameValidator.validate('José Luis de la Cruz'), isNull);
    });

    test('acepta acentos y diéresis', () {
      expect(StudentNameValidator.validate('María Núñez Güemes'), isNull);
    });

    test('acepta guiones', () {
      expect(StudentNameValidator.validate('María-José Pérez'), isNull);
    });

    test('acepta apóstrofos', () {
      expect(StudentNameValidator.validate("D'Angelo Ramírez"), isNull);

      expect(StudentNameValidator.validate('D’Angelo Ramírez'), isNull);
    });

    test('normaliza espacios exteriores e interiores', () {
      expect(
        StudentNameValidator.normalize('  Ana   María   Pérez  '),
        'Ana María Pérez',
      );
    });

    test('rechaza un solo componente', () {
      expect(
        StudentNameValidator.validate('Ana'),
        'Escribe al menos un nombre y un apellido.',
      );
    });

    test('rechaza números', () {
      expect(
        StudentNameValidator.validate('Ana Pérez 123'),
        contains('solo puede contener'),
      );
    });

    test('rechaza símbolos y emojis', () {
      expect(
        StudentNameValidator.validate('Ana Pérez 🙂'),
        contains('solo puede contener'),
      );

      expect(
        StudentNameValidator.validate('Ana @ Pérez'),
        contains('solo puede contener'),
      );
    });

    test('rechaza guiones aislados', () {
      expect(
        StudentNameValidator.validate('Ana - Pérez'),
        'Revisa la escritura del nombre completo.',
      );
    });

    test('rechaza apóstrofos aislados', () {
      expect(
        StudentNameValidator.validate("Ana ' Pérez"),
        'Revisa la escritura del nombre completo.',
      );
    });

    test('rechaza más de 150 caracteres', () {
      expect(
        StudentNameValidator.validate('${'Ana ' * 38}Pérez'),
        'El nombre no puede superar 150 caracteres.',
      );
    });
  });
}

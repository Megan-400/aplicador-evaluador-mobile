import 'package:aplicador_evaluador_mobile/presentation/screens/student/groups/join/join_group_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JoinGroupCode', () {
    test('normaliza espacios y minúsculas', () {
      expect(JoinGroupCode.normalize(' ab c123 '), 'ABC123');
    });

    test('rechaza un código vacío', () {
      expect(JoinGroupCode.validate(''), 'Ingresa el código del grupo.');
    });

    test('rechaza una longitud diferente de seis', () {
      expect(
        JoinGroupCode.validate('ABC12'),
        'El código debe contener 6 caracteres.',
      );
    });

    test('rechaza caracteres no alfanuméricos', () {
      expect(
        JoinGroupCode.validate('ABC12-'),
        'El código solo puede contener letras y números.',
      );
    });

    test('acepta un código alfanumérico de seis caracteres', () {
      expect(JoinGroupCode.validate('ABC123'), isNull);
      expect(JoinGroupCode.isValid('ABC123'), isTrue);
    });
  });
}

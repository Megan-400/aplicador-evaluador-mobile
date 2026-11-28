import 'package:aplicador_evaluador_mobile/domain/entities/enrollment/student_enrollment.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/enrollment/student_enrollment_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/enrollment/create_student_enrollment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateStudentEnrollment', () {
    test('normaliza el folio y los espacios del nombre', () async {
      final repository = _FakeEnrollmentRepository();

      final useCase = CreateStudentEnrollment(repository: repository);

      final result = await useCase(
        groupFolio: ' grupo1 ',
        studentName: '  Ana   María   Pérez  ',
      );

      expect(repository.receivedFolio, 'GRUPO1');

      expect(repository.receivedName, 'Ana María Pérez');

      expect(result.accessCode, 'ABCD27');
      expect(repository.callCount, 1);
    });

    test('acepta acentos y guiones', () async {
      final repository = _FakeEnrollmentRepository();

      final useCase = CreateStudentEnrollment(repository: repository);

      await useCase(groupFolio: 'GRUPO1', studentName: 'María-José Núñez');

      expect(repository.receivedName, 'María-José Núñez');
    });

    test('rechaza un folio vacío', () {
      final repository = _FakeEnrollmentRepository();

      final useCase = CreateStudentEnrollment(repository: repository);

      expect(
        () => useCase(groupFolio: ' ', studentName: 'Ana Pérez'),
        throwsA(isA<FormatException>()),
      );

      expect(repository.callCount, 0);
    });

    test('rechaza caracteres inválidos en el folio', () {
      final repository = _FakeEnrollmentRepository();

      final useCase = CreateStudentEnrollment(repository: repository);

      expect(
        () => useCase(groupFolio: 'GRUPO-1', studentName: 'Ana Pérez'),
        throwsA(isA<FormatException>()),
      );

      expect(repository.callCount, 0);
    });

    test('rechaza un nombre con menos de 2 caracteres', () {
      final repository = _FakeEnrollmentRepository();

      final useCase = CreateStudentEnrollment(repository: repository);

      expect(
        () => useCase(groupFolio: 'GRUPO1', studentName: ' A '),
        throwsA(isA<FormatException>()),
      );

      expect(repository.callCount, 0);
    });

    test('rechaza un nombre mayor a 150 caracteres', () {
      final repository = _FakeEnrollmentRepository();

      final useCase = CreateStudentEnrollment(repository: repository);

      expect(
        () => useCase(groupFolio: 'GRUPO1', studentName: 'a' * 151),
        throwsA(isA<FormatException>()),
      );

      expect(repository.callCount, 0);
    });
  });
}

class _FakeEnrollmentRepository implements StudentEnrollmentRepository {
  int callCount = 0;
  String? receivedFolio;
  String? receivedName;

  @override
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) async {
    callCount++;
    receivedFolio = groupFolio;
    receivedName = studentName;

    return const StudentEnrollment(
      studentId: 17,
      groupId: 4,
      subject: 'Historia',
      studentName: 'Ana Pérez',
      status: 'inscrito',
      mode: 'nuevo',
      credentialVersion: 1,
      accessCode: 'ABCD27',
    );
  }
}

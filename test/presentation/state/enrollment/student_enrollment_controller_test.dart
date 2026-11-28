import 'dart:async';

import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/enrollment/student_enrollment.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/enrollment/student_enrollment_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/enrollment/create_student_enrollment.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/enrollment/student_enrollment_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentEnrollmentController', () {
    test('inicia sin inscripción, código ni error', () {
      final controller = _buildController(
        repository: _SuccessEnrollmentRepository(),
      );

      expect(controller.status, StudentEnrollmentStatus.initial);

      expect(controller.enrollment, isNull);
      expect(controller.accessCode, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isSuccess, isFalse);

      controller.dispose();
    });

    test('crea correctamente un perfil nuevo', () async {
      final repository = _SuccessEnrollmentRepository();

      final controller = _buildController(repository: repository);

      final result = await controller.create(
        groupFolio: ' grupo1 ',
        studentName: '  Ana   María   Pérez  ',
      );

      expect(result, isTrue);

      expect(controller.status, StudentEnrollmentStatus.success);

      expect(controller.isSuccess, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);

      expect(controller.enrollment?.studentId, 17);

      expect(controller.enrollment?.groupId, 4);

      expect(controller.enrollment?.subject, 'Historia');

      expect(controller.enrollment?.studentName, 'Ana María Pérez');

      expect(controller.accessCode, 'ABCD27');

      expect(repository.receivedFolio, 'GRUPO1');

      expect(repository.receivedName, 'Ana María Pérez');

      expect(repository.callCount, 1);

      controller.dispose();
    });

    test('notifica loading antes de completar', () async {
      final repository = _PendingEnrollmentRepository();

      final controller = _buildController(repository: repository);

      final createFuture = controller.create(
        groupFolio: 'GRUPO1',
        studentName: 'Ana Pérez',
      );

      expect(controller.status, StudentEnrollmentStatus.loading);

      expect(controller.isLoading, isTrue);
      expect(controller.enrollment, isNull);
      expect(controller.accessCode, isNull);
      expect(controller.errorMessage, isNull);

      repository.complete(_enrollment);

      expect(await createFuture, isTrue);

      expect(controller.status, StudentEnrollmentStatus.success);

      expect(controller.enrollment, same(_enrollment));

      expect(controller.accessCode, 'ABCD27');

      controller.dispose();
    });

    test('evita dos solicitudes simultáneas', () async {
      final repository = _PendingEnrollmentRepository();

      final controller = _buildController(repository: repository);

      final firstRequest = controller.create(
        groupFolio: 'GRUPO1',
        studentName: 'Ana Pérez',
      );

      expect(controller.isLoading, isTrue);

      final secondResult = await controller.create(
        groupFolio: 'GRUPO2',
        studentName: 'Otro alumno',
      );

      expect(secondResult, isFalse);
      expect(repository.callCount, 1);

      repository.complete(_enrollment);

      expect(await firstRequest, isTrue);
      expect(repository.callCount, 1);

      controller.dispose();
    });

    test('expone errores locales de validación', () async {
      final repository = _SuccessEnrollmentRepository();

      final controller = _buildController(repository: repository);

      final result = await controller.create(
        groupFolio: ' ',
        studentName: 'Ana Pérez',
      );

      expect(result, isFalse);

      expect(controller.status, StudentEnrollmentStatus.failure);

      expect(controller.enrollment, isNull);
      expect(controller.accessCode, isNull);

      expect(
        controller.errorMessage,
        'El folio debe contener entre 4 y 20 '
        'letras o números.',
      );

      expect(repository.callCount, 0);

      controller.dispose();
    });

    test('expone un error controlado de la API', () async {
      const exception = ApiException(
        type: ApiFailureType.groupUnavailable,
        statusCode: 402,
        message: 'El grupo alcanzó su límite de alumnos.',
      );

      final controller = _buildController(
        repository: _FailureEnrollmentRepository(exception: exception),
      );

      final result = await controller.create(
        groupFolio: 'GRUPO1',
        studentName: 'Ana Pérez',
      );

      expect(result, isFalse);

      expect(controller.status, StudentEnrollmentStatus.failure);

      expect(controller.enrollment, isNull);
      expect(controller.accessCode, isNull);

      expect(controller.errorMessage, 'El grupo alcanzó su límite de alumnos.');

      expect(controller.isLoading, isFalse);
      expect(controller.isSuccess, isFalse);

      controller.dispose();
    });

    test('permite reintentar después de un error', () async {
      final repository = _FailOnceEnrollmentRepository();

      final controller = _buildController(repository: repository);

      final firstResult = await controller.create(
        groupFolio: 'GRUPO1',
        studentName: 'Ana Pérez',
      );

      expect(firstResult, isFalse);

      expect(controller.status, StudentEnrollmentStatus.failure);

      final secondResult = await controller.create(
        groupFolio: 'GRUPO1',
        studentName: 'Ana Pérez',
      );

      expect(secondResult, isTrue);

      expect(controller.status, StudentEnrollmentStatus.success);

      expect(controller.accessCode, 'ABCD27');
      expect(repository.callCount, 2);

      controller.dispose();
    });

    test('expone un error inesperado controlado', () async {
      final controller = _buildController(
        repository: _UnexpectedFailureEnrollmentRepository(),
      );

      final result = await controller.create(
        groupFolio: 'GRUPO1',
        studentName: 'Ana Pérez',
      );

      expect(result, isFalse);

      expect(controller.status, StudentEnrollmentStatus.failure);

      expect(
        controller.errorMessage,
        'Ocurrió un error inesperado al crear el perfil.',
      );

      expect(controller.enrollment, isNull);
      expect(controller.accessCode, isNull);

      controller.dispose();
    });

    test('reset elimina inscripción, código y error', () async {
      final controller = _buildController(
        repository: _SuccessEnrollmentRepository(),
      );

      await controller.create(groupFolio: 'GRUPO1', studentName: 'Ana Pérez');

      expect(controller.enrollment, isNotNull);
      expect(controller.accessCode, 'ABCD27');

      controller.reset();

      expect(controller.status, StudentEnrollmentStatus.initial);

      expect(controller.enrollment, isNull);
      expect(controller.accessCode, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isSuccess, isFalse);

      controller.dispose();
    });
  });
}

StudentEnrollmentController _buildController({
  required StudentEnrollmentRepository repository,
}) {
  return StudentEnrollmentController(
    createEnrollment: CreateStudentEnrollment(repository: repository),
  );
}

const StudentEnrollment _enrollment = StudentEnrollment(
  studentId: 17,
  groupId: 4,
  subject: 'Historia',
  studentName: 'Ana María Pérez',
  status: 'inscrito',
  mode: 'nuevo',
  credentialVersion: 1,
  accessCode: 'ABCD27',
);

class _SuccessEnrollmentRepository implements StudentEnrollmentRepository {
  String? receivedFolio;
  String? receivedName;
  int callCount = 0;

  @override
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) async {
    callCount++;
    receivedFolio = groupFolio;
    receivedName = studentName;

    return StudentEnrollment(
      studentId: 17,
      groupId: 4,
      subject: 'Historia',
      studentName: studentName,
      status: 'inscrito',
      mode: 'nuevo',
      credentialVersion: 1,
      accessCode: 'ABCD27',
    );
  }
}

class _FailureEnrollmentRepository implements StudentEnrollmentRepository {
  const _FailureEnrollmentRepository({required this.exception});

  final ApiException exception;

  @override
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) {
    throw exception;
  }
}

class _PendingEnrollmentRepository implements StudentEnrollmentRepository {
  final Completer<StudentEnrollment> _completer =
      Completer<StudentEnrollment>();

  int callCount = 0;

  @override
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) {
    callCount++;
    return _completer.future;
  }

  void complete(StudentEnrollment enrollment) {
    _completer.complete(enrollment);
  }
}

class _FailOnceEnrollmentRepository implements StudentEnrollmentRepository {
  int callCount = 0;

  @override
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) async {
    callCount++;

    if (callCount == 1) {
      throw const ApiException(
        type: ApiFailureType.connection,
        message:
            'No fue posible crear el perfil. '
            'Revisa tu conexión.',
      );
    }

    return _enrollment;
  }
}

class _UnexpectedFailureEnrollmentRepository
    implements StudentEnrollmentRepository {
  @override
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) {
    throw StateError('Error sintético inesperado.');
  }
}

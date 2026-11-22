import 'dart:async';

import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/attempts/student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/attempts/student_exam_attempt_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/attempts/start_student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/attempts/start_exam_attempt_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StartExamAttemptController', () {
    test('inicia sin intento ni mensaje de error', () {
      final controller = _buildController(
        repository: _SuccessAttemptRepository(),
      );

      expect(controller.status, StartExamAttemptStatus.initial);
      expect(controller.attempt, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);

      controller.dispose();
    });

    test('inicia correctamente un intento nuevo', () async {
      final repository = _SuccessAttemptRepository();

      final controller = _buildController(repository: repository);

      final result = await controller.start(
        folio: 'folio123',
        accessCode: 'abcd27',
        examId: 25,
      );

      expect(result, isTrue);
      expect(controller.status, StartExamAttemptStatus.success);
      expect(controller.attempt, isNotNull);
      expect(controller.attempt?.id, 123);
      expect(controller.attempt?.examId, 25);
      expect(controller.attempt?.wasResumed, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);

      expect(repository.receivedFolio, 'FOLIO123');
      expect(repository.receivedAccessCode, 'ABCD27');
      expect(repository.receivedExamId, 25);

      controller.dispose();
    });

    test('conserva un intento reanudado', () async {
      final controller = _buildController(
        repository: _SuccessAttemptRepository(attempt: _resumedAttempt),
      );

      final result = await controller.start(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
        examId: 25,
      );

      expect(result, isTrue);
      expect(controller.attempt, isNotNull);
      expect(controller.attempt?.wasResumed, isTrue);
      expect(controller.status, StartExamAttemptStatus.success);

      controller.dispose();
    });

    test('notifica el estado de carga antes de completar', () async {
      final repository = _PendingAttemptRepository();

      final controller = _buildController(repository: repository);

      final startFuture = controller.start(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
        examId: 25,
      );

      expect(controller.status, StartExamAttemptStatus.loading);
      expect(controller.isLoading, isTrue);
      expect(controller.attempt, isNull);
      expect(controller.errorMessage, isNull);

      repository.complete(_newAttempt);

      final result = await startFuture;

      expect(result, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.status, StartExamAttemptStatus.success);
      expect(controller.attempt, same(_newAttempt));

      controller.dispose();
    });

    test('evita un segundo envío durante la carga', () async {
      final repository = _PendingAttemptRepository();

      final controller = _buildController(repository: repository);

      final firstRequest = controller.start(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
        examId: 25,
      );

      expect(controller.isLoading, isTrue);

      final secondResult = await controller.start(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
        examId: 25,
      );

      expect(secondResult, isFalse);
      expect(repository.callCount, 1);

      repository.complete(_newAttempt);

      expect(await firstRequest, isTrue);

      controller.dispose();
    });

    test('expone un error controlado de la API', () async {
      const exception = ApiException(
        type: ApiFailureType.examUnavailable,
        statusCode: 404,
        message: 'El examen no está disponible para este grupo.',
      );

      final controller = _buildController(
        repository: _FailureAttemptRepository(exception: exception),
      );

      final result = await controller.start(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
        examId: 25,
      );

      expect(result, isFalse);
      expect(controller.status, StartExamAttemptStatus.failure);
      expect(controller.attempt, isNull);
      expect(
        controller.errorMessage,
        'El examen no está disponible para este grupo.',
      );
      expect(controller.isLoading, isFalse);

      controller.dispose();
    });

    test('expone el error de un examen ya cerrado', () async {
      const exception = ApiException(
        type: ApiFailureType.attemptClosed,
        statusCode: 409,
        message: 'Ya entregaste este examen o el intento fue anulado.',
      );

      final controller = _buildController(
        repository: _FailureAttemptRepository(exception: exception),
      );

      final result = await controller.start(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
        examId: 25,
      );

      expect(result, isFalse);
      expect(
        controller.errorMessage,
        'Ya entregaste este examen o el intento fue anulado.',
      );
      expect(controller.attempt, isNull);

      controller.dispose();
    });

    test('rechaza un identificador de examen inválido', () async {
      final repository = _SuccessAttemptRepository();

      final controller = _buildController(repository: repository);

      final result = await controller.start(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
        examId: 0,
      );

      expect(result, isFalse);
      expect(controller.status, StartExamAttemptStatus.failure);
      expect(controller.errorMessage, 'El examen seleccionado no es válido.');
      expect(repository.callCount, 0);

      controller.dispose();
    });

    test('el mensaje de error no contiene el token de sesión', () async {
      const syntheticToken = 'token-secreto-de-prueba';

      const exception = ApiException(
        type: ApiFailureType.requestFailed,
        statusCode: 503,
        message: 'No se pudo iniciar el examen. Inténtalo de nuevo.',
      );

      final controller = _buildController(
        repository: _FailureAttemptRepository(exception: exception),
      );

      await controller.start(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
        examId: 25,
      );

      expect(controller.errorMessage, isNot(contains(syntheticToken)));

      controller.dispose();
    });

    test('reset elimina el intento y restaura el estado inicial', () async {
      final controller = _buildController(
        repository: _SuccessAttemptRepository(),
      );

      await controller.start(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
        examId: 25,
      );

      expect(controller.attempt, isNotNull);

      controller.reset();

      expect(controller.status, StartExamAttemptStatus.initial);
      expect(controller.attempt, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);

      controller.dispose();
    });
  });
}

StartExamAttemptController _buildController({
  required StudentExamAttemptRepository repository,
}) {
  return StartExamAttemptController(
    startAttempt: StartStudentExamAttempt(repository: repository),
  );
}

final StudentExamAttempt _newAttempt = StudentExamAttempt(
  id: 123,
  examId: 25,
  sessionToken: 'token-sintetico-nuevo',
  startedAt: DateTime.parse('2026-11-20T18:30:00-06:00'),
  wasResumed: false,
);

final StudentExamAttempt _resumedAttempt = StudentExamAttempt(
  id: 123,
  examId: 25,
  sessionToken: 'token-sintetico-reanudado',
  startedAt: DateTime.parse('2026-11-20T18:30:00-06:00'),
  wasResumed: true,
);

class _SuccessAttemptRepository implements StudentExamAttemptRepository {
  _SuccessAttemptRepository({StudentExamAttempt? attempt})
    : attempt = attempt ?? _newAttempt;

  final StudentExamAttempt attempt;

  String? receivedFolio;
  String? receivedAccessCode;
  int? receivedExamId;
  int callCount = 0;

  @override
  Future<StudentExamAttempt> start({
    required String folio,
    required String accessCode,
    required int examId,
  }) async {
    callCount++;
    receivedFolio = folio;
    receivedAccessCode = accessCode;
    receivedExamId = examId;

    return attempt;
  }
}

class _FailureAttemptRepository implements StudentExamAttemptRepository {
  const _FailureAttemptRepository({required this.exception});

  final ApiException exception;

  @override
  Future<StudentExamAttempt> start({
    required String folio,
    required String accessCode,
    required int examId,
  }) {
    throw exception;
  }
}

class _PendingAttemptRepository implements StudentExamAttemptRepository {
  final Completer<StudentExamAttempt> _completer =
      Completer<StudentExamAttempt>();

  int callCount = 0;

  @override
  Future<StudentExamAttempt> start({
    required String folio,
    required String accessCode,
    required int examId,
  }) {
    callCount++;
    return _completer.future;
  }

  void complete(StudentExamAttempt attempt) {
    _completer.complete(attempt);
  }
}

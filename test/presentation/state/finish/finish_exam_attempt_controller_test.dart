import 'dart:async';

import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/finish/student_finished_attempt.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/finish/student_finish_attempt_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/finish/finish_student_exam_attempt.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/finish/finish_exam_attempt_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinishExamAttemptController', () {
    test('inicia sin entrega ni error', () {
      final controller = _buildController(
        repository: _SuccessFinishRepository(),
      );

      expect(controller.status, FinishExamAttemptStatus.initial);

      expect(controller.finishedAttempt, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isSuccess, isFalse);

      controller.dispose();
    });

    test('finaliza correctamente el intento', () async {
      final repository = _SuccessFinishRepository();

      final controller = _buildController(repository: repository);

      final result = await controller.finish(sessionToken: ' token-sintetico ');

      expect(result, isTrue);

      expect(controller.status, FinishExamAttemptStatus.success);

      expect(controller.isSuccess, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);

      expect(controller.finishedAttempt?.id, 123);

      expect(controller.finishedAttempt?.status, 'finalizado');

      expect(
        controller.finishedAttempt?.submittedAt,
        DateTime.parse('2026-11-23T18:30:00-06:00'),
      );

      expect(repository.receivedToken, 'token-sintetico');

      expect(repository.callCount, 1);

      controller.dispose();
    });

    test('notifica loading antes de completar', () async {
      final repository = _PendingFinishRepository();

      final controller = _buildController(repository: repository);

      final finishFuture = controller.finish(sessionToken: 'token-sintetico');

      expect(controller.status, FinishExamAttemptStatus.loading);

      expect(controller.isLoading, isTrue);
      expect(controller.finishedAttempt, isNull);

      repository.complete(_finishedAttempt);

      expect(await finishFuture, isTrue);

      expect(controller.status, FinishExamAttemptStatus.success);

      expect(controller.finishedAttempt, same(_finishedAttempt));

      controller.dispose();
    });

    test('evita dos solicitudes simultáneas', () async {
      final repository = _PendingFinishRepository();

      final controller = _buildController(repository: repository);

      final firstRequest = controller.finish(sessionToken: 'token-sintetico');

      expect(controller.isLoading, isTrue);

      final secondResult = await controller.finish(
        sessionToken: 'token-sintetico',
      );

      expect(secondResult, isFalse);
      expect(repository.callCount, 1);

      repository.complete(_finishedAttempt);

      expect(await firstRequest, isTrue);
      expect(repository.callCount, 1);

      controller.dispose();
    });

    test('acepta una confirmación idempotente', () async {
      final repository = _SuccessFinishRepository(
        finishedAttempt: _finishedAttempt,
      );

      final controller = _buildController(repository: repository);

      final firstResult = await controller.finish(
        sessionToken: 'token-sintetico',
      );

      final firstSubmittedAt = controller.finishedAttempt?.submittedAt;

      controller.reset();

      final secondResult = await controller.finish(
        sessionToken: 'token-sintetico',
      );

      expect(firstResult, isTrue);
      expect(secondResult, isTrue);

      expect(controller.finishedAttempt?.submittedAt, firstSubmittedAt);

      expect(repository.callCount, 2);

      controller.dispose();
    });

    test('expone un error controlado de la API', () async {
      const exception = ApiException(
        type: ApiFailureType.requestFailed,
        statusCode: 422,
        message: 'No fue posible entregar el examen.',
      );

      final controller = _buildController(
        repository: _FailureFinishRepository(exception: exception),
      );

      final result = await controller.finish(sessionToken: 'token-sintetico');

      expect(result, isFalse);

      expect(controller.status, FinishExamAttemptStatus.failure);

      expect(controller.finishedAttempt, isNull);

      expect(controller.errorMessage, 'No fue posible entregar el examen.');

      expect(controller.isLoading, isFalse);
      expect(controller.isSuccess, isFalse);

      controller.dispose();
    });

    test('conserva un mensaje para intento no disponible', () async {
      const exception = ApiException(
        type: ApiFailureType.examUnavailable,
        statusCode: 403,
        message: 'El intento ya no está disponible.',
      );

      final controller = _buildController(
        repository: _FailureFinishRepository(exception: exception),
      );

      final result = await controller.finish(sessionToken: 'token-sintetico');

      expect(result, isFalse);

      expect(controller.errorMessage, 'El intento ya no está disponible.');

      controller.dispose();
    });

    test('expone errores de validación local', () async {
      final repository = _SuccessFinishRepository();

      final controller = _buildController(repository: repository);

      final result = await controller.finish(sessionToken: '   ');

      expect(result, isFalse);

      expect(controller.status, FinishExamAttemptStatus.failure);

      expect(
        controller.errorMessage,
        'La sesión del intento no está disponible.',
      );

      expect(repository.callCount, 0);

      controller.dispose();
    });

    test('expone un error inesperado controlado', () async {
      final controller = _buildController(
        repository: _UnexpectedFailureFinishRepository(),
      );

      final result = await controller.finish(sessionToken: 'token-sintetico');

      expect(result, isFalse);

      expect(
        controller.errorMessage,
        'Ocurrió un error inesperado al entregar '
        'el examen.',
      );

      controller.dispose();
    });

    test('reset elimina entrega y error', () async {
      final controller = _buildController(
        repository: _SuccessFinishRepository(),
      );

      await controller.finish(sessionToken: 'token-sintetico');

      expect(controller.finishedAttempt, isNotNull);
      expect(controller.isSuccess, isTrue);

      controller.reset();

      expect(controller.status, FinishExamAttemptStatus.initial);

      expect(controller.finishedAttempt, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isSuccess, isFalse);

      controller.dispose();
    });
  });
}

FinishExamAttemptController _buildController({
  required StudentFinishAttemptRepository repository,
}) {
  return FinishExamAttemptController(
    finishAttempt: FinishStudentExamAttempt(repository: repository),
  );
}

final StudentFinishedAttempt _finishedAttempt = StudentFinishedAttempt(
  id: 123,
  status: 'finalizado',
  submittedAt: DateTime.parse('2026-11-23T18:30:00-06:00'),
);

class _SuccessFinishRepository implements StudentFinishAttemptRepository {
  _SuccessFinishRepository({StudentFinishedAttempt? finishedAttempt})
    : finishedAttempt = finishedAttempt ?? _finishedAttempt;

  final StudentFinishedAttempt finishedAttempt;

  String? receivedToken;
  int callCount = 0;

  @override
  Future<StudentFinishedAttempt> finish({required String sessionToken}) async {
    callCount++;
    receivedToken = sessionToken;

    return finishedAttempt;
  }
}

class _FailureFinishRepository implements StudentFinishAttemptRepository {
  const _FailureFinishRepository({required this.exception});

  final ApiException exception;

  @override
  Future<StudentFinishedAttempt> finish({required String sessionToken}) {
    throw exception;
  }
}

class _PendingFinishRepository implements StudentFinishAttemptRepository {
  final Completer<StudentFinishedAttempt> _completer =
      Completer<StudentFinishedAttempt>();

  int callCount = 0;

  @override
  Future<StudentFinishedAttempt> finish({required String sessionToken}) {
    callCount++;
    return _completer.future;
  }

  void complete(StudentFinishedAttempt finishedAttempt) {
    _completer.complete(finishedAttempt);
  }
}

class _UnexpectedFailureFinishRepository
    implements StudentFinishAttemptRepository {
  @override
  Future<StudentFinishedAttempt> finish({required String sessionToken}) {
    throw StateError('Error inesperado sintético.');
  }
}

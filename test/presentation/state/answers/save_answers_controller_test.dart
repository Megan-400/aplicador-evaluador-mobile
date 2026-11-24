import 'dart:async';

import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/answers/student_saved_answer.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/answers/student_answer_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/answers/save_student_answer.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/answers/save_answers_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaveAnswersController', () {
    test('inicia sin estados ni respuestas pendientes', () {
      final controller = _buildController(
        repository: _SuccessAnswerRepository(),
      );

      expect(controller.states, isEmpty);
      expect(controller.hasPendingAnswers, isFalse);
      expect(controller.hasFailedAnswers, isFalse);
      expect(controller.isSavingAny, isFalse);
      expect(controller.pendingCount, 0);

      controller.dispose();
    });

    test('hidrata respuestas recuperadas como sincronizadas', () {
      final controller = _buildController(
        repository: _SuccessAnswerRepository(),
      );

      controller.hydrate(const {1: 'Respuesta abierta.', 2: 'B'});

      expect(controller.stateFor(1).localAnswer, 'Respuesta abierta.');
      expect(controller.stateFor(1).savedAnswer, 'Respuesta abierta.');
      expect(controller.stateFor(1).status, AnswerSaveStatus.unchanged);

      expect(controller.stateFor(2).localAnswer, 'B');
      expect(controller.hasPendingAnswers, isFalse);

      controller.dispose();
    });

    test('marca una respuesta editada como pendiente', () {
      final controller = _buildController(
        repository: _SuccessAnswerRepository(),
      );

      controller.hydrate(const {1: 'Respuesta original.'});

      controller.setLocalAnswer(questionId: 1, answer: 'Respuesta modificada.');

      final state = controller.stateFor(1);

      expect(state.status, AnswerSaveStatus.pending);
      expect(state.localAnswer, 'Respuesta modificada.');
      expect(state.savedAnswer, 'Respuesta original.');
      expect(state.hasChanges, isTrue);
      expect(controller.hasPendingAnswers, isTrue);

      controller.dispose();
    });

    test('volver al contenido guardado elimina el pendiente', () {
      final controller = _buildController(
        repository: _SuccessAnswerRepository(),
      );

      controller.hydrate(const {1: 'Respuesta original.'});

      controller.setLocalAnswer(questionId: 1, answer: 'Respuesta modificada.');

      controller.setLocalAnswer(questionId: 1, answer: 'Respuesta original.');

      expect(controller.stateFor(1).status, AnswerSaveStatus.unchanged);
      expect(controller.hasPendingAnswers, isFalse);

      controller.dispose();
    });

    test('guarda una respuesta pendiente', () async {
      final repository = _SuccessAnswerRepository();

      final controller = _buildController(repository: repository);

      controller.setLocalAnswer(questionId: 1, answer: 'Respuesta nueva.');

      final result = await controller.save(
        sessionToken: 'token-sintetico',
        questionId: 1,
      );

      expect(result, isTrue);

      final state = controller.stateFor(1);

      expect(state.status, AnswerSaveStatus.saved);
      expect(state.localAnswer, 'Respuesta nueva.');
      expect(state.savedAnswer, 'Respuesta nueva.');
      expect(state.savedAnswerId, 123);
      expect(state.errorMessage, isNull);

      expect(repository.receivedAnswer, 'Respuesta nueva.');
      expect(repository.receivedQuestionId, 1);

      controller.dispose();
    });

    test('no envía una respuesta sin cambios', () async {
      final repository = _SuccessAnswerRepository();

      final controller = _buildController(repository: repository);

      controller.hydrate(const {1: 'Respuesta guardada.'});

      final result = await controller.save(
        sessionToken: 'token-sintetico',
        questionId: 1,
      );

      expect(result, isTrue);
      expect(repository.callCount, 0);

      controller.dispose();
    });

    test('evita guardar dos veces la misma pregunta', () async {
      final repository = _PendingAnswerRepository();

      final controller = _buildController(repository: repository);

      controller.setLocalAnswer(questionId: 1, answer: 'Respuesta pendiente.');

      final firstSave = controller.save(
        sessionToken: 'token-sintetico',
        questionId: 1,
      );

      expect(controller.stateFor(1).status, AnswerSaveStatus.saving);

      final secondResult = await controller.save(
        sessionToken: 'token-sintetico',
        questionId: 1,
      );

      expect(secondResult, isFalse);
      expect(repository.callCount, 1);

      repository.complete(const StudentSavedAnswer(id: 123, questionId: 1));

      expect(await firstSave, isTrue);

      controller.dispose();
    });

    test('mantiene pendiente una edición hecha durante el guardado', () async {
      final repository = _PendingAnswerRepository();

      final controller = _buildController(repository: repository);

      controller.setLocalAnswer(questionId: 1, answer: 'Versión enviada.');

      final saveFuture = controller.save(
        sessionToken: 'token-sintetico',
        questionId: 1,
      );

      controller.setLocalAnswer(questionId: 1, answer: 'Versión más reciente.');

      repository.complete(const StudentSavedAnswer(id: 123, questionId: 1));

      expect(await saveFuture, isTrue);

      final state = controller.stateFor(1);

      expect(state.status, AnswerSaveStatus.pending);
      expect(state.localAnswer, 'Versión más reciente.');
      expect(state.savedAnswer, 'Versión enviada.');
      expect(state.hasChanges, isTrue);

      controller.dispose();
    });

    test('conserva la respuesta local cuando falla', () async {
      const exception = ApiException(
        type: ApiFailureType.requestFailed,
        statusCode: 422,
        message: 'No fue posible guardar la respuesta.',
      );

      final controller = _buildController(
        repository: _FailureAnswerRepository(exception: exception),
      );

      controller.setLocalAnswer(
        questionId: 1,
        answer: 'Respuesta sin guardar.',
      );

      final result = await controller.save(
        sessionToken: 'token-sintetico',
        questionId: 1,
      );

      expect(result, isFalse);

      final state = controller.stateFor(1);

      expect(state.status, AnswerSaveStatus.failure);
      expect(state.localAnswer, 'Respuesta sin guardar.');
      expect(state.savedAnswer, '');
      expect(state.errorMessage, 'No fue posible guardar la respuesta.');

      expect(controller.hasPendingAnswers, isTrue);
      expect(controller.hasFailedAnswers, isTrue);

      controller.dispose();
    });

    test('reintenta una respuesta con error', () async {
      final repository = _FailOnceAnswerRepository();

      final controller = _buildController(repository: repository);

      controller.setLocalAnswer(
        questionId: 1,
        answer: 'Respuesta para reintentar.',
      );

      expect(
        await controller.save(sessionToken: 'token-sintetico', questionId: 1),
        isFalse,
      );

      expect(controller.stateFor(1).status, AnswerSaveStatus.failure);

      expect(
        await controller.retry(sessionToken: 'token-sintetico', questionId: 1),
        isTrue,
      );

      expect(controller.stateFor(1).status, AnswerSaveStatus.saved);

      expect(repository.callCount, 2);

      controller.dispose();
    });

    test('reset elimina todos los estados', () {
      final controller = _buildController(
        repository: _SuccessAnswerRepository(),
      );

      controller.hydrate(const {1: 'Respuesta.'});

      controller.setLocalAnswer(questionId: 2, answer: 'Otra respuesta.');

      controller.reset();

      expect(controller.states, isEmpty);
      expect(controller.hasPendingAnswers, isFalse);
      expect(controller.isSavingAny, isFalse);

      controller.dispose();
    });
  });
}

SaveAnswersController _buildController({
  required StudentAnswerRepository repository,
}) {
  return SaveAnswersController(
    saveAnswer: SaveStudentAnswer(repository: repository),
  );
}

class _SuccessAnswerRepository implements StudentAnswerRepository {
  int callCount = 0;
  String? receivedToken;
  int? receivedQuestionId;
  String? receivedAnswer;

  @override
  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) async {
    callCount++;
    receivedToken = sessionToken;
    receivedQuestionId = questionId;
    receivedAnswer = answer;

    return StudentSavedAnswer(id: 123, questionId: questionId);
  }
}

class _FailureAnswerRepository implements StudentAnswerRepository {
  const _FailureAnswerRepository({required this.exception});

  final ApiException exception;

  @override
  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) {
    throw exception;
  }
}

class _PendingAnswerRepository implements StudentAnswerRepository {
  final Completer<StudentSavedAnswer> _completer =
      Completer<StudentSavedAnswer>();

  int callCount = 0;

  @override
  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) {
    callCount++;
    return _completer.future;
  }

  void complete(StudentSavedAnswer answer) {
    _completer.complete(answer);
  }
}

class _FailOnceAnswerRepository implements StudentAnswerRepository {
  int callCount = 0;

  @override
  Future<StudentSavedAnswer> save({
    required String sessionToken,
    required int questionId,
    required String answer,
  }) async {
    callCount++;

    if (callCount == 1) {
      throw const ApiException(
        type: ApiFailureType.connection,
        message: 'Error sintético de conexión.',
      );
    }

    return StudentSavedAnswer(id: 123, questionId: questionId);
  }
}

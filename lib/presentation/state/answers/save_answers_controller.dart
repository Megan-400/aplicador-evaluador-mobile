import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entities/answers/student_saved_answer.dart';
import '../../../domain/usecases/answers/save_student_answer.dart';

/// Estado de sincronización de una respuesta.
enum AnswerSaveStatus {
  /// La respuesta coincide con la última versión guardada.
  unchanged,

  /// La respuesta fue modificada localmente.
  pending,

  /// La respuesta se está enviando al backend.
  saving,

  /// La respuesta fue confirmada por el backend.
  saved,

  /// El último intento de guardado falló.
  failure,
}

/// Estado de guardado de una pregunta concreta.
class AnswerSaveState {
  const AnswerSaveState({
    required this.status,
    required this.localAnswer,
    required this.savedAnswer,
    this.savedAnswerId,
    this.errorMessage,
  });

  const AnswerSaveState.initial({String answer = ''})
    : this(
        status: AnswerSaveStatus.unchanged,
        localAnswer: answer,
        savedAnswer: answer,
      );

  final AnswerSaveStatus status;

  /// Contenido actual que el alumno ve y edita.
  final String localAnswer;

  /// Último contenido confirmado por el backend.
  final String savedAnswer;

  /// Identificador devuelto por el backend.
  final int? savedAnswerId;

  final String? errorMessage;

  bool get hasChanges => localAnswer != savedAnswer;

  bool get isSaving => status == AnswerSaveStatus.saving;

  bool get hasFailure => status == AnswerSaveStatus.failure;

  AnswerSaveState copyWith({
    AnswerSaveStatus? status,
    String? localAnswer,
    String? savedAnswer,
    int? savedAnswerId,
    bool clearSavedAnswerId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AnswerSaveState(
      status: status ?? this.status,
      localAnswer: localAnswer ?? this.localAnswer,
      savedAnswer: savedAnswer ?? this.savedAnswer,
      savedAnswerId: clearSavedAnswerId
          ? null
          : savedAnswerId ?? this.savedAnswerId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

/// Administra el guardado remoto de respuestas por pregunta.
///
/// No conserva ni imprime `token_sesion`. El token se recibe únicamente
/// cuando se solicita guardar una respuesta.
class SaveAnswersController extends ChangeNotifier {
  SaveAnswersController({required this.saveAnswer});

  final SaveStudentAnswer saveAnswer;

  final Map<int, AnswerSaveState> _states = {};

  Map<int, AnswerSaveState> get states => Map.unmodifiable(_states);

  AnswerSaveState stateFor(int questionId) {
    return _states[questionId] ?? const AnswerSaveState.initial();
  }

  bool get isSavingAny {
    return _states.values.any((state) => state.isSaving);
  }

  bool get hasPendingAnswers {
    return _states.values.any(
      (state) =>
          state.status == AnswerSaveStatus.pending ||
          state.status == AnswerSaveStatus.failure,
    );
  }

  bool get hasFailedAnswers {
    return _states.values.any((state) => state.hasFailure);
  }

  int get pendingCount {
    return _states.values
        .where(
          (state) =>
              state.status == AnswerSaveStatus.pending ||
              state.status == AnswerSaveStatus.failure,
        )
        .length;
  }

  int get savedCount {
    return _states.values
        .where(
          (state) =>
              state.status == AnswerSaveStatus.saved ||
              state.status == AnswerSaveStatus.unchanged,
        )
        .length;
  }

  /// Inicializa las respuestas recuperadas al reanudar.
  ///
  /// Se consideran sincronizadas porque proceden del backend.
  void hydrate(Map<int, String> savedAnswers) {
    _states
      ..clear()
      ..addEntries(
        savedAnswers.entries.map(
          (entry) =>
              MapEntry(entry.key, AnswerSaveState.initial(answer: entry.value)),
        ),
      );

    notifyListeners();
  }

  /// Notifica una edición local.
  void setLocalAnswer({required int questionId, required String answer}) {
    if (questionId <= 0) {
      return;
    }

    final current = stateFor(questionId);

    if (current.localAnswer == answer) {
      return;
    }

    final nextStatus = answer == current.savedAnswer
        ? AnswerSaveStatus.unchanged
        : AnswerSaveStatus.pending;

    _states[questionId] = current.copyWith(
      status: nextStatus,
      localAnswer: answer,
      clearError: true,
    );

    notifyListeners();
  }

  /// Guarda una pregunta si contiene cambios válidos.
  ///
  /// Devuelve `true` cuando la pregunta no necesita guardarse o cuando
  /// el backend confirma correctamente el guardado.
  Future<bool> save({
    required String sessionToken,
    required int questionId,
  }) async {
    final current = stateFor(questionId);

    if (current.isSaving) {
      return false;
    }

    if (!current.hasChanges) {
      return true;
    }

    if (current.localAnswer.trim().isEmpty) {
      _states[questionId] = current.copyWith(
        status: AnswerSaveStatus.pending,
        errorMessage: 'La respuesta está vacía y no puede guardarse.',
      );
      notifyListeners();
      return false;
    }

    final answerBeingSaved = current.localAnswer;

    _states[questionId] = current.copyWith(
      status: AnswerSaveStatus.saving,
      clearError: true,
    );
    notifyListeners();

    try {
      final result = await saveAnswer(
        sessionToken: sessionToken,
        questionId: questionId,
        answer: answerBeingSaved,
      );

      _applySuccessfulSave(
        questionId: questionId,
        answerBeingSaved: answerBeingSaved,
        result: result,
      );

      return true;
    } on ApiException catch (error) {
      _applyFailure(
        questionId: questionId,
        answerBeingSaved: answerBeingSaved,
        message: error.message,
      );

      return false;
    } on FormatException catch (error) {
      _applyFailure(
        questionId: questionId,
        answerBeingSaved: answerBeingSaved,
        message: error.message,
      );

      return false;
    } catch (_) {
      _applyFailure(
        questionId: questionId,
        answerBeingSaved: answerBeingSaved,
        message: 'Ocurrió un error inesperado al guardar la respuesta.',
      );

      return false;
    }
  }

  void _applySuccessfulSave({
    required int questionId,
    required String answerBeingSaved,
    required StudentSavedAnswer result,
  }) {
    final current = stateFor(questionId);

    // El alumno pudo seguir escribiendo mientras se guardaba.
    final wasEditedDuringSave = current.localAnswer != answerBeingSaved;

    _states[questionId] = current.copyWith(
      status: wasEditedDuringSave
          ? AnswerSaveStatus.pending
          : AnswerSaveStatus.saved,
      savedAnswer: answerBeingSaved,
      savedAnswerId: result.id,
      clearError: true,
    );

    notifyListeners();
  }

  void _applyFailure({
    required int questionId,
    required String answerBeingSaved,
    required String message,
  }) {
    final current = stateFor(questionId);

    _states[questionId] = current.copyWith(
      status: AnswerSaveStatus.failure,
      errorMessage: message,
    );

    notifyListeners();
  }

  /// Reintenta una pregunta en estado de error o pendiente.
  Future<bool> retry({required String sessionToken, required int questionId}) {
    return save(sessionToken: sessionToken, questionId: questionId);
  }

  void reset() {
    _states.clear();
    notifyListeners();
  }
}

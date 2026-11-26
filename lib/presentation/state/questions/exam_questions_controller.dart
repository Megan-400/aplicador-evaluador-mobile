import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entities/questions/student_exam_question.dart';
import '../../../domain/usecases/questions/load_student_exam_questions.dart';

enum ExamQuestionsStatus { initial, loading, success, empty, failure }

/// Administra las preguntas y respuestas locales de un intento.
/// Las respuestas se mantienen únicamente en memoria. El guardado remoto
/// se implementará posteriormente en HU-MOV-012.
class ExamQuestionsController extends ChangeNotifier {
  ExamQuestionsController({required this.loadQuestions});

  final LoadStudentExamQuestions loadQuestions;

  ExamQuestionsStatus _status = ExamQuestionsStatus.initial;
  List<StudentExamQuestion> _questions = const [];
  int _currentIndex = 0;
  String? _errorMessage;

  final Map<int, String> _localAnswers = {};

  ExamQuestionsStatus get status => _status;

  List<StudentExamQuestion> get questions => List.unmodifiable(_questions);

  int get currentIndex => _currentIndex;

  String? get errorMessage => _errorMessage;

  String _examName = '';

  String get examName => _examName;

  bool get isLoading => _status == ExamQuestionsStatus.loading;

  bool get hasQuestions =>
      _status == ExamQuestionsStatus.success && _questions.isNotEmpty;

  int get totalQuestions => _questions.length;

  StudentExamQuestion? get currentQuestion {
    if (_questions.isEmpty ||
        _currentIndex < 0 ||
        _currentIndex >= _questions.length) {
      return null;
    }

    return _questions[_currentIndex];
  }

  bool get isFirstQuestion {
    return _questions.isEmpty || _currentIndex == 0;
  }

  bool get isLastQuestion {
    return _questions.isNotEmpty && _currentIndex == _questions.length - 1;
  }

  bool get canGoPrevious {
    return _questions.isNotEmpty && _currentIndex > 0;
  }

  bool get canGoNext {
    return _questions.isNotEmpty && _currentIndex < _questions.length - 1;
  }

  /// Progreso entre cero y uno.
  ///
  /// La primera pregunta representa una fracción del total, por ejemplo:
  /// pregunta 1 de 4 = 0.25.
  double get progress {
    if (_questions.isEmpty) {
      return 0;
    }

    return (_currentIndex + 1) / _questions.length;
  }

  /// Texto de progreso listo para presentarse.
  String get progressLabel {
    if (_questions.isEmpty) {
      return 'Sin preguntas';
    }

    return 'Pregunta ${_currentIndex + 1} de ${_questions.length}';
  }

  /// Proporción de preguntas que contienen una respuesta local.
  double get answeredProgress {
    if (_questions.isEmpty) {
      return 0;
    }

    return answeredCount / _questions.length;
  }

  /// Copia inmutable de las respuestas locales.
  Map<int, String> get localAnswers => Map.unmodifiable(_localAnswers);

  String answerFor(int questionId) {
    return _localAnswers[questionId] ?? '';
  }

  String get currentAnswer {
    final question = currentQuestion;

    if (question == null) {
      return '';
    }

    return answerFor(question.id);
  }

  bool isAnswered(int questionId) {
    return answerFor(questionId).trim().isNotEmpty;
  }

  int get answeredCount {
    return _localAnswers.values
        .where((answer) => answer.trim().isNotEmpty)
        .length;
  }

  Future<bool> load({required String sessionToken}) async {
    if (isLoading) {
      return false;
    }

    _examName = '';
    _status = ExamQuestionsStatus.loading;
    _questions = const [];
    _currentIndex = 0;
    _errorMessage = null;
    _localAnswers.clear();
    notifyListeners();

    try {
      final result = await loadQuestions(sessionToken: sessionToken);

      _examName = result.examName;
      _questions = List.unmodifiable(result.questions);
      _localAnswers
        ..clear()
        ..addAll(result.savedAnswers);
      _currentIndex = 0;
      _errorMessage = null;

      if (_questions.isEmpty) {
        _status = ExamQuestionsStatus.empty;
        notifyListeners();
        return true;
      }

      _status = ExamQuestionsStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _status = ExamQuestionsStatus.failure;
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } on FormatException catch (error) {
      _status = ExamQuestionsStatus.failure;
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _status = ExamQuestionsStatus.failure;
      _errorMessage = 'Ocurrió un error inesperado al cargar las preguntas.';
      notifyListeners();
      return false;
    }
  }

  /// Avanza a la siguiente pregunta.
  ///
  /// Devuelve `false` cuando la pregunta actual ya es la última.
  bool next() {
    if (!canGoNext) {
      return false;
    }

    _currentIndex++;
    notifyListeners();
    return true;
  }

  /// Regresa a la pregunta anterior.
  ///
  /// Devuelve `false` cuando la pregunta actual ya es la primera.
  bool previous() {
    if (!canGoPrevious) {
      return false;
    }

    _currentIndex--;
    notifyListeners();
    return true;
  }

  /// Navega directamente a una pregunta mediante su índice.
  bool goTo(int index) {
    if (index < 0 || index >= _questions.length) {
      return false;
    }

    if (index == _currentIndex) {
      return true;
    }

    _currentIndex = index;
    notifyListeners();
    return true;
  }

  /// Conserva una respuesta local en memoria.
  ///
  /// Las respuestas vacías eliminan la entrada del mapa para no considerar
  /// una pregunta sin contenido como respondida.
  void setAnswer({required int questionId, required String answer}) {
    if (!_containsQuestion(questionId)) {
      return;
    }

    final previousAnswer = _localAnswers[questionId];

    if (answer.trim().isEmpty) {
      if (previousAnswer == null) {
        return;
      }

      _localAnswers.remove(questionId);
      notifyListeners();
      return;
    }

    if (previousAnswer == answer) {
      return;
    }

    _localAnswers[questionId] = answer;
    notifyListeners();
  }

  void clearAnswer(int questionId) {
    if (_localAnswers.remove(questionId) != null) {
      notifyListeners();
    }
  }

  bool _containsQuestion(int questionId) {
    return _questions.any((question) => question.id == questionId);
  }

  void reset() {
    _examName = '';
    _status = ExamQuestionsStatus.initial;
    _questions = const [];
    _currentIndex = 0;
    _errorMessage = null;
    _localAnswers.clear();
    notifyListeners();
  }
}

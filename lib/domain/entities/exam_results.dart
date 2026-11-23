import 'attempt_result.dart';

/// Resultados de un examen, con los datos que resumen al grupo.
class ExamResults {
  const ExamResults({
    required this.examId,
    required this.examName,
    required this.scale,
    required this.attempts,
  });

  final int examId;
  final String examName;
  final String scale;
  final List<AttemptResult> attempts;

  /// Calificación máxima de la escala (por ejemplo `10` en `0-10`).
  String get maxScore {
    final partes = scale.split('-');

    return partes.length == 2 ? partes[1] : scale;
  }

  List<double> get _grades => [for (final intento in attempts) ?intento.grade];

  int get totalAttempts => attempts.length;

  int get gradedAttempts => _grades.length;

  int get pendingAttempts => totalAttempts - gradedAttempts;

    /// Intentos finalizados que aún no tienen calificación definitiva.
  int get awaitingGrading {
    return attempts
        .where(
          (intento) => intento.status == 'finalizado' && intento.grade == null,
        )
        .length;
  }

  double? get average {
    final notas = _grades;

    if (notas.isEmpty) {
      return null;
    }

    return notas.reduce((a, b) => a + b) / notas.length;
  }

  double? get highest {
    final notas = _grades;

    if (notas.isEmpty) {
      return null;
    }

    return notas.reduce((a, b) => a > b ? a : b);
  }

  double? get lowest {
    final notas = _grades;

    if (notas.isEmpty) {
      return null;
    }

    return notas.reduce((a, b) => a < b ? a : b);
  }
}
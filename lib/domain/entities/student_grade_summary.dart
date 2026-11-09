/// Clasificación visible del resultado de una evaluación.
enum StudentGradeResult { passed, notPassed }

/// Información resumida de una calificación publicada.
class StudentGradeSummary {
  const StudentGradeSummary({
    required this.id,
    required this.examTitle,
    required this.subject,
    required this.score,
    required this.maximumScore,
    required this.result,
    required this.publishedAt,
  });

  final String id;
  final String examTitle;
  final String subject;
  final double score;
  final double maximumScore;
  final StudentGradeResult result;
  final DateTime publishedAt;

  /// Porcentaje obtenido respecto a la puntuación máxima.
  double get percentage {
    if (maximumScore <= 0) {
      return 0;
    }

    return (score / maximumScore) * 100;
  }
}

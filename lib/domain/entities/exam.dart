/// Estado de un examen según su publicación y su fecha de cierre.
enum ExamStatus { draft, published, closed }

/// Examen creado por el docente para un grupo.
///
/// `order`, `scale`, `platform` y `resultVisibility` conservan los valores
/// de la API (por ejemplo `aleatorio`, `0-10`, `movil`, `oculto`).
class Exam {
  const Exam({
    required this.id,
    required this.groupId,
    required this.name,
    required this.opensAt,
    required this.closesAt,
    required this.order,
    required this.scale,
    required this.platform,
    required this.isPublished,
    required this.resultVisibility,
  });

  final int id;
  final int groupId;
  final String name;
  final DateTime? opensAt;
  final DateTime? closesAt;
  final String order;
  final String scale;
  final String platform;
  final bool isPublished;
  final String resultVisibility;

  ExamStatus get status {
    if (!isPublished) {
      return ExamStatus.draft;
    }

    final cierre = closesAt;

    if (cierre != null && cierre.isBefore(DateTime.now())) {
      return ExamStatus.closed;
    }

    return ExamStatus.published;
  }
}
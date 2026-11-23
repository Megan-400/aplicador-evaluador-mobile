import '../../core/errors/app_exception.dart';
import '../entities/exam.dart';
import '../entities/exam_results.dart';
import '../entities/teacher_summary.dart';
import '../repositories/exams_repository.dart';
import '../repositories/groups_repository.dart';
import '../repositories/results_repository.dart';

/// Reúne grupos, exámenes y resultados en un solo resumen para el docente.
class GetTeacherSummary {
  GetTeacherSummary({
    required GroupsRepository groupsRepository,
    required ExamsRepository examsRepository,
    required ResultsRepository resultsRepository,
  }) : _groups = groupsRepository,
       _exams = examsRepository,
       _results = resultsRepository;

  final GroupsRepository _groups;
  final ExamsRepository _exams;
  final ResultsRepository _results;

  Future<TeacherSummary> call() async {
    final grupos = await _groups.getGroups();
    final examenes = await _exams.getExams();

    final borradores = _conEstado(examenes, ExamStatus.draft);
    final publicados = _conEstado(examenes, ExamStatus.published);
    final cerrados = _conEstado(examenes, ExamStatus.closed);

    final porCalificar = await _contarPorCalificar([
      ...publicados,
      ...cerrados,
    ]);

    final proximo = _proximoCierre(publicados);
    final materia = proximo == null
        ? null
        : grupos
              .where((grupo) => grupo.id == proximo.groupId)
              .map((grupo) => grupo.subject)
              .firstOrNull;

    return TeacherSummary(
      totalGroups: grupos.length,
      activeGroups: grupos.where((grupo) => grupo.isActive).length,
      draftExams: borradores.length,
      publishedExams: publicados.length,
      closedExams: cerrados.length,
      awaitingGrading: porCalificar,
      nextClosingExam: proximo,
      nextClosingSubject: materia,
    );
  }

  List<Exam> _conEstado(List<Exam> examenes, ExamStatus estado) {
    return examenes.where((examen) => examen.status == estado).toList();
  }

  /// Suma los intentos por calificar de todos los exámenes. Si la consulta
  /// falla, devuelve `null` en vez de impedir que se vea el resto del resumen.
  Future<int?> _contarPorCalificar(List<Exam> examenes) async {
    try {
      final resultados = await Future.wait<ExamResults>([
        for (final examen in examenes) _results.getExamResults(examen.id),
      ]);

      return resultados.fold<int>(
        0,
        (suma, resultado) => suma + resultado.awaitingGrading,
      );
    } on AppException {
      return null;
    }
  }

  Exam? _proximoCierre(List<Exam> publicados) {
    final conFecha = publicados.where((e) => e.closesAt != null).toList();

    if (conFecha.isEmpty) {
      return null;
    }

    conFecha.sort((a, b) => a.closesAt!.compareTo(b.closesAt!));

    return conFecha.first;
  }
}
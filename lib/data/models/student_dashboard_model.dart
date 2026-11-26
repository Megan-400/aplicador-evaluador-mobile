import '../../domain/entities/student_dashboard.dart';
import '../../domain/entities/student_exam_summary.dart';
import '../../domain/entities/student_grade_summary.dart';
import '../../domain/entities/student_group_summary.dart';

/// Convierte la respuesta del dashboard a entidades de dominio.
abstract final class StudentDashboardModel {
  static StudentDashboard fromJson(Map<String, dynamic> json) {
    final data = _map(json['data'], field: 'data');

    return StudentDashboard(
      student: _student(data),
      groups: _list(
        data['grupos'],
        field: 'data.grupos',
      ).map(_group).toList(growable: false),
      exams: _list(
        data['examenes'],
        field: 'data.examenes',
      ).map(_exam).toList(growable: false),
      grades: _list(
        data['entregas'],
        field: 'data.entregas',
      ).map(_grade).toList(growable: false),
    );
  }

  static StudentProfile _student(Map<String, dynamic> data) {
    final student = _map(data['alumno'], field: 'data.alumno');

    return StudentProfile(
      id: _int(student['id']),
      name: _string(student['nombre']),
      selectedGroupId: _int(student['grupo_id']),
    );
  }

  static StudentGroupSummary _group(Map<String, dynamic> json) {
    final subject = _string(json['materia']);

    return StudentGroupSummary(
      id: _int(json['id']).toString(),
      name: subject,
      subject: subject,
      period: '',
      status: _bool(json['activo'])
          ? StudentGroupStatus.active
          : StudentGroupStatus.completed,
      folioCode: _string(json['folio_codigo']),
      teacherName: _nullableString(json['docente']),
    );
  }

  static StudentExamSummary _exam(Map<String, dynamic> json) {
    final durationSeconds = _int(json['duracion_segundos']);

    return StudentExamSummary(
      id: _int(json['id']).toString(),
      title: _string(json['nombre']),
      subject: _string(json['materia']),
      status: _examStatus(_string(json['estado'])),
      durationMinutes: (durationSeconds / 60).ceil(),
      questionCount: _int(json['total_preguntas']),
      availableAt: _nullableDate(json['fecha_apertura']),
      dueAt: _nullableDate(json['fecha_cierre']),
    );
  }

  static StudentGradeSummary _grade(Map<String, dynamic> json) {
    final score = _nullableDouble(json['calificacion']);

    final maximumScore = _nullableDouble(json['escala']) ?? 100;

    return StudentGradeSummary(
      id: _int(json['id']).toString(),
      examTitle: _string(json['nombre']),
      subject: _string(json['materia']),
      score: score ?? 0,
      maximumScore: maximumScore,
      result: _gradeResult(_string(json['estado'])),
      publishedAt:
          _nullableDate(json['fecha_entrega']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static StudentExamStatus _examStatus(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(' ', '_');

    return switch (normalized) {
      'disponible' || 'en_progreso' => StudentExamStatus.available,

      'proximamente' || 'próximamente' => StudentExamStatus.upcoming,

      'completado' ||
      'finalizado' ||
      'entregado' => StudentExamStatus.completed,

      'cerrado' || 'anulado' => StudentExamStatus.closed,

      _ => throw FormatException('Estado de examen desconocido: $value'),
    };
  }

  static StudentGradeResult _gradeResult(String value) {
    return switch (value.toLowerCase()) {
      'aprobado' => StudentGradeResult.passed,
      'no_aprobado' ||
      'no aprobado' ||
      'reprobado' => StudentGradeResult.notPassed,
      'en_revision' => StudentGradeResult.pending,
      'sin_publicar' => StudentGradeResult.hidden,
      _ => StudentGradeResult.pending,
    };
  }

  static Map<String, dynamic> _map(Object? value, {required String field}) {
    if (value is! Map) {
      throw FormatException('El campo $field no tiene un formato válido.');
    }

    return Map<String, dynamic>.from(value);
  }

  static List<Map<String, dynamic>> _list(
    Object? value, {
    required String field,
  }) {
    if (value == null) {
      return const [];
    }

    if (value is! List) {
      throw FormatException('El campo $field no contiene una lista válida.');
    }

    return value
        .map((item) {
          if (item is! Map) {
            throw FormatException(
              'Un elemento de $field no tiene un formato válido.',
            );
          }

          return Map<String, dynamic>.from(item);
        })
        .toList(growable: false);
  }

  static String _string(Object? value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static String? _nullableString(Object? value) {
    final result = _string(value).trim();
    return result.isEmpty ? null : result;
  }

  static int _int(Object? value) {
    if (value is int) {
      return value;
    }

    return int.parse(value.toString());
  }

  static double? _nullableDouble(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    final normalized = value.toString().trim();

    if (normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }

  static bool _bool(Object? value) {
    if (value is bool) {
      return value;
    }

    return value.toString().toLowerCase() == 'true';
  }

  static DateTime? _nullableDate(Object? value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}

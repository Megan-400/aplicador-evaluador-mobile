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
      groups: _list(data['grupos']).map(_group).toList(),
      exams: _list(data['examenes']).map(_exam).toList(),
      grades: _list(data['entregas']).map(_grade).toList(),
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

    return StudentGradeSummary(
      id: _int(json['id']).toString(),
      examTitle: _string(json['nombre']),
      subject: _string(json['materia']),
      score: score ?? 0,
      maximumScore: _double(json['escala']),
      result: _gradeResult(_string(json['estado'])),
      publishedAt:
          _nullableDate(json['fecha_entrega']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static StudentExamStatus _examStatus(String value) {
    return switch (value.toLowerCase()) {
      'disponible' => StudentExamStatus.available,
      'proximamente' => StudentExamStatus.upcoming,
      'completado' => StudentExamStatus.completed,
      'cerrado' => StudentExamStatus.closed,
      _ => throw const FormatException('Estado de examen desconocido.'),
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
    if (value is! Map<String, dynamic>) {
      throw FormatException('El campo $field no tiene un formato válido.');
    }

    return value;
  }

  static List<Map<String, dynamic>> _list(Object? value) {
    if (value == null) {
      return const [];
    }

    if (value is! List) {
      throw const FormatException('La colección no tiene un formato válido.');
    }

    return value.map((item) => Map<String, dynamic>.from(item as Map)).toList();
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

  static double _double(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.parse(value.toString());
  }

  static double? _nullableDouble(Object? value) {
    if (value == null) {
      return null;
    }

    return _double(value);
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

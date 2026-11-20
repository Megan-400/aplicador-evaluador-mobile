import 'package:aplicador_evaluador_mobile/data/models/student_dashboard_model.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_exam_summary.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_grade_summary.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_group_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentDashboardModel', () {
    test('convierte correctamente la respuesta completa de la API', () {
      final dashboard = StudentDashboardModel.fromJson({
        'data': {
          'alumno': {'id': 14, 'nombre': 'Alumno de prueba', 'grupo_id': 8},
          'grupos': [
            {
              'id': 8,
              'materia': 'Matemáticas',
              'folio_codigo': 'FOLIO123',
              'activo': true,
              'docente': 'Docente de prueba',
            },
          ],
          'examenes': [
            {
              'id': 22,
              'nombre': 'Evaluación parcial',
              'materia': 'Matemáticas',
              'fecha_apertura': '2026-11-20T10:00:00-06:00',
              'fecha_cierre': '2026-11-20T12:00:00-06:00',
              'total_preguntas': 20,
              'duracion_segundos': 2700,
              'estado': 'disponible',
            },
          ],
          'entregas': [
            {
              'id': 35,
              'nombre': 'Evaluación diagnóstica',
              'materia': 'Matemáticas',
              'fecha_entrega': '2026-11-19T11:20:00-06:00',
              'escala': 10,
              'estado': 'aprobado',
              'calificacion': 8.5,
            },
          ],
        },
      });

      expect(dashboard.student.id, 14);
      expect(dashboard.student.name, 'Alumno de prueba');
      expect(dashboard.student.selectedGroupId, 8);

      expect(dashboard.groups, hasLength(1));
      expect(dashboard.exams, hasLength(1));
      expect(dashboard.grades, hasLength(1));

      final group = dashboard.groups.single;

      expect(group.id, '8');
      expect(group.name, 'Matemáticas');
      expect(group.subject, 'Matemáticas');
      expect(group.folioCode, 'FOLIO123');
      expect(group.status, StudentGroupStatus.active);
      expect(group.teacherName, 'Docente de prueba');

      final exam = dashboard.exams.single;

      expect(exam.id, '22');
      expect(exam.title, 'Evaluación parcial');
      expect(exam.subject, 'Matemáticas');
      expect(exam.status, StudentExamStatus.available);
      expect(exam.durationMinutes, 45);
      expect(exam.questionCount, 20);
      expect(exam.availableAt, isNotNull);
      expect(exam.dueAt, isNotNull);

      final grade = dashboard.grades.single;

      expect(grade.id, '35');
      expect(grade.examTitle, 'Evaluación diagnóstica');
      expect(grade.subject, 'Matemáticas');
      expect(grade.score, 8.5);
      expect(grade.maximumScore, 10);
      expect(grade.result, StudentGradeResult.passed);
      expect(grade.publishedAt.year, 2026);
    });

    test('convierte colecciones vacías de la API', () {
      final dashboard = StudentDashboardModel.fromJson({
        'data': {
          'alumno': {'id': 14, 'nombre': 'Alumno de prueba', 'grupo_id': 8},
          'grupos': <Object>[],
          'examenes': <Object>[],
          'entregas': <Object>[],
        },
      });

      expect(dashboard.groups, isEmpty);
      expect(dashboard.exams, isEmpty);
      expect(dashboard.grades, isEmpty);
    });

    test('convierte los segundos a minutos redondeando hacia arriba', () {
      final dashboard = StudentDashboardModel.fromJson({
        'data': {
          'alumno': {'id': 14, 'nombre': 'Alumno de prueba', 'grupo_id': 8},
          'grupos': <Object>[],
          'examenes': [
            {
              'id': 22,
              'nombre': 'Evaluación parcial',
              'materia': 'Matemáticas',
              'fecha_apertura': null,
              'fecha_cierre': null,
              'total_preguntas': 20,
              'duracion_segundos': 2720,
              'estado': 'disponible',
            },
          ],
          'entregas': <Object>[],
        },
      });

      expect(dashboard.exams.single.durationMinutes, 46);
    });

    test('convierte todos los estados conocidos de examen', () {
      final dashboard = StudentDashboardModel.fromJson({
        'data': {
          'alumno': {'id': 14, 'nombre': 'Alumno de prueba', 'grupo_id': 8},
          'grupos': <Object>[],
          'examenes': [
            _examJson(id: 1, state: 'disponible'),
            _examJson(id: 2, state: 'proximamente'),
            _examJson(id: 3, state: 'completado'),
            _examJson(id: 4, state: 'cerrado'),
          ],
          'entregas': <Object>[],
        },
      });

      expect(dashboard.exams.map((exam) => exam.status), [
        StudentExamStatus.available,
        StudentExamStatus.upcoming,
        StudentExamStatus.completed,
        StudentExamStatus.closed,
      ]);
    });

    test('convierte los estados pendientes de las entregas', () {
      final dashboard = StudentDashboardModel.fromJson({
        'data': {
          'alumno': {'id': 14, 'nombre': 'Alumno de prueba', 'grupo_id': 8},
          'grupos': <Object>[],
          'examenes': <Object>[],
          'entregas': [
            _gradeJson(id: 1, state: 'en_revision'),
            _gradeJson(id: 2, state: 'sin_publicar'),
          ],
        },
      });

      expect(dashboard.grades.map((grade) => grade.result), [
        StudentGradeResult.pending,
        StudentGradeResult.hidden,
      ]);
    });

    test('rechaza un estado desconocido de examen', () {
      expect(
        () => StudentDashboardModel.fromJson({
          'data': {
            'alumno': {'id': 14, 'nombre': 'Alumno de prueba', 'grupo_id': 8},
            'grupos': <Object>[],
            'examenes': [_examJson(id: 1, state: 'estado_desconocido')],
            'entregas': <Object>[],
          },
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rechaza una respuesta sin el objeto data', () {
      expect(
        () => StudentDashboardModel.fromJson(<String, dynamic>{}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

Map<String, dynamic> _examJson({required int id, required String state}) {
  return {
    'id': id,
    'nombre': 'Evaluación $id',
    'materia': 'Matemáticas',
    'fecha_apertura': null,
    'fecha_cierre': null,
    'total_preguntas': 10,
    'duracion_segundos': 600,
    'estado': state,
  };
}

Map<String, dynamic> _gradeJson({required int id, required String state}) {
  return {
    'id': id,
    'nombre': 'Evaluación $id',
    'materia': 'Matemáticas',
    'fecha_entrega': '2026-11-19T11:20:00-06:00',
    'escala': 10,
    'estado': state,
    'calificacion': null,
  };
}

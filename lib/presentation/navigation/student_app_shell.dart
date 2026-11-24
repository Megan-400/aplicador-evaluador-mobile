import 'package:flutter/material.dart';

import '../screens/student/exams/student_exams_screen.dart';
import '../screens/student/grades/student_grades_screen.dart';
import '../screens/student/groups/student_groups_screen.dart';
import '../screens/student/home/student_home_screen.dart';
import '../../domain/entities/student_dashboard.dart';
import '../screens/student/profile/student_profile_screen.dart';
import '../../domain/entities/student_exam_summary.dart';
import '../../domain/entities/student_session_credentials.dart';
import '../screens/student/exams/detail/student_exam_detail_screen.dart';
import '../state/attempts/start_exam_attempt_controller.dart';
import '../screens/student/attempt/student_exam_attempt_screen.dart';
import '../state/questions/exam_questions_controller.dart';
import '../state/answers/save_answers_controller.dart';
import '../state/finish/finish_exam_attempt_controller.dart';

/// Contenedor principal de navegación del portal móvil del alumno.
/// `IndexedStack` conserva el estado básico de cada pantalla cuando el alumno
/// cambia de destino.
class StudentAppShell extends StatefulWidget {
  const StudentAppShell({
    required this.dashboard,
    required this.credentials,
    required this.startAttemptController,
    required this.questionsController,
    required this.saveAnswersController,
    required this.finishAttemptController,
    required this.onRefreshDashboard,
    required this.dashboardErrorMessage,
    required this.onSignOut,
    super.key,
  });

  final StudentDashboard dashboard;
  final StudentSessionCredentials credentials;
  final StartExamAttemptController startAttemptController;
  final ExamQuestionsController questionsController;
  final SaveAnswersController saveAnswersController;
  final FinishExamAttemptController finishAttemptController;
  final Future<bool> Function() onRefreshDashboard;
  final String? Function() dashboardErrorMessage;
  final VoidCallback onSignOut;

  @override
  State<StudentAppShell> createState() => _StudentAppShellState();
}

class _StudentAppShellState extends State<StudentAppShell> {
  int _selectedIndex = 0;

  /// Cambia el destino seleccionado en la navegación inferior.
  void _selectDestination(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return StudentProfileScreen(
            dashboard: widget.dashboard,
            onSignOut: _requestSignOut,
          );
        },
      ),
    );
  }

  Future<void> _requestSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text(
            'Tendrás que ingresar nuevamente tu folio y '
            'código personal para acceder.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              key: const Key('confirm-student-sign-out-button'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final navigator = Navigator.of(context);

    navigator.popUntil((route) => route.isFirst);

    widget.onSignOut();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      StudentHomeScreen(
        onOpenExams: () => _selectDestination(1),
        onOpenGrades: () => _selectDestination(2),
        onOpenGroups: () => _selectDestination(3),
        onOpenProfile: _openProfile,
        studentName: widget.dashboard.student.name,
      ),
      StudentExamsScreen(
        exams: widget.dashboard.exams,
        onOpenExam: _openExamDetail,
      ),
      StudentGradesScreen(grades: widget.dashboard.grades),
      StudentGroupsScreen(groups: widget.dashboard.groups),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: destinations),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Exámenes',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Calificaciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Mis grupos',
          ),
        ],
      ),
    );
  }

  Future<void> _openExamDetail(StudentExamSummary exam) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (detailContext) {
          return StudentExamDetailScreen(
            exam: exam,
            startErrorMessage: () => widget.startAttemptController.errorMessage,
            onStartExam: (_) async {
              final examId = int.tryParse(exam.id);

              if (examId == null) {
                return false;
              }

              final navigator = Navigator.of(detailContext);

              final started = await widget.startAttemptController.start(
                folio: widget.credentials.folio,
                accessCode: widget.credentials.accessCode,
                examId: examId,
              );

              if (!started || !mounted || !navigator.mounted) {
                return false;
              }

              final attempt = widget.startAttemptController.attempt;

              if (attempt == null) {
                return false;
              }

              widget.questionsController.reset();
              widget.saveAnswersController.reset();
              widget.finishAttemptController.reset();

              final delivered = await navigator.pushReplacement<bool, void>(
                MaterialPageRoute<bool>(
                  builder: (context) {
                    return StudentExamAttemptScreen(
                      exam: exam,
                      attempt: attempt,
                      questionsController: widget.questionsController,
                      saveAnswersController: widget.saveAnswersController,
                      finishAttemptController: widget.finishAttemptController,
                    );
                  },
                ),
              );

              if (delivered != true) {
                return true;
              }

              widget.saveAnswersController.reset();
              widget.questionsController.reset();
              widget.startAttemptController.reset();

              final refreshed = await widget.onRefreshDashboard();

              if (!mounted) {
                return true;
              }

              widget.finishAttemptController.reset();

              if (refreshed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'El examen fue entregado y el portal '
                      'se actualizó.',
                    ),
                  ),
                );

                return true;
              }

              final refreshError = widget.dashboardErrorMessage();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    refreshError ??
                        'El examen fue entregado, pero no fue '
                            'posible actualizar el portal.',
                  ),
                  action: SnackBarAction(
                    label: 'Actualizar',
                    onPressed: () {
                      _retryDashboardRefresh();
                    },
                  ),
                ),
              );

              return true;
            },
          );
        },
      ),
    );
  }

  Future<void> _retryDashboardRefresh() async {
    final refreshed = await widget.onRefreshDashboard();

    if (!mounted) {
      return;
    }

    final message = refreshed
        ? 'El portal se actualizó correctamente.'
        : widget.dashboardErrorMessage() ??
              'No fue posible actualizar el portal.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: refreshed
            ? null
            : SnackBarAction(
                label: 'Reintentar',
                onPressed: () {
                  _retryDashboardRefresh();
                },
              ),
      ),
    );
  }
}

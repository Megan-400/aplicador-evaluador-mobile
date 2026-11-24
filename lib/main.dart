import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/remote/student_dashboard_remote_data_source.dart';
import 'data/repositories/student_dashboard_repository_impl.dart';
import 'domain/usecases/load_student_dashboard.dart';
import 'presentation/screens/student/access/student_access_screen.dart';
import 'presentation/state/student_dashboard_controller.dart';
import 'presentation/navigation/student_app_shell.dart';
import 'data/datasources/remote/attempts/student_exam_attempt_remote_data_source.dart';
import 'data/repositories/attempts/student_exam_attempt_repository_impl.dart';
import 'domain/usecases/attempts/start_student_exam_attempt.dart';
import 'presentation/state/attempts/start_exam_attempt_controller.dart';
import 'data/datasources/remote/questions/student_exam_questions_remote_data_source.dart';
import 'data/repositories/questions/student_exam_questions_repository_impl.dart';
import 'domain/usecases/questions/load_student_exam_questions.dart';
import 'presentation/state/questions/exam_questions_controller.dart';
import 'data/datasources/remote/answers/student_answer_remote_data_source.dart';
import 'data/repositories/answers/student_answer_repository_impl.dart';
import 'domain/usecases/answers/save_student_answer.dart';
import 'presentation/state/answers/save_answers_controller.dart';
import 'data/datasources/remote/finish/student_finish_attempt_remote_data_source.dart';
import 'data/repositories/finish/student_finish_attempt_repository_impl.dart';
import 'domain/usecases/finish/finish_student_exam_attempt.dart';
import 'presentation/state/finish/finish_exam_attempt_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StudentDashboardRemoteDataSource _remoteDataSource;
  late final StudentDashboardController _controller;
  late final StudentExamAttemptRemoteDataSource _attemptRemoteDataSource;
  late final StartExamAttemptController _startAttemptController;
  late final StudentExamQuestionsRemoteDataSource _questionsRemoteDataSource;
  late final ExamQuestionsController _questionsController;
  late final StudentAnswerRemoteDataSource _answerRemoteDataSource;
  late final SaveAnswersController _saveAnswersController;
  late final StudentFinishAttemptRemoteDataSource _finishRemoteDataSource;
  late final FinishExamAttemptController _finishAttemptController;

  @override
  void initState() {
    super.initState();

    _remoteDataSource = StudentDashboardRemoteDataSource();

    final repository = StudentDashboardRepositoryImpl(
      remoteDataSource: _remoteDataSource,
    );

    _controller = StudentDashboardController(
      loadDashboard: LoadStudentDashboard(repository: repository),
    );

    _attemptRemoteDataSource = StudentExamAttemptRemoteDataSource();

    final attemptRepository = StudentExamAttemptRepositoryImpl(
      remoteDataSource: _attemptRemoteDataSource,
    );

    _startAttemptController = StartExamAttemptController(
      startAttempt: StartStudentExamAttempt(repository: attemptRepository),
    );

    _questionsRemoteDataSource = StudentExamQuestionsRemoteDataSource();

    final questionsRepository = StudentExamQuestionsRepositoryImpl(
      remoteDataSource: _questionsRemoteDataSource,
    );

    _questionsController = ExamQuestionsController(
      loadQuestions: LoadStudentExamQuestions(repository: questionsRepository),
    );

    _answerRemoteDataSource = StudentAnswerRemoteDataSource();

    final answerRepository = StudentAnswerRepositoryImpl(
      remoteDataSource: _answerRemoteDataSource,
    );

    _saveAnswersController = SaveAnswersController(
      saveAnswer: SaveStudentAnswer(repository: answerRepository),
    );

    _finishRemoteDataSource = StudentFinishAttemptRemoteDataSource();

    final finishRepository = StudentFinishAttemptRepositoryImpl(
      remoteDataSource: _finishRemoteDataSource,
    );

    _finishAttemptController = FinishExamAttemptController(
      finishAttempt: FinishStudentExamAttempt(repository: finishRepository),
    );
  }

  @override
  void dispose() {
    _finishAttemptController.dispose();
    _saveAnswersController.dispose();
    _questionsController.dispose();
    _startAttemptController.dispose();
    _controller.dispose();
    _finishRemoteDataSource.close();
    _answerRemoteDataSource.close();
    _questionsRemoteDataSource.close();
    _attemptRemoteDataSource.close();
    _remoteDataSource.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicador/Evaluador de Exámenes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final dashboard = _controller.dashboard;
          final credentials = _controller.credentials;

          if (dashboard == null || credentials == null) {
            return StudentAccessScreen(controller: _controller);
          }

          return StudentAppShell(
            dashboard: dashboard,
            credentials: credentials,
            startAttemptController: _startAttemptController,
            questionsController: _questionsController,
            saveAnswersController: _saveAnswersController,
            finishAttemptController: _finishAttemptController,
            onRefreshDashboard: _controller.refresh,
            dashboardErrorMessage: () => _controller.errorMessage,
            onSignOut: () {
              _finishAttemptController.reset();
              _saveAnswersController.reset();
              _questionsController.reset();
              _startAttemptController.reset();
              _controller.signOut();
            },
          );
        },
      ),
    );
  }
}

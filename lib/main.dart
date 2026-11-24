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
  }

  @override
  void dispose() {
    _controller.dispose();
    _remoteDataSource.close();
    _startAttemptController.dispose();
    _attemptRemoteDataSource.close();
    _questionsController.dispose();
    _questionsRemoteDataSource.close();
    _saveAnswersController.dispose();
    _answerRemoteDataSource.close();
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
            saveAnswersController: _saveAnswersController,
            startAttemptController: _startAttemptController,
            questionsController: _questionsController,
            onSignOut: () {
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

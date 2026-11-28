import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/enrollment/student_enrollment.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_dashboard.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/enrollment/student_enrollment_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/student_dashboard_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/enrollment/create_student_enrollment.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/load_student_dashboard.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/access/student_access_screen.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/enrollment/student_enrollment_screen.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/enrollment/student_enrollment_controller.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/student_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<_Dependencies> buildScreen(
    WidgetTester tester, {
    StudentDashboardRepository? dashboardRepository,
    StudentEnrollmentRepository? enrollmentRepository,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    final resolvedDashboardRepository =
        dashboardRepository ?? _SuccessDashboardRepository();

    final resolvedEnrollmentRepository =
        enrollmentRepository ?? _SuccessEnrollmentRepository();

    final dashboardController = StudentDashboardController(
      loadDashboard: LoadStudentDashboard(
        repository: resolvedDashboardRepository,
      ),
    );

    final enrollmentController = StudentEnrollmentController(
      createEnrollment: CreateStudentEnrollment(
        repository: resolvedEnrollmentRepository,
      ),
    );

    addTearDown(dashboardController.dispose);
    addTearDown(enrollmentController.dispose);

    await tester.binding.setSurfaceSize(const Size(800, 900));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: StudentAccessScreen(
          controller: dashboardController,
          enrollmentController: enrollmentController,
        ),
      ),
    );

    await tester.pumpAndSettle();

    return _Dependencies(
      dashboardController: dashboardController,
      enrollmentController: enrollmentController,
      dashboardRepository: resolvedDashboardRepository,
      enrollmentRepository: resolvedEnrollmentRepository,
    );
  }

  Future<void> continueWithFolio(
    WidgetTester tester, {
    String folio = 'GRUPO1',
  }) async {
    final folioField = find.byKey(const Key('student-folio-field'));

    await tester.enterText(folioField, folio);

    await tester.pump();

    final continueButton = find.byKey(
      const Key('student-folio-continue-button'),
    );

    await tester.ensureVisible(continueButton);

    await tester.tap(continueButton);

    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).last,
    );

    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('muestra inicialmente el paso del folio', (tester) async {
    await buildScreen(tester);

    expect(find.byKey(const Key('student-folio-field')), findsOneWidget);

    expect(
      find.byKey(const Key('student-folio-continue-button')),
      findsOneWidget,
    );

    expect(find.byKey(const Key('student-access-mode-selector')), findsNothing);
  });

  testWidgets('normaliza el folio antes de continuar', (tester) async {
    await buildScreen(tester);

    await continueWithFolio(tester, folio: 'grupo1');

    expect(find.text('GRUPO1'), findsOneWidget);

    expect(
      find.byKey(const Key('student-access-mode-selector')),
      findsOneWidget,
    );
  });

  testWidgets('muestra los modos Primera vez y Ya tengo código', (
    tester,
  ) async {
    await buildScreen(tester);
    await continueWithFolio(tester);

    expect(find.text('Primera vez'), findsOneWidget);

    expect(find.text('Ya tengo código'), findsOneWidget);

    // El flujo existente se mantiene seleccionado.
    expect(find.byKey(const Key('student-access-code-field')), findsOneWidget);
  });

  testWidgets('abre la inscripción al seleccionar Primera vez', (tester) async {
    await buildScreen(tester);
    await continueWithFolio(tester);

    await tester.tap(find.text('Primera vez'));
    await tester.pumpAndSettle();

    final enrollmentButton = find.byKey(
      const Key('open-student-enrollment-button'),
    );

    await tester.ensureVisible(enrollmentButton);
    await tester.pumpAndSettle();

    expect(enrollmentButton, findsOneWidget);

    await tester.tap(enrollmentButton);
    await tester.pumpAndSettle();

    expect(find.byType(StudentEnrollmentScreen), findsOneWidget);

    expect(find.text('Crear perfil'), findsWidgets);

    expect(find.text('GRUPO1'), findsWidgets);
  });

  testWidgets('conserva el acceso existente con código personal', (
    tester,
  ) async {
    await buildScreen(tester);
    await continueWithFolio(tester);

    expect(find.byKey(const Key('student-access-code-field')), findsOneWidget);

    expect(find.byKey(const Key('student-access-button')), findsOneWidget);

    expect(
      find.byKey(const Key('open-student-enrollment-button')),
      findsNothing,
    );
  });

  testWidgets('cambia entre los dos modos de acceso', (tester) async {
    await buildScreen(tester);
    await continueWithFolio(tester);

    await tester.tap(find.text('Primera vez'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('open-student-enrollment-button')),
      findsOneWidget,
    );

    expect(find.byKey(const Key('student-access-code-field')), findsNothing);

    await tester.tap(find.text('Ya tengo código'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('student-access-code-field')), findsOneWidget);

    expect(
      find.byKey(const Key('open-student-enrollment-button')),
      findsNothing,
    );
  });

  testWidgets('ingresa con el código personal existente', (tester) async {
    final repository = _SuccessDashboardRepository();

    final dependencies = await buildScreen(
      tester,
      dashboardRepository: repository,
    );

    await continueWithFolio(tester);

    final codeField = find.byKey(const Key('student-access-code-field'));

    await tester.enterText(codeField, 'abcd27');
    await tester.pump();

    final accessButton = find.byKey(const Key('student-access-button'));

    await tester.ensureVisible(accessButton);
    await tester.pumpAndSettle();

    await tester.tap(accessButton);
    await tester.pumpAndSettle();

    expect(repository.callCount, 1);
    expect(repository.receivedFolio, 'GRUPO1');
    expect(repository.receivedAccessCode, 'ABCD27');

    expect(dependencies.dashboardController.dashboard, isNotNull);
  });

  testWidgets('regresa al paso del grupo', (tester) async {
    await buildScreen(tester);
    await continueWithFolio(tester);

    final returnButton = find.byKey(const Key('return-to-group-button'));

    await tapVisible(tester, returnButton);

    expect(find.byKey(const Key('student-folio-field')), findsOneWidget);

    expect(find.byKey(const Key('student-access-mode-selector')), findsNothing);
  });

  testWidgets('muestra el error de acceso existente', (tester) async {
    await buildScreen(
      tester,
      dashboardRepository: _FailureDashboardRepository(),
    );

    await continueWithFolio(tester);

    await tester.enterText(
      find.byKey(const Key('student-access-code-field')),
      'ABCD27',
    );

    await tester.pump();

    final accessButton = find.byKey(const Key('student-access-button'));

    await tester.ensureVisible(accessButton);
    await tester.tap(accessButton);
    await tester.pumpAndSettle();

    expect(find.text('El código personal no es válido.'), findsOneWidget);
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildScreen(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentAccessScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
  });
}

class _Dependencies {
  const _Dependencies({
    required this.dashboardController,
    required this.enrollmentController,
    required this.dashboardRepository,
    required this.enrollmentRepository,
  });

  final StudentDashboardController dashboardController;

  final StudentEnrollmentController enrollmentController;

  final StudentDashboardRepository dashboardRepository;

  final StudentEnrollmentRepository enrollmentRepository;
}

class _SuccessDashboardRepository implements StudentDashboardRepository {
  int callCount = 0;
  String? receivedFolio;
  String? receivedAccessCode;

  @override
  Future<StudentDashboard> load({
    required String folio,
    required String accessCode,
  }) async {
    callCount++;
    receivedFolio = folio;
    receivedAccessCode = accessCode;

    return const StudentDashboard(
      student: StudentProfile(
        id: 17,
        name: 'Ana María Pérez',
        selectedGroupId: 4,
      ),
      groups: [],
      exams: [],
      grades: [],
    );
  }
}

class _FailureDashboardRepository implements StudentDashboardRepository {
  @override
  Future<StudentDashboard> load({
    required String folio,
    required String accessCode,
  }) {
    throw const ApiException(
      type: ApiFailureType.invalidCredentials,
      statusCode: 401,
      message: 'El código personal no es válido.',
    );
  }
}

class _SuccessEnrollmentRepository implements StudentEnrollmentRepository {
  @override
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) async {
    return StudentEnrollment(
      studentId: 17,
      groupId: 4,
      subject: 'Historia',
      studentName: studentName,
      status: 'inscrito',
      mode: 'nuevo',
      credentialVersion: 1,
      accessCode: 'ABCD27',
    );
  }
}

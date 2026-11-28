import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/enrollment/student_enrollment.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/enrollment/student_enrollment_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/enrollment/create_student_enrollment.dart';
import 'package:aplicador_evaluador_mobile/presentation/screens/student/enrollment/student_enrollment_screen.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/enrollment/student_enrollment_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<_Dependencies> buildScreen(
    WidgetTester tester, {
    StudentEnrollmentRepository? repository,
    ThemeMode themeMode = ThemeMode.light,
    Future<void> Function({
      required String groupFolio,
      required String accessCode,
    })?
    onContinue,
  }) async {
    final resolvedRepository = repository ?? _SuccessEnrollmentRepository();

    final controller = StudentEnrollmentController(
      createEnrollment: CreateStudentEnrollment(repository: resolvedRepository),
    );

    addTearDown(controller.dispose);

    await tester.binding.setSurfaceSize(const Size(800, 900));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    var continuedFolio = '';
    var continuedCode = '';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: StudentEnrollmentScreen(
          groupFolio: 'GRUPO1',
          controller: controller,
          onContinue:
              onContinue ??
              ({required groupFolio, required accessCode}) async {
                continuedFolio = groupFolio;
                continuedCode = accessCode;
              },
        ),
      ),
    );

    await tester.pumpAndSettle();

    return _Dependencies(
      controller: controller,
      repository: resolvedRepository,
      continuedFolio: () => continuedFolio,
      continuedCode: () => continuedCode,
    );
  }

  Future<void> createProfile(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('student-enrollment-name-field')),
      'Ana María Pérez',
    );

    await tester.tap(find.byKey(const Key('create-student-profile-button')));

    await tester.pumpAndSettle();
  }

  testWidgets('muestra el formulario de primera inscripción', (tester) async {
    await buildScreen(tester);

    expect(find.text('Primera vez'), findsOneWidget);

    expect(find.text('GRUPO1'), findsOneWidget);

    expect(
      find.byKey(const Key('student-enrollment-name-field')),
      findsOneWidget,
    );

    expect(
      find.byKey(const Key('create-student-profile-button')),
      findsOneWidget,
    );
  });

  Future<void> acknowledgeCode(WidgetTester tester) async {
    final acknowledgement = find.byKey(
      const Key('enrollment-code-acknowledgement'),
    );

    final scrollable = find.byType(Scrollable).last;

    await tester.scrollUntilVisible(
      acknowledgement,
      300,
      scrollable: scrollable,
    );

    await tester.pumpAndSettle();

    await tester.tap(acknowledgement);

    await tester.pumpAndSettle();
  }

  testWidgets('valida un nombre vacío sin llamar al repositorio', (
    tester,
  ) async {
    final repository = _SuccessEnrollmentRepository();

    await buildScreen(tester, repository: repository);

    await tester.tap(find.byKey(const Key('create-student-profile-button')));

    await tester.pump();

    expect(find.text('Escribe tu nombre completo.'), findsOneWidget);

    expect(repository.callCount, 0);
  });

  testWidgets('crea el perfil y muestra el código', (tester) async {
    final repository = _SuccessEnrollmentRepository();

    await buildScreen(tester, repository: repository);

    await createProfile(tester);

    expect(repository.callCount, 1);
    expect(repository.receivedFolio, 'GRUPO1');
    expect(repository.receivedName, 'Ana María Pérez');

    expect(find.text('Inscripción completada'), findsOneWidget);

    expect(find.text('Historia'), findsOneWidget);

    expect(find.text('ABCD27'), findsOneWidget);

    expect(
      find.byKey(const Key('copy-enrollment-code-button')),
      findsOneWidget,
    );
  });

  testWidgets('copia el código al portapapeles', (tester) async {
    String? clipboardText;

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final arguments = call.arguments as Map<dynamic, dynamic>;

          clipboardText = arguments['text']?.toString();
        }

        return null;
      },
    );

    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await buildScreen(tester);
    await createProfile(tester);

    final copyButton = find.byKey(const Key('copy-enrollment-code-button'));

    await tester.scrollUntilVisible(
      copyButton,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(clipboardText, 'ABCD27');

    expect(find.text('Código personal copiado.'), findsOneWidget);
  });

  testWidgets('requiere reconocer que el código fue guardado', (tester) async {
    await buildScreen(tester);
    await createProfile(tester);

    final continueButton = find.byKey(
      const Key('continue-after-enrollment-button'),
    );

    var button = tester.widget<ElevatedButton>(continueButton);

    expect(button.onPressed, isNull);

    await acknowledgeCode(tester);

    await tester.scrollUntilVisible(
      continueButton,
      200,
      scrollable: find.byType(Scrollable).last,
    );

    await tester.pumpAndSettle();

    button = tester.widget<ElevatedButton>(continueButton);

    expect(button.onPressed, isNotNull);
  });

  testWidgets('continúa usando el folio y código generados', (tester) async {
    final dependencies = await buildScreen(tester);

    await createProfile(tester);
    await acknowledgeCode(tester);

    final continueButton = find.byKey(
      const Key('continue-after-enrollment-button'),
    );

    await tester.scrollUntilVisible(
      continueButton,
      200,
      scrollable: find.byType(Scrollable).last,
    );

    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(continueButton);

    expect(button.onPressed, isNotNull);

    await tester.tap(continueButton);

    await tester.pumpAndSettle();

    expect(dependencies.continuedFolio(), 'GRUPO1');

    expect(dependencies.continuedCode(), 'ABCD27');
  });

  testWidgets('muestra un error de creación', (tester) async {
    await buildScreen(tester, repository: _FailureEnrollmentRepository());

    await createProfile(tester);

    expect(find.text('El grupo alcanzó su límite de alumnos.'), findsOneWidget);

    expect(
      find.byKey(const Key('student-enrollment-name-field')),
      findsOneWidget,
    );

    expect(find.text('Ana María Pérez'), findsOneWidget);
  });

  testWidgets('advierte antes de salir sin reconocer el código', (
    tester,
  ) async {
    await buildScreen(tester);
    await createProfile(tester);

    await tester.tap(find.byKey(const Key('enrollment-exit-button')));

    await tester.pumpAndSettle();

    expect(find.text('¿Ya guardaste tu código?'), findsOneWidget);

    expect(find.text('Permanecer aquí'), findsOneWidget);

    expect(
      find.byKey(const Key('confirm-exit-enrollment-button')),
      findsOneWidget,
    );
  });

  testWidgets('funciona con el tema oscuro', (tester) async {
    await buildScreen(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(StudentEnrollmentScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
  });
}

class _Dependencies {
  const _Dependencies({
    required this.controller,
    required this.repository,
    required this.continuedFolio,
    required this.continuedCode,
  });

  final StudentEnrollmentController controller;
  final StudentEnrollmentRepository repository;
  final String Function() continuedFolio;
  final String Function() continuedCode;
}

class _SuccessEnrollmentRepository implements StudentEnrollmentRepository {
  int callCount = 0;
  String? receivedFolio;
  String? receivedName;

  @override
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) async {
    callCount++;
    receivedFolio = groupFolio;
    receivedName = studentName;

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

class _FailureEnrollmentRepository implements StudentEnrollmentRepository {
  @override
  Future<StudentEnrollment> create({
    required String groupFolio,
    required String studentName,
  }) {
    throw const ApiException(
      type: ApiFailureType.groupUnavailable,
      statusCode: 402,
      message: 'El grupo alcanzó su límite de alumnos.',
    );
  }
}

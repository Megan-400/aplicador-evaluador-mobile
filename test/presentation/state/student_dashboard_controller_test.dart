import 'dart:async';

import 'package:aplicador_evaluador_mobile/core/network/api_exception.dart';
import 'package:aplicador_evaluador_mobile/domain/entities/student_dashboard.dart';
import 'package:aplicador_evaluador_mobile/domain/repositories/student_dashboard_repository.dart';
import 'package:aplicador_evaluador_mobile/domain/usecases/load_student_dashboard.dart';
import 'package:aplicador_evaluador_mobile/presentation/state/student_dashboard_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StudentDashboardController', () {
    test('inicia sin dashboard ni mensaje de error', () {
      final controller = _buildController(
        repository: _FakeStudentDashboardRepository.success(
          dashboard: _dashboard,
        ),
      );

      expect(controller.status, StudentDashboardStatus.initial);
      expect(controller.dashboard, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);

      controller.dispose();
    });

    test('carga correctamente el dashboard', () async {
      final repository = _FakeStudentDashboardRepository.success(
        dashboard: _dashboard,
      );

      final controller = _buildController(repository: repository);

      final result = await controller.signIn(
        folio: 'folio123',
        accessCode: 'abcd27',
      );

      expect(result, isTrue);
      expect(controller.status, StudentDashboardStatus.success);
      expect(controller.dashboard, same(_dashboard));
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);

      expect(repository.receivedFolio, 'FOLIO123');
      expect(repository.receivedAccessCode, 'ABCD27');

      controller.dispose();
    });

    test('notifica el estado de carga antes de completar', () async {
      final repository = _PendingStudentDashboardRepository();

      final controller = _buildController(repository: repository);

      final signInFuture = controller.signIn(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
      );

      expect(controller.status, StudentDashboardStatus.loading);
      expect(controller.isLoading, isTrue);
      expect(controller.dashboard, isNull);

      repository.complete(_dashboard);

      final result = await signInFuture;

      expect(result, isTrue);
      expect(controller.status, StudentDashboardStatus.success);
      expect(controller.isLoading, isFalse);

      controller.dispose();
    });

    test('expone un error controlado de la API', () async {
      const exception = ApiException(
        type: ApiFailureType.invalidCredentials,
        statusCode: 401,
        message: 'El código personal no es válido.',
      );

      final controller = _buildController(
        repository: _FakeStudentDashboardRepository.failure(
          exception: exception,
        ),
      );

      final result = await controller.signIn(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
      );

      expect(result, isFalse);
      expect(controller.status, StudentDashboardStatus.failure);
      expect(controller.dashboard, isNull);
      expect(controller.errorMessage, 'El código personal no es válido.');
      expect(controller.isLoading, isFalse);

      controller.dispose();
    });

    test('expone un mensaje ante un error inesperado', () async {
      final controller = _buildController(
        repository: _FakeStudentDashboardRepository.unexpectedFailure(),
      );

      final result = await controller.signIn(
        folio: 'FOLIO123',
        accessCode: 'ABCD27',
      );

      expect(result, isFalse);
      expect(controller.status, StudentDashboardStatus.failure);
      expect(
        controller.errorMessage,
        'Ocurrió un error inesperado. Inténtalo nuevamente.',
      );

      controller.dispose();
    });

    test('cierra la sesión local y elimina el dashboard', () async {
      final controller = _buildController(
        repository: _FakeStudentDashboardRepository.success(
          dashboard: _dashboard,
        ),
      );

      await controller.signIn(folio: 'FOLIO123', accessCode: 'ABCD27');

      expect(controller.dashboard, isNotNull);

      controller.signOut();

      expect(controller.status, StudentDashboardStatus.initial);
      expect(controller.dashboard, isNull);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);

      controller.dispose();
    });

    test('actualiza el dashboard usando la sesión en memoria', () async {
      final initialDashboard = _dashboard;

      const refreshedDashboard = StudentDashboard(
        student: StudentProfile(
          id: 14,
          name: 'Alumno actualizado',
          selectedGroupId: 8,
        ),
        groups: [],
        exams: [],
        grades: [],
      );

      final repository = _SequentialStudentDashboardRepository(
        dashboards: [initialDashboard, refreshedDashboard],
      );

      final controller = _buildController(repository: repository);

      await controller.signIn(folio: 'FOLIO123', accessCode: 'ABCD27');

      expect(controller.dashboard?.student.name, 'Alumno de prueba');

      final refreshed = await controller.refresh();

      expect(refreshed, isTrue);
      expect(controller.dashboard?.student.name, 'Alumno actualizado');
      expect(repository.callCount, 2);
      expect(repository.receivedFolio, 'FOLIO123');
      expect(repository.receivedAccessCode, 'ABCD27');

      controller.dispose();
    });

    test('conserva el dashboard cuando falla la actualización', () async {
      final repository = _SuccessThenFailureDashboardRepository(
        dashboard: _dashboard,
      );

      final controller = _buildController(repository: repository);

      await controller.signIn(folio: 'FOLIO123', accessCode: 'ABCD27');

      final dashboardBeforeRefresh = controller.dashboard;

      final refreshed = await controller.refresh();

      expect(refreshed, isFalse);
      expect(controller.dashboard, same(dashboardBeforeRefresh));
      expect(controller.status, StudentDashboardStatus.success);
      expect(controller.errorMessage, 'No fue posible actualizar el portal.');

      controller.dispose();
    });
  });
}

StudentDashboardController _buildController({
  required StudentDashboardRepository repository,
}) {
  return StudentDashboardController(
    loadDashboard: LoadStudentDashboard(repository: repository),
  );
}

const StudentDashboard _dashboard = StudentDashboard(
  student: StudentProfile(id: 14, name: 'Alumno de prueba', selectedGroupId: 8),
  groups: [],
  exams: [],
  grades: [],
);

enum _RepositoryBehavior { success, apiFailure, unexpectedFailure }

class _FakeStudentDashboardRepository implements StudentDashboardRepository {
  _FakeStudentDashboardRepository.success({required this.dashboard})
    : behavior = _RepositoryBehavior.success,
      exception = null;

  _FakeStudentDashboardRepository.failure({required this.exception})
    : behavior = _RepositoryBehavior.apiFailure,
      dashboard = null;

  _FakeStudentDashboardRepository.unexpectedFailure()
    : behavior = _RepositoryBehavior.unexpectedFailure,
      dashboard = null,
      exception = null;

  final _RepositoryBehavior behavior;
  final StudentDashboard? dashboard;
  final ApiException? exception;

  String? receivedFolio;
  String? receivedAccessCode;

  @override
  Future<StudentDashboard> load({
    required String folio,
    required String accessCode,
  }) async {
    receivedFolio = folio;
    receivedAccessCode = accessCode;

    return switch (behavior) {
      _RepositoryBehavior.success => dashboard!,
      _RepositoryBehavior.apiFailure => throw exception!,
      _RepositoryBehavior.unexpectedFailure => throw StateError(
        'Error inesperado de prueba',
      ),
    };
  }
}

class _PendingStudentDashboardRepository implements StudentDashboardRepository {
  final _completer = Completer<StudentDashboard>();

  @override
  Future<StudentDashboard> load({
    required String folio,
    required String accessCode,
  }) {
    return _completer.future;
  }

  void complete(StudentDashboard dashboard) {
    _completer.complete(dashboard);
  }
}

class _SequentialStudentDashboardRepository
    implements StudentDashboardRepository {
  _SequentialStudentDashboardRepository({required this.dashboards});

  final List<StudentDashboard> dashboards;

  int callCount = 0;
  String? receivedFolio;
  String? receivedAccessCode;

  @override
  Future<StudentDashboard> load({
    required String folio,
    required String accessCode,
  }) async {
    receivedFolio = folio;
    receivedAccessCode = accessCode;

    final index = callCount;
    callCount++;

    if (index >= dashboards.length) {
      return dashboards.last;
    }

    return dashboards[index];
  }
}

class _SuccessThenFailureDashboardRepository
    implements StudentDashboardRepository {
  _SuccessThenFailureDashboardRepository({required this.dashboard});

  final StudentDashboard dashboard;
  int callCount = 0;

  @override
  Future<StudentDashboard> load({
    required String folio,
    required String accessCode,
  }) async {
    callCount++;

    if (callCount == 1) {
      return dashboard;
    }

    throw const ApiException(
      type: ApiFailureType.connection,
      message: 'No fue posible actualizar el portal.',
    );
  }
}

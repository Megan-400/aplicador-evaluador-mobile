import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/entities/enrollment/student_enrollment.dart';
import '../../../domain/usecases/enrollment/create_student_enrollment.dart';

enum StudentEnrollmentStatus { initial, loading, success, failure }

/// Administra la creación e inscripción de un perfil de alumno.
/// La inscripción y el código personal permanecen únicamente en memoria.
/// El controlador no registra ni persiste la credencial.
class StudentEnrollmentController extends ChangeNotifier {
  StudentEnrollmentController({required this.createEnrollment});

  final CreateStudentEnrollment createEnrollment;

  StudentEnrollmentStatus _status = StudentEnrollmentStatus.initial;

  StudentEnrollment? _enrollment;
  String? _errorMessage;

  StudentEnrollmentStatus get status => _status;

  StudentEnrollment? get enrollment => _enrollment;

  String? get errorMessage => _errorMessage;

  bool get isLoading {
    return _status == StudentEnrollmentStatus.loading;
  }

  bool get isSuccess {
    return _status == StudentEnrollmentStatus.success;
  }

  /// Código personal generado durante la inscripción.
  /// Solo está disponible mientras [enrollment] permanezca en memoria.
  String? get accessCode => _enrollment?.accessCode;

  /// Crea un perfil y lo inscribe en el grupo indicado.
  /// Devuelve `false` cuando ya existe una solicitud en curso o cuando
  /// la creación no puede completarse.
  Future<bool> create({
    required String groupFolio,
    required String studentName,
  }) async {
    if (isLoading) {
      return false;
    }

    _status = StudentEnrollmentStatus.loading;
    _enrollment = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await createEnrollment(
        groupFolio: groupFolio,
        studentName: studentName,
      );

      _enrollment = result;
      _status = StudentEnrollmentStatus.success;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on ApiException catch (error) {
      _status = StudentEnrollmentStatus.failure;
      _errorMessage = error.message;
      notifyListeners();

      return false;
    } on FormatException catch (error) {
      _status = StudentEnrollmentStatus.failure;
      _errorMessage = error.message;
      notifyListeners();

      return false;
    } catch (_) {
      _status = StudentEnrollmentStatus.failure;
      _errorMessage = 'Ocurrió un error inesperado al crear el perfil.';
      notifyListeners();

      return false;
    }
  }

  /// Elimina la inscripción y el código personal de la memoria.
  void reset() {
    _status = StudentEnrollmentStatus.initial;
    _enrollment = null;
    _errorMessage = null;
    notifyListeners();
  }
}

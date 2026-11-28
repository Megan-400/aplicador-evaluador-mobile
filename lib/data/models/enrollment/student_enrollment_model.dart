import '../../../domain/entities/enrollment/student_enrollment.dart';

abstract final class StudentEnrollmentModel {
  static final RegExp _accessCodePattern = RegExp(r'^[A-Z]{4}[0-9]{2}$');

  static StudentEnrollment fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    if (data is! Map) {
      throw const FormatException('La respuesta no contiene la inscripción.');
    }

    final dataMap = Map<String, dynamic>.from(data);

    final studentId = _positiveInt(dataMap['alumno_id']);

    final groupId = _positiveInt(dataMap['grupo_id']);

    final subject = _requiredString(dataMap['materia'], field: 'materia');

    final studentName = _requiredString(dataMap['nombre'], field: 'nombre');

    final status = _requiredString(
      dataMap['estado'],
      field: 'estado',
    ).toLowerCase();

    final mode = _requiredString(dataMap['modo'], field: 'modo').toLowerCase();

    final credentialVersion = _positiveInt(dataMap['credencial_version']);

    final accessCode = _requiredString(
      dataMap['codigo_acceso'],
      field: 'codigo_acceso',
    ).toUpperCase();

    if (studentId <= 0) {
      throw const FormatException('El identificador del alumno no es válido.');
    }

    if (groupId <= 0) {
      throw const FormatException('El identificador del grupo no es válido.');
    }

    if (status != 'inscrito') {
      throw const FormatException('El perfil no fue confirmado como inscrito.');
    }

    if (mode != 'nuevo') {
      throw const FormatException(
        'La respuesta no corresponde a una inscripción nueva.',
      );
    }

    if (credentialVersion <= 0) {
      throw const FormatException('La versión de la credencial no es válida.');
    }

    if (!_accessCodePattern.hasMatch(accessCode)) {
      throw const FormatException(
        'El código personal no tiene un formato válido.',
      );
    }

    return StudentEnrollment(
      studentId: studentId,
      groupId: groupId,
      subject: subject,
      studentName: studentName,
      status: status,
      mode: mode,
      credentialVersion: credentialVersion,
      accessCode: accessCode,
    );
  }

  static int _positiveInt(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _requiredString(Object? value, {required String field}) {
    final result = value?.toString().trim() ?? '';

    if (result.isEmpty) {
      throw FormatException('El campo $field no es válido.');
    }

    return result;
  }
}

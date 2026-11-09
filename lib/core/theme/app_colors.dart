import 'package:flutter/material.dart';

/// Colores institucionales y semánticos de la aplicación.
abstract final class AppColors {
  /*
   * Colores institucionales definidos para BigBitByte.
   */
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color institutionalSurface = Color(0xFFF0F9FF);
  static const Color institutionalDark = Color(0xFF1F2937);

  /*
   * Colores del tema claro.
   */
  static const Color lightBackground = institutionalSurface;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimarySurface = Color(0xFFEFF6FF);
  static const Color lightTextPrimary = institutionalDark;
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFDCE7F5);

  /*
   * Colores del tema oscuro.
   */
  static const Color darkBackground = Color(0xFF0C1523);
  static const Color darkSurface = Color(0xFF162337);
  static const Color darkPrimarySurface = Color(0xFF1A3552);
  static const Color darkTextPrimary = Color(0xFFEDF5FF);
  static const Color darkTextSecondary = Color(0xFFA1B3CD);
  static const Color darkBorder = Color(0xFF2E4159);

  /*
   * Colores semánticos.
   */
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFB3261E);
  static const Color information = primary;

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);
}

import 'package:aplicador_evaluador_mobile/core/theme/app_colors.dart';
import 'package:aplicador_evaluador_mobile/core/theme/app_dimensions.dart';
import 'package:aplicador_evaluador_mobile/core/theme/app_text_styles.dart';
import 'package:aplicador_evaluador_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('configura el tema claro con los valores institucionales', () {
      final theme = AppTheme.light;

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(theme.textTheme.bodyLarge?.fontFamily, AppTextStyles.fontFamily);
    });

    test('configura el tema oscuro con los valores institucionales', () {
      final theme = AppTheme.dark;

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(theme.textTheme.bodyLarge?.fontFamily, AppTextStyles.fontFamily);
    });

    test('mantiene las dimensiones mínimas acordadas', () {
      expect(AppDimensions.buttonHeight, 48);
      expect(AppDimensions.inputHeight, 48);
      expect(AppDimensions.minimumTouchTarget, 48);
      expect(AppDimensions.answerOptionMinHeight, 56);
    });
  });
}

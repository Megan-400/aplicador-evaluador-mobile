import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';

/// Pantalla provisional para las calificaciones del alumno.

class StudentGradesScreen extends StatelessWidget {
  const StudentGradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: ListView(
        key: const PageStorageKey<String>('student-grades'),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          Text('Calificaciones', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Consulta los resultados disponibles de tus evaluaciones.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    size: AppDimensions.iconLarge,
                    color: colors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Sin calificaciones disponibles',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Los resultados aparecerán aquí cuando sean publicados.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

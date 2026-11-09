import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';

/// Pantalla provisional de exámenes disponibles para el alumno.

class StudentExamsScreen extends StatelessWidget {
  const StudentExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: ListView(
        key: const PageStorageKey<String>('student-exams'),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          Text('Exámenes', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Consulta los exámenes disponibles y sus instrucciones.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: AppDimensions.iconLarge,
                    color: colors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Sin exámenes cargados',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'La consulta de exámenes se implementará cuando esté '
                    'disponible el contrato correspondiente de la API.',
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

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';

/// Pantalla provisional para los grupos asociados al alumno.

class StudentGroupsScreen extends StatelessWidget {
  const StudentGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: ListView(
        key: const PageStorageKey<String>('student-groups'),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          Text('Mis grupos', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Consulta los grupos a los que perteneces.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: AppDimensions.iconLarge,
                    color: colors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Sin grupos asociados',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'La consulta y unión a grupos se implementará en una '
                    'historia posterior.',
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

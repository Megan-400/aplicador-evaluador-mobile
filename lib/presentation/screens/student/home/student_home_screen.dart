import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';

/// Pantalla inicial provisional del portal del alumno.

/// El contenido definitivo se implementará en una historia independiente.

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: ListView(
        key: const PageStorageKey<String>('student-home'),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          Text('Inicio', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Consulta tus actividades y accesos recientes.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: AppDimensions.iconLarge,
                    color: colors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Portal del alumno',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'El contenido del inicio se incorporará en una historia '
                    'posterior.',
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

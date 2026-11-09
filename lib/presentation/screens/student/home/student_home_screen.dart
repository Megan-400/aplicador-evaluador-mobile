import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';

/// Pantalla inicial del portal móvil del alumno.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({
    required this.onOpenExams,
    required this.onOpenGrades,
    required this.onOpenGroups,
    super.key,
  });

  final VoidCallback onOpenExams;
  final VoidCallback onOpenGrades;
  final VoidCallback onOpenGroups;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: ListView(
        key: const PageStorageKey<String>('student-home'),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          _HomeHeader(theme: theme),
          const SizedBox(height: AppSpacing.lg),
          _WelcomeCard(colors: colors),
          const SizedBox(height: AppSpacing.lg),
          Text('Accesos principales', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _QuickAccessGrid(
            onOpenExams: onOpenExams,
            onOpenGrades: onOpenGrades,
            onOpenGroups: onOpenGroups,
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(
            title: 'Próximos exámenes',
            actionText: 'Ver todos',
            onActionPressed: onOpenExams,
          ),
          const SizedBox(height: AppSpacing.md),
          const _EmptyUpcomingExams(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inicio', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Consulta tus actividades y accesos principales.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Semantics(
          label: 'Perfil del alumno',
          button: true,
          child: IconButton(
            onPressed: () {},
            tooltip: 'Perfil',
            icon: const Icon(Icons.person_outline),
          ),
        ),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.minimumTouchTarget,
            height: AppDimensions.minimumTouchTarget,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: Icon(Icons.school_outlined, color: colors.onPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Portal del alumno', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Desde aquí podrás consultar tus exámenes, resultados '
                  'y grupos registrados.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({
    required this.onOpenExams,
    required this.onOpenGrades,
    required this.onOpenGroups,
  });

  final VoidCallback onOpenExams;
  final VoidCallback onOpenGrades;
  final VoidCallback onOpenGroups;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minimumCardWidth = 156.0;

        final useTwoColumns =
            constraints.maxWidth >= (minimumCardWidth * 2) + AppSpacing.md;

        final itemWidth = useTwoColumns
            ? (constraints.maxWidth - AppSpacing.md) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _QuickAccessCard(
              width: itemWidth,
              icon: Icons.assignment_outlined,
              title: 'Exámenes',
              description: 'Consulta evaluaciones disponibles.',
              onPressed: onOpenExams,
            ),
            _QuickAccessCard(
              width: itemWidth,
              icon: Icons.bar_chart_outlined,
              title: 'Calificaciones',
              description: 'Revisa tus resultados publicados.',
              onPressed: onOpenGrades,
            ),
            _QuickAccessCard(
              width: itemWidth,
              icon: Icons.groups_outlined,
              title: 'Mis grupos',
              description: 'Consulta tus grupos registrados.',
              onPressed: onOpenGroups,
            ),
          ],
        );
      },
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  final double width;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: width,
      height: AppDimensions.quickAccessCardHeight,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: AppDimensions.iconLarge,
                  color: colors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Expanded(
                  child: Text(
                    description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward,
                    size: AppDimensions.iconSmall,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onActionPressed,
  });

  final String title;
  final String actionText;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(onPressed: onActionPressed, child: Text(actionText)),
      ],
    );
  }
}

class _EmptyUpcomingExams extends StatelessWidget {
  const _EmptyUpcomingExams();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(
              Icons.event_available_outlined,
              size: AppDimensions.iconLarge,
              color: colors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No hay próximos exámenes',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Los exámenes asignados aparecerán en esta sección.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

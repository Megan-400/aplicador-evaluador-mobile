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
    required this.onOpenProfile,
    required this.studentName,
    required this.pendingExamCount,
    required this.completedExamCount,
    required this.registeredGroupCount,
    super.key,
  });

  final VoidCallback onOpenExams;
  final VoidCallback onOpenGrades;
  final VoidCallback onOpenGroups;
  final VoidCallback onOpenProfile;

  final String studentName;
  final int pendingExamCount;
  final int completedExamCount;
  final int registeredGroupCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: ListView(
        key: const PageStorageKey<String>('student-home'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.mobileHorizontal,
          AppSpacing.md,
          AppSpacing.mobileHorizontal,
          AppSpacing.xxl,
        ),
        children: [
          _HomeHeader(studentName: studentName, onOpenProfile: onOpenProfile),
          const SizedBox(height: AppSpacing.md),
          _WelcomeCard(colors: colors),
          const SizedBox(height: AppSpacing.lg),
          Text('Tu actividad', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          _StudentDashboardStats(
            pendingExamCount: pendingExamCount,
            completedExamCount: completedExamCount,
            registeredGroupCount: registeredGroupCount,
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
          const SizedBox(height: AppSpacing.sm),
          const _EmptyUpcomingExams(),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.studentName, required this.onOpenProfile});

  final String studentName;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TU ESPACIO ACADÉMICO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Hola, $studentName.',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Consulta tus actividades y accesos '
                'principales.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onOpenProfile,
          tooltip: 'Perfil',
          icon: const Icon(Icons.person_outline),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.primary.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: Icon(
              Icons.school_outlined,
              size: AppDimensions.iconMedium,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Portal del alumno', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Desde aquí podrás consultar tus '
                  'exámenes, resultados y grupos '
                  'registrados.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadii.control),
              ),
              child: Icon(
                Icons.event_available_outlined,
                size: AppDimensions.iconMedium,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No hay próximos exámenes',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Los exámenes asignados aparecerán '
                    'en esta sección.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentDashboardStats extends StatelessWidget {
  const _StudentDashboardStats({
    required this.pendingExamCount,
    required this.completedExamCount,
    required this.registeredGroupCount,
    required this.onOpenExams,
    required this.onOpenGrades,
    required this.onOpenGroups,
  });

  final int pendingExamCount;
  final int completedExamCount;
  final int registeredGroupCount;

  final VoidCallback onOpenExams;
  final VoidCallback onOpenGrades;
  final VoidCallback onOpenGroups;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;

        final cardWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _StudentStatisticCard(
                key: const Key('pending-exams-statistic'),
                icon: Icons.description_outlined,
                label: 'Por realizar',
                value: pendingExamCount.toString(),
                description: pendingExamCount == 1
                    ? 'Examen pendiente'
                    : 'Exámenes pendientes',
                accentColor: const Color(0xFF3B82F6),
                onPressed: onOpenExams,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StudentStatisticCard(
                key: const Key('completed-exams-statistic'),
                icon: Icons.check_outlined,
                label: 'Entregados',
                value: completedExamCount.toString(),
                description: completedExamCount == 1
                    ? 'Examen entregado'
                    : 'Exámenes entregados',
                accentColor: const Color(0xFF14B8A6),
                onPressed: onOpenGrades,
              ),
            ),
            SizedBox(
              width: constraints.maxWidth,
              child: _StudentStatisticCard(
                key: const Key('registered-groups-statistic'),
                icon: Icons.groups_outlined,
                label: 'Mis grupos',
                value: registeredGroupCount.toString(),
                description: registeredGroupCount == 1
                    ? 'Grupo registrado'
                    : 'Grupos registrados',
                accentColor: const Color(0xFF8B5CF6),
                onPressed: onOpenGroups,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StudentStatisticCard extends StatelessWidget {
  const _StudentStatisticCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.description,
    required this.accentColor,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String description;
  final Color accentColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
                child: Icon(
                  icon,
                  size: AppDimensions.iconMedium,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                size: AppDimensions.iconSmall,
                color: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/entities/student_group_summary.dart';

/// Tarjeta con la información resumida de un grupo.
class StudentGroupCard extends StatelessWidget {
  const StudentGroupCard({
    required this.group,
    required this.onPressed,
    super.key,
  });

  final StudentGroupSummary group;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppDimensions.minimumTouchTarget,
                    height: AppDimensions.minimumTouchTarget,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadii.control),
                    ),
                    child: Icon(Icons.groups_outlined, color: colors.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(group.subject, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _GroupStatusBadge(status: group.status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.xs,
                children: [
                  _GroupMetadata(
                    icon: Icons.calendar_month_outlined,
                    text: group.period,
                  ),
                  if (group.teacherName != null)
                    _GroupMetadata(
                      icon: Icons.person_outline,
                      text: group.teacherName!,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver grupo',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.arrow_forward,
                      size: AppDimensions.iconSmall,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupMetadata extends StatelessWidget {
  const _GroupMetadata({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSmall,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _GroupStatusBadge extends StatelessWidget {
  const _GroupStatusBadge({required this.status});

  final StudentGroupStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      StudentGroupStatus.active => AppColors.success,
      StudentGroupStatus.completed => Theme.of(
        context,
      ).colorScheme.onSurfaceVariant,
    };

    final label = switch (status) {
      StudentGroupStatus.active => 'Activo',
      StudentGroupStatus.completed => 'Finalizado',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.circular),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

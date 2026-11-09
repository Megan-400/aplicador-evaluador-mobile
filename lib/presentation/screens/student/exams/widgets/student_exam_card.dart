import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/entities/student_exam_summary.dart';

/// Tarjeta con la información resumida de un examen.
class StudentExamCard extends StatelessWidget {
  const StudentExamCard({
    required this.exam,
    required this.onPressed,
    super.key,
  });

  final StudentExamSummary exam;
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
                    child: Icon(
                      Icons.assignment_outlined,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exam.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(exam.subject, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ExamStatusBadge(status: exam.status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  _ExamMetadata(
                    icon: Icons.schedule_outlined,
                    text: '${exam.durationMinutes} min',
                  ),
                  _ExamMetadata(
                    icon: Icons.help_outline,
                    text: '${exam.questionCount} preguntas',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _actionLabel(exam.status),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _actionLabel(StudentExamStatus status) {
    return switch (status) {
      StudentExamStatus.available => 'Ver examen',
      StudentExamStatus.upcoming => 'Ver información',
      StudentExamStatus.completed => 'Ver resultado',
      StudentExamStatus.closed => 'Ver detalle',
    };
  }
}

class _ExamMetadata extends StatelessWidget {
  const _ExamMetadata({required this.icon, required this.text});

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

class _ExamStatusBadge extends StatelessWidget {
  const _ExamStatusBadge({required this.status});

  final StudentExamStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = _foregroundColor(colors);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.circular),
      ),
      child: Text(
        _label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }

  String get _label {
    return switch (status) {
      StudentExamStatus.available => 'Disponible',
      StudentExamStatus.upcoming => 'Próximo',
      StudentExamStatus.completed => 'Finalizado',
      StudentExamStatus.closed => 'Cerrado',
    };
  }

  Color _foregroundColor(ColorScheme colors) {
    return switch (status) {
      StudentExamStatus.available => colors.primary,
      StudentExamStatus.upcoming => colors.tertiary,
      StudentExamStatus.completed => colors.secondary,
      StudentExamStatus.closed => colors.onSurfaceVariant,
    };
  }
}

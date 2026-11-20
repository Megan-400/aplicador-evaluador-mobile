import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/entities/student_grade_summary.dart';

/// Tarjeta con el resumen de una calificación publicada.
class StudentGradeCard extends StatelessWidget {
  const StudentGradeCard({
    required this.grade,
    required this.onPressed,
    super.key,
  });

  final StudentGradeSummary grade;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultColor = _resultColor(context);

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
                      color: resultColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.control),
                    ),
                    child: Icon(_resultIcon, color: resultColor),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grade.examTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(grade.subject, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _GradeResultBadge(result: grade.result),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _GradeScore(
                      score: grade.score,
                      maximumScore: grade.maximumScore,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.arrow_forward,
                    size: AppDimensions.iconSmall,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _resultColor(BuildContext context) {
    return switch (grade.result) {
      StudentGradeResult.passed => AppColors.success,
      StudentGradeResult.notPassed => AppColors.error,
      StudentGradeResult.pending => AppColors.warning,
      StudentGradeResult.hidden => Theme.of(
        context,
      ).colorScheme.onSurfaceVariant,
    };
  }

  IconData get _resultIcon {
    return switch (grade.result) {
      StudentGradeResult.passed => Icons.check_circle_outline,
      StudentGradeResult.notPassed => Icons.cancel_outlined,
      StudentGradeResult.pending => Icons.hourglass_empty,
      StudentGradeResult.hidden => Icons.visibility_off_outlined,
    };
  }
}

class _GradeScore extends StatelessWidget {
  const _GradeScore({required this.score, required this.maximumScore});

  final double score;
  final double maximumScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Calificación', style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '${_formatScore(score)} / ${_formatScore(maximumScore)}',
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }

  String _formatScore(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}

class _GradeResultBadge extends StatelessWidget {
  const _GradeResultBadge({required this.result});

  final StudentGradeResult result;

  @override
  Widget build(BuildContext context) {
    final color = switch (result) {
      StudentGradeResult.passed => AppColors.success,
      StudentGradeResult.notPassed => AppColors.error,
      StudentGradeResult.pending => AppColors.warning,
      StudentGradeResult.hidden => Theme.of(
        context,
      ).colorScheme.onSurfaceVariant,
    };

    final label = switch (result) {
      StudentGradeResult.passed => 'Aprobado',
      StudentGradeResult.notPassed => 'No aprobado',
      StudentGradeResult.pending => 'En revisión',
      StudentGradeResult.hidden => 'Sin publicar',
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

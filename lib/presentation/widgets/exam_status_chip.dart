import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/exam.dart';
import 'status_chip.dart';

/// Etiqueta con el estado de un examen: borrador, publicado o cerrado.
class ExamStatusChip extends StatelessWidget {
  const ExamStatusChip({super.key, required this.status});

  final ExamStatus status;

  @override
  Widget build(BuildContext context) {
    final neutro = Theme.of(context).colorScheme.onSurface;

    return switch (status) {
      ExamStatus.draft => StatusChip(
        label: 'Borrador',
        icon: Icons.edit_outlined,
        color: neutro,
      ),
      ExamStatus.published => const StatusChip(
        label: 'Publicado',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
      ExamStatus.closed => StatusChip(
        label: 'Cerrado',
        icon: Icons.lock_outline,
        color: neutro,
      ),
    };
  }
}
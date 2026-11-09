import 'package:flutter/material.dart';

import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';

/// Etiqueta de estado con ícono y texto (el color nunca es el único indicador).
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.small),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSmall, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Opciones seleccionables de una pregunta de opción múltiple.
///
/// Por el momento se permite seleccionar una sola respuesta.
class MultipleChoiceQuestion extends StatelessWidget {
  const MultipleChoiceQuestion({
    required this.questionId,
    required this.options,
    required this.selectedAnswer,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final int questionId;
  final List<String> options;
  final String selectedAnswer;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (options.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Text(
          'Esta pregunta no contiene opciones disponibles.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onErrorContainer,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return RadioGroup<String>(
      groupValue: selectedAnswer.isEmpty ? null : selectedAnswer,
      onChanged: (value) {
        if (enabled && value != null) {
          onChanged(value);
        }
      },
      child: Column(
        key: ValueKey<String>('multiple-choice-$questionId'),
        children: [
          for (var index = 0; index < options.length; index++) ...[
            _ChoiceOption(
              questionId: questionId,
              index: index,
              label: options[index],
              selected: options[index] == selectedAnswer,
              enabled: enabled,
              onPressed: () {
                onChanged(options[index]);
              },
            ),
            if (index < options.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ChoiceOption extends StatelessWidget {
  const _ChoiceOption({
    required this.questionId,
    required this.index,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final int questionId;
  final int index;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor = selected
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;

    final borderColor = selected ? colors.primary : colors.outlineVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadii.control),
      child: InkWell(
        key: ValueKey<String>('choice-$questionId-$index'),
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AppRadii.control),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.control),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Radio<String>(value: label, enabled: enabled),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: enabled ? colors.onSurface : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

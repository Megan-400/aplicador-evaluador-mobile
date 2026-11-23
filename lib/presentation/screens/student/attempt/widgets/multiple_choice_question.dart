import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/entities/questions/student_question_option.dart';

/// Opciones seleccionables de una pregunta de opción múltiple.
///
/// Presenta la etiqueta visible de cada opción y conserva su valor estable,
/// por ejemplo `A`, `B`, `C` o `D`.
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
  final List<StudentQuestionOption> options;

  /// Valor seleccionado, por ejemplo `B`.
  final String selectedAnswer;

  /// Comunica el valor estable de la opción, no su etiqueta.
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

    final availableValues = options.map((option) => option.value).toSet();

    final groupValue = availableValues.contains(selectedAnswer)
        ? selectedAnswer
        : null;

    return RadioGroup<String>(
      groupValue: groupValue,
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
              option: options[index],
              selected: options[index].value == selectedAnswer,
              enabled: enabled,
              onPressed: () {
                onChanged(options[index].value);
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
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final int questionId;
  final int index;
  final StudentQuestionOption option;
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
              Radio<String>(value: option.value, enabled: enabled),
              const SizedBox(width: AppSpacing.xs),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? colors.primary : colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colors.primary : colors.outline,
                  ),
                ),
                child: Text(
                  option.value,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: selected ? colors.onPrimary : colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  option.label,
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

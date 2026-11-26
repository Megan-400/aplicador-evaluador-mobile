import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/entities/questions/student_question_option.dart';

/// Opciones seleccionables de una pregunta de opción múltiple.
/// [StudentQuestionOption.value] se utiliza como identificador visual,
/// por ejemplo `A`, `B`, `C` o `D`.
/// [StudentQuestionOption.label] es la respuesta completa que se muestra
/// y se envía al backend.
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

  /// Texto completo de la respuesta seleccionada.
  /// Ejemplo: `Herencia`.
  final String selectedAnswer;

  /// Comunica la etiqueta completa, no la clave visual.
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

    final selectedLabel = _selectedLabel();

    return RadioGroup<String>(
      groupValue: selectedLabel,
      onChanged: (label) {
        if (enabled && label != null) {
          onChanged(label);
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
              selected: options[index].label == selectedLabel,
              enabled: enabled,
              onPressed: () {
                onChanged(options[index].label);
              },
            ),
            if (index < options.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  /// Obtiene la etiqueta que debe mostrarse como seleccionada.
  /// La compatibilidad con [option.value] permite abrir intentos activos
  /// que hayan guardado temporalmente `A`, `B`, `C` o `D` con una versión
  /// anterior de la aplicación.
  String? _selectedLabel() {
    if (selectedAnswer.isEmpty) {
      return null;
    }

    for (final option in options) {
      if (option.label == selectedAnswer) {
        return option.label;
      }

      if (option.value == selectedAnswer) {
        return option.label;
      }
    }

    return null;
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
              Radio<String>(value: option.label, enabled: enabled),
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

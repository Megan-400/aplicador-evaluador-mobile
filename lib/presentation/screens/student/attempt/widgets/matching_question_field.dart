import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/entities/questions/student_matching_pair.dart';

/// Permite relacionar cada elemento izquierdo con una opción derecha.
///
/// La respuesta se comunica como JSON y permanece únicamente en memoria.
class MatchingQuestionField extends StatefulWidget {
  const MatchingQuestionField({
    required this.questionId,
    required this.pairs,
    required this.initialAnswer,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final int questionId;
  final List<StudentMatchingPair> pairs;
  final String initialAnswer;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<MatchingQuestionField> createState() {
    return _MatchingQuestionFieldState();
  }
}

class _MatchingQuestionFieldState extends State<MatchingQuestionField> {
  late Map<String, String> _selections;

  @override
  void initState() {
    super.initState();
    _selections = _decodeAnswer(widget.initialAnswer);
  }

  @override
  void didUpdateWidget(covariant MatchingQuestionField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.questionId != widget.questionId ||
        oldWidget.initialAnswer != widget.initialAnswer) {
      _selections = _decodeAnswer(widget.initialAnswer);
    }
  }

  Map<String, String> _decodeAnswer(String answer) {
    if (answer.trim().isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(answer);

      if (decoded is! Map) {
        return {};
      }

      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } on FormatException {
      return {};
    }
  }

  void _select({required String left, required String? right}) {
    setState(() {
      if (right == null || right.isEmpty) {
        _selections.remove(left);
      } else {
        _selections[left] = right;
      }
    });

    if (_selections.isEmpty) {
      widget.onChanged('');
      return;
    }

    widget.onChanged(jsonEncode(_selections));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final rightOptions = widget.pairs
        .map((pair) => pair.right)
        .toSet()
        .toList(growable: false);

    if (widget.pairs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Text(
          'Esta pregunta no contiene relaciones disponibles.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onErrorContainer,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      key: ValueKey<String>('matching-question-${widget.questionId}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selecciona la relación correspondiente para cada elemento.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        for (var index = 0; index < widget.pairs.length; index++) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.control),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pairs[index].left,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  key: ValueKey<String>('matching-${widget.questionId}-$index'),
                  initialValue: _selections[widget.pairs[index].left],
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Selecciona una relación',
                  ),
                  items: [
                    for (final option in rightOptions)
                      DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: widget.enabled
                      ? (value) {
                          _select(left: widget.pairs[index].left, right: value);
                        }
                      : null,
                ),
              ],
            ),
          ),
          if (index < widget.pairs.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

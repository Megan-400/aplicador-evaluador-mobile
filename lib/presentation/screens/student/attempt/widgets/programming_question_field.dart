import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';

/// Campo de captura para una respuesta de programación.
///
/// El código se conserva como texto. Este widget no ejecuta ni compila
/// contenido localmente.
class ProgrammingQuestionField extends StatefulWidget {
  const ProgrammingQuestionField({
    required this.questionId,
    required this.initialAnswer,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final int questionId;
  final String initialAnswer;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<ProgrammingQuestionField> createState() {
    return _ProgrammingQuestionFieldState();
  }
}

class _ProgrammingQuestionFieldState extends State<ProgrammingQuestionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void didUpdateWidget(covariant ProgrammingQuestionField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.questionId != widget.questionId ||
        oldWidget.initialAnswer != widget.initialAnswer) {
      _controller.value = TextEditingValue(
        text: widget.initialAnswer,
        selection: TextSelection.collapsed(offset: widget.initialAnswer.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: ValueKey<String>('programming-answer-${widget.questionId}'),
      controller: _controller,
      enabled: widget.enabled,
      minLines: 10,
      maxLines: 18,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      autocorrect: false,
      enableSuggestions: false,
      onChanged: widget.onChanged,
      style: const TextStyle(fontFamily: 'monospace'),
      decoration: const InputDecoration(
        labelText: 'Código',
        hintText: 'Escribe tu solución aquí.',
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}

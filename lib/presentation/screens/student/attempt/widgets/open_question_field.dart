import 'package:flutter/material.dart';

import '../../../../../core/theme/app_spacing.dart';

/// Campo para responder una pregunta abierta.
///
/// La respuesta se conserva fuera del widget, mediante [onChanged].
class OpenQuestionField extends StatefulWidget {
  const OpenQuestionField({
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
  State<OpenQuestionField> createState() {
    return _OpenQuestionFieldState();
  }
}

class _OpenQuestionFieldState extends State<OpenQuestionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialAnswer);
  }

  @override
  void didUpdateWidget(covariant OpenQuestionField oldWidget) {
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
      key: ValueKey<String>('open-answer-${widget.questionId}'),
      controller: _controller,
      enabled: widget.enabled,
      minLines: 5,
      maxLines: 10,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(
        labelText: 'Tu respuesta',
        hintText: 'Escribe tu respuesta aquí.',
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}

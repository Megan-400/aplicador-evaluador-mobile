import 'package:flutter/material.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/entities/student_exam_summary.dart';

typedef StartExamCallback = Future<bool> Function(StudentExamSummary exam);

/// Muestra la información e instrucciones previas de un examen.
class StudentExamDetailScreen extends StatefulWidget {
  const StudentExamDetailScreen({
    required this.exam,
    required this.onStartExam,
    this.startErrorMessage,
    super.key,
  });

  final StudentExamSummary exam;
  final StartExamCallback onStartExam;
  final String? Function()? startErrorMessage;

  @override
  State<StudentExamDetailScreen> createState() {
    return _StudentExamDetailScreenState();
  }
}

class _StudentExamDetailScreenState extends State<StudentExamDetailScreen> {
  bool _isStarting = false;

  bool get _canStart {
    return widget.exam.status == StudentExamStatus.available;
  }

  String get _primaryActionLabel {
    return switch (widget.exam.status) {
      StudentExamStatus.available => 'Iniciar examen',
      StudentExamStatus.upcoming => 'Aún no disponible',
      StudentExamStatus.completed => 'Examen finalizado',
      StudentExamStatus.closed => 'Examen cerrado',
    };
  }

  Future<void> _requestStart() async {
    if (!_canStart || _isStarting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Iniciar examen'),
          content: const Text(
            'Al iniciar, el tiempo del examen comenzará a contar. '
            'Verifica que tengas una conexión estable antes de continuar.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Iniciar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isStarting = true;
    });

    final started = await widget.onStartExam(widget.exam);

    if (!mounted) {
      return;
    }

    setState(() {
      _isStarting = false;
    });

    if (started) {
      return;
    }

    final message =
        widget.startErrorMessage?.call() ?? 'No fue posible iniciar el examen.';

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del examen')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
          children: [
            Text(widget.exam.subject, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(widget.exam.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            _StatusBanner(status: widget.exam.status),
            const SizedBox(height: AppSpacing.lg),
            _ExamInformation(exam: widget.exam),
            const SizedBox(height: AppSpacing.lg),
            _InstructionsSection(instructions: widget.exam.instructions),
            const SizedBox(height: AppSpacing.lg),
            _StartWarning(status: widget.exam.status),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              key: const Key('start-exam-button'),
              onPressed: _canStart && !_isStarting ? _requestStart : null,
              child: _isStarting
                  ? const SizedBox(
                      width: AppDimensions.iconMedium,
                      height: AppDimensions.iconMedium,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_primaryActionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamInformation extends StatelessWidget {
  const _ExamInformation({required this.exam});

  final StudentExamSummary exam;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _InformationRow(
              icon: Icons.schedule_outlined,
              label: 'Duración',
              value: '${exam.durationMinutes} minutos',
            ),
            const Divider(height: AppSpacing.lg),
            _InformationRow(
              icon: Icons.help_outline,
              label: 'Preguntas',
              value: exam.questionCount.toString(),
            ),
            if (exam.availableAt != null) ...[
              const Divider(height: AppSpacing.lg),
              _InformationRow(
                icon: Icons.event_available_outlined,
                label: 'Disponible desde',
                value: _formatDate(exam.availableAt!),
              ),
            ],
            if (exam.dueAt != null) ...[
              const Divider(height: AppSpacing.lg),
              _InformationRow(
                icon: Icons.event_busy_outlined,
                label: 'Disponible hasta',
                value: _formatDate(exam.dueAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: AppDimensions.minimumTouchTarget,
          height: AppDimensions.minimumTouchTarget,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          child: Icon(icon, color: colors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(value, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstructionsSection extends StatelessWidget {
  const _InstructionsSection({required this.instructions});

  final List<String> instructions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final visibleInstructions = instructions.isEmpty
        ? const [
            'Lee cuidadosamente cada pregunta antes de responder.',
            'Verifica tus respuestas antes de finalizar el examen.',
            'No cierres la aplicación mientras el intento esté activo.',
          ]
        : instructions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instrucciones', style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < visibleInstructions.length;
                  index++
                ) ...[
                  _InstructionItem(
                    number: index + 1,
                    text: visibleInstructions[index],
                  ),
                  if (index < visibleInstructions.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InstructionItem extends StatelessWidget {
  const _InstructionItem({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: AppDimensions.iconLarge,
          height: AppDimensions.iconLarge,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            number.toString(),
            style: theme.textTheme.labelLarge?.copyWith(color: colors.primary),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

class _StartWarning extends StatelessWidget {
  const _StartWarning({required this.status});

  final StudentExamStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final message = switch (status) {
      StudentExamStatus.available =>
        'El tiempo comenzará a contar cuando confirmes el inicio.',
      StudentExamStatus.upcoming =>
        'El examen podrá iniciarse cuando llegue la fecha indicada.',
      StudentExamStatus.completed => 'Este examen ya fue finalizado.',
      StudentExamStatus.closed =>
        'El periodo disponible para presentar este examen terminó.',
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: colors.primary.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final StudentExamStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final label = switch (status) {
      StudentExamStatus.available => 'Disponible',
      StudentExamStatus.upcoming => 'Próximo',
      StudentExamStatus.completed => 'Finalizado',
      StudentExamStatus.closed => 'Cerrado',
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadii.circular),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: colors.primary),
        ),
      ),
    );
  }
}

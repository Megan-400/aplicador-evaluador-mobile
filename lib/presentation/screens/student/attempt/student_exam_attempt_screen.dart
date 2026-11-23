import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/attempts/student_exam_attempt.dart';
import '../../../../domain/entities/questions/student_exam_question.dart';
import '../../../../domain/entities/questions/student_question_type.dart';
import '../../../../domain/entities/student_exam_summary.dart';
import '../../../state/questions/exam_questions_controller.dart';
import 'widgets/matching_question_field.dart';
import 'widgets/multiple_choice_question.dart';
import 'widgets/open_question_field.dart';
import 'widgets/programming_question_field.dart';
import '../../../state/answers/save_answers_controller.dart';

/// Presenta las preguntas asociadas con un intento activo.
/// Las respuestas se conservan únicamente en memoria. El guardado remoto
/// se implementará posteriormente en HU-MOV-012.
class StudentExamAttemptScreen extends StatefulWidget {
  const StudentExamAttemptScreen({
    required this.exam,
    required this.attempt,
    required this.questionsController,
    required this.saveAnswersController,
    super.key,
  });

  final StudentExamSummary exam;
  final StudentExamAttempt attempt;
  final ExamQuestionsController questionsController;
  final SaveAnswersController saveAnswersController;

  @override
  State<StudentExamAttemptScreen> createState() {
    return _StudentExamAttemptScreenState();
  }
}

class _StudentExamAttemptScreenState extends State<StudentExamAttemptScreen> {
  @override
  void initState() {
    super.initState();

    widget.questionsController.addListener(_handleControllerChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });

    widget.saveAnswersController.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.questionsController.removeListener(_handleControllerChange);

    widget.saveAnswersController.removeListener(_handleControllerChange);

    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadQuestions() async {
    final loaded = await widget.questionsController.load(
      sessionToken: widget.attempt.sessionToken,
    );

    if (!loaded || !mounted) {
      return;
    }

    widget.saveAnswersController.hydrate(
      widget.questionsController.localAnswers,
    );
  }

  Future<bool> _confirmExit() async {
    final hasPending = widget.saveAnswersController.hasPendingAnswers;

    final message = hasPending
        ? 'Existen respuestas pendientes o con errores de guardado. '
              'Si sales, esos cambios locales se perderán.'
        : 'Puedes salir del examen y reanudarlo posteriormente. '
              'Las respuestas guardadas permanecerán disponibles.';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Salir del examen'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Continuar examen'),
            ),
            ElevatedButton(
              key: const Key('confirm-exit-attempt-button'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _requestExit() async {
    final confirmed = await _confirmExit();

    if (!confirmed || !mounted) {
      return;
    }

    widget.saveAnswersController.reset();
    widget.questionsController.reset();

    Navigator.of(context).pop();
  }

  Future<bool> _saveCurrentQuestion() async {
    final question = widget.questionsController.currentQuestion;

    if (question == null) {
      return true;
    }

    final saveState = widget.saveAnswersController.stateFor(question.id);

    if (!saveState.hasChanges) {
      return true;
    }

    final saved = await widget.saveAnswersController.save(
      sessionToken: widget.attempt.sessionToken,
      questionId: question.id,
    );

    if (!saved && mounted) {
      final currentState = widget.saveAnswersController.stateFor(question.id);

      final message =
          currentState.errorMessage ?? 'No fue posible guardar la respuesta.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Reintentar',
            onPressed: () {
              widget.saveAnswersController.retry(
                sessionToken: widget.attempt.sessionToken,
                questionId: question.id,
              );
            },
          ),
        ),
      );
    }

    return saved;
  }

  Future<void> _goToNextQuestion() async {
    final saved = await _saveCurrentQuestion();

    if (!saved || !mounted) {
      return;
    }

    widget.questionsController.next();
  }

  Future<void> _goToPreviousQuestion() async {
    final saved = await _saveCurrentQuestion();

    if (!saved || !mounted) {
      return;
    }

    widget.questionsController.previous();
  }

  Future<void> _showReview() async {
    final saved = await _saveCurrentQuestion();

    if (!saved || !mounted) {
      return;
    }

    final questionsController = widget.questionsController;

    final unanswered = questionsController.questions
        .where((question) => !questionsController.isAnswered(question.id))
        .toList(growable: false);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Revisión del intento',
                style: Theme.of(bottomSheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${questionsController.answeredCount} de '
                '${questionsController.totalQuestions} preguntas '
                'tienen una respuesta local.',
                style: Theme.of(bottomSheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (unanswered.isEmpty)
                const _ReviewMessage(
                  icon: Icons.check_circle_outline,
                  title: 'Todas tienen respuesta',
                  description:
                      'Todas las preguntas tienen una '
                      'respuesta local.',
                )
              else
                _ReviewMessage(
                  icon: Icons.info_outline,
                  title: 'Preguntas pendientes',
                  description:
                      'Quedan ${unanswered.length} preguntas '
                      'sin respuesta.',
                ),
              const SizedBox(height: AppSpacing.lg),
              if (unanswered.isNotEmpty)
                OutlinedButton(
                  onPressed: () {
                    final firstUnanswered = unanswered.first;

                    final index = questionsController.questions.indexWhere(
                      (question) => question.id == firstUnanswered.id,
                    );

                    questionsController.goTo(index);

                    Navigator.of(bottomSheetContext).pop();
                  },
                  child: const Text('Ir a la primera pendiente'),
                ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(bottomSheetContext).pop();
                },
                child: const Text('Continuar respondiendo'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.questionsController;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _requestExit();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: const Key('attempt-exit-button'),
            onPressed: _requestExit,
            tooltip: 'Salir del examen',
            icon: const Icon(Icons.close),
          ),
          title: Text(
            widget.exam.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(child: _buildContent(controller)),
      ),
    );
  }

  Widget _buildContent(ExamQuestionsController controller) {
    return switch (controller.status) {
      ExamQuestionsStatus.initial ||
      ExamQuestionsStatus.loading => const _QuestionsLoadingState(),
      ExamQuestionsStatus.empty => const _EmptyQuestionsState(),
      ExamQuestionsStatus.failure => _QuestionsErrorState(
        message:
            controller.errorMessage ?? 'No fue posible cargar las preguntas.',
        onRetry: _loadQuestions,
      ),
      ExamQuestionsStatus.success => _buildQuestionContent(controller),
    };
  }

  Widget _buildQuestionContent(ExamQuestionsController controller) {
    final question = controller.currentQuestion;

    if (question == null) {
      return const _EmptyQuestionsState();
    }

    return Column(
      children: [
        _AttemptProgressHeader(exam: widget.exam, controller: controller),
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey<String>('question-content-${question.id}'),
            padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
            child: _QuestionCard(
              question: question,
              answer: controller.currentAnswer,
              saveState: widget.saveAnswersController.stateFor(question.id),
              onChanged: (answer) {
                controller.setAnswer(questionId: question.id, answer: answer);
                widget.saveAnswersController.setLocalAnswer(
                  questionId: question.id,
                  answer: answer,
                );
              },
            ),
          ),
        ),
        _QuestionNavigation(
          controller: controller,
          saveController: widget.saveAnswersController,
          onPrevious: _goToPreviousQuestion,
          onNext: _goToNextQuestion,
          onReview: _showReview,
        ),
      ],
    );
  }
}

class _AttemptProgressHeader extends StatelessWidget {
  const _AttemptProgressHeader({required this.exam, required this.controller});

  final StudentExamSummary exam;
  final ExamQuestionsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mobileHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exam.subject, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.progressLabel,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Text(
                '${controller.answeredCount}/'
                '${controller.totalQuestions} respondidas',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: controller.progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(AppRadii.circular),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.answer,
    required this.onChanged,
    required this.saveState,
  });

  final StudentExamQuestion question;
  final String answer;
  final ValueChanged<String> onChanged;
  final AnswerSaveState saveState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _QuestionTypeBadge(type: question.type),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: AppDimensions.iconSmall,
                      color: colors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      question.timeSeconds > 0
                          ? '${question.timeMinutes} min'
                          : 'Sin límite indicado',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(question.prompt, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            _QuestionAnswerField(
              question: question,
              answer: answer,
              onChanged: onChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            _AnswerSaveIndicator(state: saveState),
          ],
        ),
      ),
    );
  }
}

class _QuestionTypeBadge extends StatelessWidget {
  const _QuestionTypeBadge({required this.type});

  final StudentQuestionType type;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final label = switch (type) {
      StudentQuestionType.open => 'Respuesta abierta',
      StudentQuestionType.multipleChoice => 'Opción múltiple',
      StudentQuestionType.matching => 'Relación de columnas',
      StudentQuestionType.programming => 'Programación',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.circular),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: colors.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _QuestionAnswerField extends StatelessWidget {
  const _QuestionAnswerField({
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final StudentExamQuestion question;
  final String answer;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return switch (question.type) {
      StudentQuestionType.open => OpenQuestionField(
        questionId: question.id,
        initialAnswer: answer,
        onChanged: onChanged,
      ),
      StudentQuestionType.multipleChoice => MultipleChoiceQuestion(
        questionId: question.id,
        options: question.options,
        selectedAnswer: answer,
        onChanged: onChanged,
      ),
      StudentQuestionType.matching => MatchingQuestionField(
        questionId: question.id,
        pairs: question.matchingPairs,
        initialAnswer: answer,
        onChanged: onChanged,
      ),
      StudentQuestionType.programming => ProgrammingQuestionField(
        questionId: question.id,
        initialAnswer: answer,
        onChanged: onChanged,
      ),
    };
  }
}

class _QuestionNavigation extends StatelessWidget {
  const _QuestionNavigation({
    required this.controller,
    required this.saveController,
    required this.onPrevious,
    required this.onNext,
    required this.onReview,
  });

  final ExamQuestionsController controller;
  final SaveAnswersController saveController;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final question = controller.currentQuestion;

    final isSaving =
        question != null && saveController.stateFor(question.id).isSaving;

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('previous-question-button'),
                  onPressed: controller.canGoPrevious && !isSaving
                      ? onPrevious
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: controller.isLastQuestion
                    ? ElevatedButton.icon(
                        key: const Key('review-answers-button'),
                        onPressed: isSaving ? null : onReview,
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Revisar'),
                      )
                    : ElevatedButton.icon(
                        key: const Key('next-question-button'),
                        onPressed: controller.canGoNext && !isSaving
                            ? onNext
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Siguiente'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionsLoadingState extends StatelessWidget {
  const _QuestionsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text('Cargando preguntas...'),
        ],
      ),
    );
  }
}

class _EmptyQuestionsState extends StatelessWidget {
  const _EmptyQuestionsState();

  @override
  Widget build(BuildContext context) {
    return const _QuestionMessageState(
      icon: Icons.quiz_outlined,
      title: 'Sin preguntas disponibles',
      description: 'El intento no contiene preguntas para mostrar.',
    );
  }
}

class _QuestionsErrorState extends StatelessWidget {
  const _QuestionsErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _QuestionMessageState(
      icon: Icons.error_outline,
      title: 'No fue posible cargar las preguntas',
      description: message,
      action: ElevatedButton.icon(
        key: const Key('retry-questions-button'),
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Reintentar'),
      ),
    );
  }
}

class _QuestionMessageState extends StatelessWidget {
  const _QuestionMessageState({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: AppDimensions.iconLarge,
                  color: colors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewMessage extends StatelessWidget {
  const _ReviewMessage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerSaveIndicator extends StatelessWidget {
  const _AnswerSaveIndicator({required this.state});

  final AnswerSaveState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final (icon, label, color) = switch (state.status) {
      AnswerSaveStatus.unchanged => (
        Icons.cloud_done_outlined,
        'Sin cambios pendientes',
        colors.onSurfaceVariant,
      ),
      AnswerSaveStatus.pending => (
        Icons.cloud_upload_outlined,
        'Pendiente de guardar',
        colors.tertiary,
      ),
      AnswerSaveStatus.saving => (
        Icons.sync,
        'Guardando respuesta...',
        colors.primary,
      ),
      AnswerSaveStatus.saved => (
        Icons.check_circle_outline,
        'Respuesta guardada',
        colors.primary,
      ),
      AnswerSaveStatus.failure => (
        Icons.error_outline,
        'No se pudo guardar',
        colors.error,
      ),
    };

    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          if (state.status == AnswerSaveStatus.saving)
            SizedBox(
              width: AppDimensions.iconSmall,
              height: AppDimensions.iconSmall,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(icon, size: AppDimensions.iconSmall, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

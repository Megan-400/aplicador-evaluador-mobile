import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/number_format.dart';
import '../../../../domain/entities/attempt_result.dart';
import '../../../../domain/entities/exam.dart';
import '../../../../domain/entities/exam_results.dart';
import '../../../../domain/repositories/results_repository.dart';
import '../../../widgets/message_with_action.dart';
import '../../../widgets/status_chip.dart';

/// Resumen y lista de intentos de un examen.
class TeacherExamResultsScreen extends StatefulWidget {
  const TeacherExamResultsScreen({
    super.key,
    required this.exam,
    required this.subject,
    required this.repository,
  });

  final Exam exam;
  final String? subject;
  final ResultsRepository repository;

  @override
  State<TeacherExamResultsScreen> createState() =>
      _TeacherExamResultsScreenState();
}

class _TeacherExamResultsScreenState extends State<TeacherExamResultsScreen> {
  ExamResults? _resultados;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar({bool silencioso = false}) async {
    setState(() {
      if (!silencioso) {
        _cargando = true;
      }
      _error = null;
    });

    try {
      final resultados = await widget.repository.getExamResults(
        widget.exam.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _resultados = resultados;
        _cargando = false;
      });
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = e.message;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exam.name)),
      body: SafeArea(child: _construirContenido()),
    );
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _error;

    if (error != null) {
      return MessageWithAction(
        message: error,
        actionLabel: 'Reintentar',
        onPressed: _cargar,
      );
    }

    final datos = _resultados;

    if (datos == null) {
      return const SizedBox.shrink();
    }

    final textos = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () => _cargar(silencioso: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          Text(
            '${widget.subject ?? 'Grupo ${widget.exam.groupId}'} · '
            'Escala ${datos.scale}',
            style: textos.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _ResumenCard(resultados: datos),
          const SizedBox(height: AppSpacing.lg),
          Text('Intentos (${datos.totalAttempts})', style: textos.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (datos.attempts.isEmpty)
            Text(
              'Aún no hay intentos en este examen.',
              style: textos.bodyMedium,
            )
          else
            for (final intento in datos.attempts)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _IntentoCard(
                  intento: intento,
                  maxScore: datos.maxScore,
                ),
              ),
        ],
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  const _ResumenCard({required this.resultados});

  final ExamResults resultados;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen', style: textos.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.md,
              children: [
                _Metrica(
                  etiqueta: 'Intentos',
                  valor: '${resultados.totalAttempts}',
                ),
                _Metrica(
                  etiqueta: 'Calificados',
                  valor: '${resultados.gradedAttempts}',
                ),
                _Metrica(
                  etiqueta: 'Pendientes',
                  valor: '${resultados.pendingAttempts}',
                ),
                _Metrica(
                  etiqueta: 'Promedio',
                  valor: _nota(resultados.average),
                ),
                _Metrica(
                  etiqueta: 'Más alta',
                  valor: _nota(resultados.highest),
                ),
                _Metrica(
                  etiqueta: 'Más baja',
                  valor: _nota(resultados.lowest),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Calificaciones sobre ${resultados.maxScore}. Un intento cuenta '
              'cuando todas sus preguntas ya están calificadas.',
              style: textos.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _nota(double? valor) {
    return valor == null ? '—' : formatGrade(valor);
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(valor, style: textos.titleLarge),
          Text(etiqueta, style: textos.bodySmall),
        ],
      ),
    );
  }
}

class _IntentoCard extends StatelessWidget {
  const _IntentoCard({required this.intento, required this.maxScore});

  final AttemptResult intento;
  final String maxScore;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final nota = intento.grade;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    intento.studentName.isEmpty
                        ? 'Sin nombre'
                        : intento.studentName,
                    style: textos.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${_etiquetaEstado(intento.status)} · Calificadas '
                    '${intento.gradedQuestions} de ${intento.totalQuestions}',
                    style: textos.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (nota == null)
                    const StatusChip(
                      label: 'Pendiente de calificar',
                      icon: Icons.hourglass_empty,
                      color: AppColors.warning,
                    )
                  else
                    const StatusChip(
                      label: 'Calificado',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                ],
              ),
            ),
            if (nota != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatGrade(nota), style: textos.headlineSmall),
                  Text('/ $maxScore', style: textos.bodySmall),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

String _etiquetaEstado(String valor) {
  if (valor.isEmpty) {
    return valor;
  }

  final texto = valor.replaceAll('_', ' ');

  return texto[0].toUpperCase() + texto.substring(1);
}
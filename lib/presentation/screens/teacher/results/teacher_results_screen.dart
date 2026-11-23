import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/exam.dart';
import '../../../../domain/repositories/exams_repository.dart';
import '../../../../domain/repositories/groups_repository.dart';
import '../../../../domain/repositories/results_repository.dart';
import '../../../widgets/exam_status_chip.dart';
import '../../../widgets/message_with_action.dart';
import 'teacher_exam_results_screen.dart';

/// Exámenes publicados o cerrados, de los que se pueden consultar resultados.
class TeacherResultsScreen extends StatefulWidget {
  const TeacherResultsScreen({
    super.key,
    required this.examsRepository,
    required this.groupsRepository,
    required this.resultsRepository,
  });

  final ExamsRepository examsRepository;
  final GroupsRepository groupsRepository;
  final ResultsRepository resultsRepository;

  @override
  State<TeacherResultsScreen> createState() => _TeacherResultsScreenState();
}

class _TeacherResultsScreenState extends State<TeacherResultsScreen> {
  List<Exam> _examenes = const [];
  Map<int, String> _materiaPorGrupo = const {};
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
      final examenes = await widget.examsRepository.getExams();
      final grupos = await widget.groupsRepository.getGroups();

      if (!mounted) {
        return;
      }

      setState(() {
        // Un borrador todavía no puede tener intentos ni resultados.
        _examenes = examenes
            .where((examen) => examen.status != ExamStatus.draft)
            .toList();
        _materiaPorGrupo = {for (final g in grupos) g.id: g.subject};
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

  void _abrirResultados(Exam examen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TeacherExamResultsScreen(
          exam: examen,
          subject: _materiaPorGrupo[examen.groupId],
          repository: widget.resultsRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
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

    if (_examenes.isEmpty) {
      return MessageWithAction(
        message: 'Aún no hay exámenes publicados.',
        actionLabel: 'Actualizar',
        onPressed: _cargar,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _cargar(silencioso: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        itemCount: _examenes.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final examen = _examenes[index];

          return _ExamenCard(
            examen: examen,
            materia: _materiaPorGrupo[examen.groupId],
            onTap: () => _abrirResultados(examen),
          );
        },
      ),
    );
  }
}

class _ExamenCard extends StatelessWidget {
  const _ExamenCard({
    required this.examen,
    required this.materia,
    required this.onTap,
  });

  final Exam examen;
  final String? materia;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(examen.name, style: textos.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      materia ?? 'Grupo ${examen.groupId}',
                      style: textos.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ExamStatusChip(status: examen.status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
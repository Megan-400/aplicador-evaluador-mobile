import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../domain/entities/exam.dart';
import '../../../../domain/repositories/exams_repository.dart';
import '../../../../domain/repositories/groups_repository.dart';
import '../../../widgets/message_with_action.dart';
import '../../../widgets/status_chip.dart';

/// Lista de exámenes del docente, con filtro por estado.
class TeacherExamsScreen extends StatefulWidget {
  const TeacherExamsScreen({
    super.key,
    required this.examsRepository,
    required this.groupsRepository,
  });

  final ExamsRepository examsRepository;
  final GroupsRepository groupsRepository;

  @override
  State<TeacherExamsScreen> createState() => _TeacherExamsScreenState();
}

class _TeacherExamsScreenState extends State<TeacherExamsScreen> {
  List<Exam> _examenes = const [];
  Map<int, String> _materiaPorGrupo = const {};
  ExamStatus? _filtro;
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
        _examenes = examenes;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exámenes')),
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
        message: 'Aún no tienes exámenes.',
        actionLabel: 'Actualizar',
        onPressed: _cargar,
      );
    }

    final visibles = _examenes
        .where((examen) => _filtro == null || examen.status == _filtro)
        .toList();

    return RefreshIndicator(
      onRefresh: () => _cargar(silencioso: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          _Filtros(
            seleccionado: _filtro,
            onSeleccion: (valor) => setState(() => _filtro = valor),
          ),
          const SizedBox(height: AppSpacing.md),
          if (visibles.isEmpty)
            Text(
              'No hay exámenes con este estado.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            for (final examen in visibles)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ExamCard(
                  examen: examen,
                  materia: _materiaPorGrupo[examen.groupId],
                ),
              ),
        ],
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.seleccionado, required this.onSeleccion});

  final ExamStatus? seleccionado;
  final ValueChanged<ExamStatus?> onSeleccion;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        ChoiceChip(
          label: const Text('Todos'),
          selected: seleccionado == null,
          onSelected: (_) => onSeleccion(null),
        ),
        ChoiceChip(
          label: const Text('Borrador'),
          selected: seleccionado == ExamStatus.draft,
          onSelected: (_) => onSeleccion(ExamStatus.draft),
        ),
        ChoiceChip(
          label: const Text('Publicado'),
          selected: seleccionado == ExamStatus.published,
          onSelected: (_) => onSeleccion(ExamStatus.published),
        ),
        ChoiceChip(
          label: const Text('Cerrado'),
          selected: seleccionado == ExamStatus.closed,
          onSelected: (_) => onSeleccion(ExamStatus.closed),
        ),
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.examen, required this.materia});

  final Exam examen;
  final String? materia;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final apertura = examen.opensAt;
    final cierre = examen.closesAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(examen.name, style: textos.titleMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(materia ?? 'Grupo ${examen.groupId}', style: textos.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            if (apertura != null)
              Text(
                'Apertura: ${formatDateTime(apertura)}',
                style: textos.bodyMedium,
              ),
            if (cierre != null)
              Text(
                'Cierre: ${formatDateTime(cierre)}',
                style: textos.bodyMedium,
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Escala ${examen.scale} · ${_etiquetaOrden(examen.order)} · '
              '${_etiquetaPlataforma(examen.platform)}',
              style: textos.bodySmall,
            ),
            Text(
              _etiquetaResultado(examen.resultVisibility),
              style: textos.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            _chipDeEstado(context, examen.status),
          ],
        ),
      ),
    );
  }
}

StatusChip _chipDeEstado(BuildContext context, ExamStatus estado) {
  final neutro = Theme.of(context).colorScheme.onSurface;

  return switch (estado) {
    ExamStatus.draft => StatusChip(
      label: 'Borrador',
      icon: Icons.edit_outlined,
      color: neutro,
    ),
    ExamStatus.published => const StatusChip(
      label: 'Publicado',
      icon: Icons.check_circle_outline,
      color: AppColors.success,
    ),
    ExamStatus.closed => StatusChip(
      label: 'Cerrado',
      icon: Icons.lock_outline,
      color: neutro,
    ),
  };
}

String _etiquetaOrden(String valor) {
  return switch (valor) {
    'aleatorio' => 'Orden aleatorio',
    'fijo' => 'Orden fijo',
    _ => valor,
  };
}

String _etiquetaPlataforma(String valor) {
  return switch (valor) {
    'web' => 'Solo web',
    'movil' => 'Solo móvil',
    'ambas' => 'Web y móvil',
    _ => valor,
  };
}

String _etiquetaResultado(String valor) {
  return switch (valor) {
    'final' => 'Resultado final visible',
    'aproximado' => 'Resultado aproximado visible',
    'oculto' => 'Resultado oculto',
    _ => valor,
  };
}
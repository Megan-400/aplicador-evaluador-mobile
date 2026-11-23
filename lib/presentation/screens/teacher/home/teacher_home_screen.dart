import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../domain/entities/exam.dart';
import '../../../../domain/entities/teacher.dart';
import '../../../../domain/entities/teacher_summary.dart';
import '../../../../domain/usecases/get_teacher_summary.dart';
import '../../../widgets/message_with_action.dart';
import '../../../widgets/theme_mode_button.dart';

/// Inicio del docente: resumen de su actividad.
class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({
    super.key,
    required this.teacher,
    required this.getSummary,
    required this.themeController,
    required this.onOpenTab,
    required this.onLogout,
  });

  final Teacher teacher;
  final GetTeacherSummary getSummary;
  final ThemeController themeController;

  /// Pide cambiar a otra pestaña de la barra inferior (por su posición).
  final ValueChanged<int> onOpenTab;
  final VoidCallback onLogout;

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  TeacherSummary? _resumen;
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
      final resumen = await widget.getSummary();

      if (!mounted) {
        return;
      }

      setState(() {
        _resumen = resumen;
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
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          ThemeModeButton(controller: widget.themeController),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
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

    final resumen = _resumen;

    if (resumen == null) {
      return const SizedBox.shrink();
    }

    final textos = Theme.of(context).textTheme;
    final porCalificar = resumen.awaitingGrading;

    return RefreshIndicator(
      onRefresh: () => _cargar(silencioso: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          Text('Hola, ${widget.teacher.name}', style: textos.headlineSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(widget.teacher.email, style: textos.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.groups_outlined,
                    value: '${resumen.activeGroups}',
                    label: 'Grupos activos',
                    detail: 'De ${resumen.totalGroups} en total',
                    onTap: () => widget.onOpenTab(1),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.assignment_outlined,
                    value: '${resumen.publishedExams}',
                    label: 'Exámenes publicados',
                    detail:
                        '${resumen.draftExams} en borrador · '
                        '${resumen.closedExams} cerrados',
                    onTap: () => widget.onOpenTab(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetricCard(
            icon: Icons.pending_actions_outlined,
            value: porCalificar?.toString() ?? '—',
            label: 'Intentos por calificar',
            detail: porCalificar == null
                ? 'No se pudo consultar. Desliza para actualizar.'
                : 'Intentos finalizados sin calificación definitiva',
            highlight: (porCalificar ?? 0) > 0,
            onTap: () => widget.onOpenTab(3),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CierreCard(
            examen: resumen.nextClosingExam,
            materia: resumen.nextClosingSubject,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.detail,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final String detail;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: highlight ? AppColors.warning : colores.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(value, style: textos.headlineSmall),
              Text(label, style: textos.titleMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(detail, style: textos.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _CierreCard extends StatelessWidget {
  const _CierreCard({required this.examen, required this.materia});

  final Exam? examen;
  final String? materia;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final proximo = examen;
    final cierre = proximo?.closesAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Próximo cierre', style: textos.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            if (proximo == null || cierre == null)
              Text(
                'No hay exámenes publicados por cerrar.',
                style: textos.bodyMedium,
              )
            else ...[
              Text(proximo.name, style: textos.titleMedium),
              Text(
                materia ?? 'Grupo ${proximo.groupId}',
                style: textos.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Cierra el ${formatDateTime(cierre)}',
                style: textos.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
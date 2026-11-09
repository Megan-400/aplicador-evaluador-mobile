import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../domain/entities/group.dart';
import '../../../../domain/entities/student.dart';
import '../../../../domain/repositories/groups_repository.dart';
import '../../../widgets/message_with_action.dart';
import '../../../widgets/status_chip.dart';

/// Detalle de un grupo: folio, estado y alumnos inscritos.
class TeacherGroupDetailScreen extends StatefulWidget {
  const TeacherGroupDetailScreen({
    super.key,
    required this.group,
    required this.repository,
  });

  final Group group;
  final GroupsRepository repository;

  @override
  State<TeacherGroupDetailScreen> createState() =>
      _TeacherGroupDetailScreenState();
}

class _TeacherGroupDetailScreenState extends State<TeacherGroupDetailScreen> {
  List<Student> _alumnos = const [];
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
      final alumnos = await widget.repository.getStudents(widget.group.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _alumnos = alumnos;
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

  Future<void> _copiarFolio() async {
    await Clipboard.setData(ClipboardData(text: widget.group.folio));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Folio copiado.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.subject)),
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

    final textos = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () => _cargar(silencioso: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          _Encabezado(grupo: widget.group, onCopiar: _copiarFolio),
          const SizedBox(height: AppSpacing.lg),
          Text('Alumnos (${_alumnos.length})', style: textos.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (_alumnos.isEmpty)
            Text(
              'Aún no hay alumnos inscritos en este grupo.',
              style: textos.bodyMedium,
            )
          else
            for (final alumno in _alumnos)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _AlumnoCard(alumno: alumno),
              ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.grupo, required this.onCopiar});

  final Group grupo;
  final VoidCallback onCopiar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final activo = grupo.isActive;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Folio del grupo', style: textos.bodySmall),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                Expanded(child: Text(grupo.folio, style: textos.titleMedium)),
                IconButton(
                  tooltip: 'Copiar folio',
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: onCopiar,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            StatusChip(
              label: activo ? 'Activo' : 'Inactivo',
              icon: activo
                  ? Icons.check_circle_outline
                  : Icons.pause_circle_outline,
              color: activo ? AppColors.success : AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlumnoCard extends StatelessWidget {
  const _AlumnoCard({required this.alumno});

  final Student alumno;

  @override
  Widget build(BuildContext context) {
    final union = alumno.joinedAt;
    final inicial = alumno.name.isEmpty ? '?' : alumno.name[0].toUpperCase();

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(inicial)),
        title: Text(alumno.name.isEmpty ? 'Sin nombre' : alumno.name),
        subtitle: union == null ? null : Text('Se unió el ${formatDate(union)}'),
      ),
    );
  }
}
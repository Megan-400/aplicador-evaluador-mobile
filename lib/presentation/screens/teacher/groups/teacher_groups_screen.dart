import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/group.dart';
import '../../../../domain/repositories/groups_repository.dart';
import '../../../widgets/message_with_action.dart';
import '../../../widgets/status_chip.dart';
import 'teacher_group_detail_screen.dart';

/// Lista de grupos del docente.
class TeacherGroupsScreen extends StatefulWidget {
  const TeacherGroupsScreen({super.key, required this.repository});

  final GroupsRepository repository;

  @override
  State<TeacherGroupsScreen> createState() => _TeacherGroupsScreenState();
}

class _TeacherGroupsScreenState extends State<TeacherGroupsScreen> {
  List<Group> _grupos = const [];
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
      final grupos = await widget.repository.getGroups();

      if (!mounted) {
        return;
      }

      setState(() {
        _grupos = grupos;
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

  Future<void> _copiarFolio(String folio) async {
    await Clipboard.setData(ClipboardData(text: folio));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Folio copiado.')));
  }

  void _abrirDetalle(Group grupo) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TeacherGroupDetailScreen(
          group: grupo,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grupos')),
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

    if (_grupos.isEmpty) {
      return MessageWithAction(
        message: 'Aún no tienes grupos.',
        actionLabel: 'Actualizar',
        onPressed: _cargar,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _cargar(silencioso: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        itemCount: _grupos.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final grupo = _grupos[index];

          return _GrupoCard(
            grupo: grupo,
            onCopiar: _copiarFolio,
            onTap: () => _abrirDetalle(grupo),
          );
        },
      ),
    );
  }
}

class _GrupoCard extends StatelessWidget {
  const _GrupoCard({
    required this.grupo,
    required this.onCopiar,
    required this.onTap,
  });

  final Group grupo;
  final ValueChanged<String> onCopiar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final activo = grupo.isActive;

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
                    Text(grupo.subject, style: textos.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Folio: ${grupo.folio}', style: textos.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
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
              IconButton(
                tooltip: 'Copiar folio',
                icon: const Icon(Icons.copy_outlined),
                onPressed: () => onCopiar(grupo.folio),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
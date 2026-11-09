import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/student_group_summary.dart';
import 'widgets/student_group_card.dart';

/// Pantalla de consulta y filtrado de grupos del alumno.
class StudentGroupsScreen extends StatefulWidget {
  const StudentGroupsScreen({
    this.groups = const [],
    this.onJoinGroup,
    super.key,
  });

  final List<StudentGroupSummary> groups;
  final VoidCallback? onJoinGroup;

  @override
  State<StudentGroupsScreen> createState() => _StudentGroupsScreenState();
}

class _StudentGroupsScreenState extends State<StudentGroupsScreen> {
  final TextEditingController _searchController = TextEditingController();

  StudentGroupStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentGroupSummary> get _filteredGroups {
    final query = _searchController.text.trim().toLowerCase();

    return widget.groups.where((group) {
      final matchesQuery =
          query.isEmpty ||
          group.name.toLowerCase().contains(query) ||
          group.subject.toLowerCase().contains(query) ||
          group.period.toLowerCase().contains(query) ||
          (group.teacherName?.toLowerCase().contains(query) ?? false);

      final matchesStatus =
          _selectedStatus == null || group.status == _selectedStatus;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty || _selectedStatus != null;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
    });
  }

  void _requestJoinGroup() {
    final callback = widget.onJoinGroup;

    if (callback != null) {
      callback();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La unión a grupos se implementará en HU-MOV-006.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        key: const PageStorageKey<String>('student-groups'),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mis grupos', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Consulta los grupos vinculados con tu cuenta.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                onPressed: _requestJoinGroup,
                tooltip: 'Unirse a un grupo',
                icon: const Icon(Icons.group_add_outlined),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _GroupsSummary(groups: widget.groups),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _requestJoinGroup,
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Unirse a un grupo'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _searchController,
            onChanged: (_) {
              setState(() {});
            },
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Buscar grupo',
              hintText: 'Nombre, materia, periodo o docente',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<StudentGroupStatus?>(
            initialValue: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Estado',
              prefixIcon: Icon(Icons.filter_alt_outlined),
            ),
            items: const [
              DropdownMenuItem<StudentGroupStatus?>(
                value: null,
                child: Text('Todos los estados'),
              ),
              DropdownMenuItem<StudentGroupStatus?>(
                value: StudentGroupStatus.active,
                child: Text('Activo'),
              ),
              DropdownMenuItem<StudentGroupStatus?>(
                value: StudentGroupStatus.completed,
                child: Text('Finalizado'),
              ),
            ],
            onChanged: (status) {
              setState(() {
                _selectedStatus = status;
              });
            },
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar filtros'),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.groups.isEmpty) {
      return const _EmptyGroupsState();
    }

    final filteredGroups = _filteredGroups;

    if (filteredGroups.isEmpty) {
      return _NoGroupResultsState(onClearFilters: _clearFilters);
    }

    return Column(
      children: [
        for (var index = 0; index < filteredGroups.length; index++) ...[
          StudentGroupCard(group: filteredGroups[index], onPressed: () {}),
          if (index < filteredGroups.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _GroupsSummary extends StatelessWidget {
  const _GroupsSummary({required this.groups});

  final List<StudentGroupSummary> groups;

  @override
  Widget build(BuildContext context) {
    final activeGroups = groups
        .where((group) => group.status == StudentGroupStatus.active)
        .length;

    return Row(
      children: [
        Expanded(
          child: _GroupSummaryCard(
            icon: Icons.groups_outlined,
            value: groups.length.toString(),
            label: 'Registrados',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _GroupSummaryCard(
            icon: Icons.check_circle_outline,
            value: activeGroups.toString(),
            label: 'Activos',
          ),
        ),
      ],
    );
  }
}

class _GroupSummaryCard extends StatelessWidget {
  const _GroupSummaryCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, size: AppDimensions.iconMedium, color: colors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyGroupsState extends StatelessWidget {
  const _EmptyGroupsState();

  @override
  Widget build(BuildContext context) {
    return const _GroupMessageCard(
      icon: Icons.groups_outlined,
      title: 'Sin grupos asociados',
      description: 'Los grupos a los que te unas aparecerán en esta sección.',
    );
  }
}

class _NoGroupResultsState extends StatelessWidget {
  const _NoGroupResultsState({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return _GroupMessageCard(
      icon: Icons.search_off_outlined,
      title: 'Sin resultados',
      description:
          'No existen grupos que coincidan con la búsqueda y los filtros.',
      action: OutlinedButton(
        onPressed: onClearFilters,
        child: const Text('Limpiar filtros'),
      ),
    );
  }
}

class _GroupMessageCard extends StatelessWidget {
  const _GroupMessageCard({
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(icon, size: AppDimensions.iconLarge, color: colors.primary),
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
              const SizedBox(height: AppSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

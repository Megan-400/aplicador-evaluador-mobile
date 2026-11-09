import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/student_grade_summary.dart';
import 'widgets/student_grade_card.dart';

/// Pantalla de consulta y filtrado de calificaciones del alumno.
class StudentGradesScreen extends StatefulWidget {
  const StudentGradesScreen({this.grades = const [], super.key});

  final List<StudentGradeSummary> grades;

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedSubject;
  StudentGradeResult? _selectedResult;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _subjects {
    final subjects =
        widget.grades.map((grade) => grade.subject).toSet().toList()..sort();

    return subjects;
  }

  List<StudentGradeSummary> get _filteredGrades {
    final query = _searchController.text.trim().toLowerCase();

    return widget.grades.where((grade) {
      final matchesQuery =
          query.isEmpty ||
          grade.examTitle.toLowerCase().contains(query) ||
          grade.subject.toLowerCase().contains(query);

      final matchesSubject =
          _selectedSubject == null || grade.subject == _selectedSubject;

      final matchesResult =
          _selectedResult == null || grade.result == _selectedResult;

      return matchesQuery && matchesSubject && matchesResult;
    }).toList();
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _selectedSubject != null ||
        _selectedResult != null;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSubject = null;
      _selectedResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        key: const PageStorageKey<String>('student-grades'),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          Text('Calificaciones', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Consulta los resultados publicados de tus evaluaciones.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          _GradesSummary(grades: widget.grades),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _searchController,
            onChanged: (_) {
              setState(() {});
            },
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Buscar calificación',
              hintText: 'Nombre del examen o materia',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _GradeFilters(
            subjects: _subjects,
            selectedSubject: _selectedSubject,
            selectedResult: _selectedResult,
            onSubjectChanged: (subject) {
              setState(() {
                _selectedSubject = subject;
              });
            },
            onResultChanged: (result) {
              setState(() {
                _selectedResult = result;
              });
            },
            onClear: _clearFilters,
            hasActiveFilters: _hasActiveFilters,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.grades.isEmpty) {
      return const _EmptyGradesState();
    }

    final filteredGrades = _filteredGrades;

    if (filteredGrades.isEmpty) {
      return _NoGradeResultsState(onClearFilters: _clearFilters);
    }

    return Column(
      children: [
        for (var index = 0; index < filteredGrades.length; index++) ...[
          StudentGradeCard(grade: filteredGrades[index], onPressed: () {}),
          if (index < filteredGrades.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _GradesSummary extends StatelessWidget {
  const _GradesSummary({required this.grades});

  final List<StudentGradeSummary> grades;

  @override
  Widget build(BuildContext context) {
    final published = grades.length;
    final passed = grades
        .where((grade) => grade.result == StudentGradeResult.passed)
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.assignment_turned_in_outlined,
            value: published.toString(),
            label: 'Publicadas',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SummaryCard(
            icon: Icons.check_circle_outline,
            value: passed.toString(),
            label: 'Aprobadas',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppDimensions.iconMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeFilters extends StatelessWidget {
  const _GradeFilters({
    required this.subjects,
    required this.selectedSubject,
    required this.selectedResult,
    required this.onSubjectChanged,
    required this.onResultChanged,
    required this.onClear,
    required this.hasActiveFilters,
  });

  final List<String> subjects;
  final String? selectedSubject;
  final StudentGradeResult? selectedResult;
  final ValueChanged<String?> onSubjectChanged;
  final ValueChanged<StudentGradeResult?> onResultChanged;
  final VoidCallback onClear;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String?>(
          initialValue: selectedSubject,
          decoration: const InputDecoration(
            labelText: 'Materia',
            prefixIcon: Icon(Icons.menu_book_outlined),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todas las materias'),
            ),
            for (final subject in subjects)
              DropdownMenuItem<String?>(value: subject, child: Text(subject)),
          ],
          onChanged: onSubjectChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<StudentGradeResult?>(
          initialValue: selectedResult,
          decoration: const InputDecoration(
            labelText: 'Resultado',
            prefixIcon: Icon(Icons.filter_alt_outlined),
          ),
          items: const [
            DropdownMenuItem<StudentGradeResult?>(
              value: null,
              child: Text('Todos los resultados'),
            ),
            DropdownMenuItem<StudentGradeResult?>(
              value: StudentGradeResult.passed,
              child: Text('Aprobado'),
            ),
            DropdownMenuItem<StudentGradeResult?>(
              value: StudentGradeResult.notPassed,
              child: Text('No aprobado'),
            ),
          ],
          onChanged: onResultChanged,
        ),
        if (hasActiveFilters) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: const Text('Limpiar filtros'),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyGradesState extends StatelessWidget {
  const _EmptyGradesState();

  @override
  Widget build(BuildContext context) {
    return const _GradeMessageCard(
      icon: Icons.bar_chart_outlined,
      title: 'Sin calificaciones disponibles',
      description:
          'Las calificaciones aparecerán cuando los resultados sean '
          'publicados.',
    );
  }
}

class _NoGradeResultsState extends StatelessWidget {
  const _NoGradeResultsState({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return _GradeMessageCard(
      icon: Icons.search_off_outlined,
      title: 'Sin resultados',
      description:
          'No existen calificaciones que coincidan con la búsqueda y los '
          'filtros.',
      action: OutlinedButton(
        onPressed: onClearFilters,
        child: const Text('Limpiar filtros'),
      ),
    );
  }
}

class _GradeMessageCard extends StatelessWidget {
  const _GradeMessageCard({
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

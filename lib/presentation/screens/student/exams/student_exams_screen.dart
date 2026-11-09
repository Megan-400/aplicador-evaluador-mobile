import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/student_exam_summary.dart';
import 'widgets/student_exam_card.dart';

/// Pantalla de consulta y filtrado de exámenes del alumno.
class StudentExamsScreen extends StatefulWidget {
  const StudentExamsScreen({this.exams = const [], super.key});

  final List<StudentExamSummary> exams;

  @override
  State<StudentExamsScreen> createState() => _StudentExamsScreenState();
}

class _StudentExamsScreenState extends State<StudentExamsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedSubject;
  StudentExamStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _subjects {
    final subjects = widget.exams.map((exam) => exam.subject).toSet().toList()
      ..sort();

    return subjects;
  }

  List<StudentExamSummary> get _filteredExams {
    final query = _searchController.text.trim().toLowerCase();

    return widget.exams.where((exam) {
      final matchesQuery =
          query.isEmpty ||
          exam.title.toLowerCase().contains(query) ||
          exam.subject.toLowerCase().contains(query);

      final matchesSubject =
          _selectedSubject == null || exam.subject == _selectedSubject;

      final matchesStatus =
          _selectedStatus == null || exam.status == _selectedStatus;

      return matchesQuery && matchesSubject && matchesStatus;
    }).toList();
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _selectedSubject != null ||
        _selectedStatus != null;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSubject = null;
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        key: const PageStorageKey<String>('student-exams'),
        padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
        children: [
          Text('Exámenes', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Consulta tus evaluaciones por materia y estado.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _searchController,
            onChanged: (_) {
              setState(() {});
            },
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Buscar examen',
              hintText: 'Nombre del examen o materia',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ExamFilters(
            subjects: _subjects,
            selectedSubject: _selectedSubject,
            selectedStatus: _selectedStatus,
            onSubjectChanged: (subject) {
              setState(() {
                _selectedSubject = subject;
              });
            },
            onStatusChanged: (status) {
              setState(() {
                _selectedStatus = status;
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
    if (widget.exams.isEmpty) {
      return const _EmptyExamsState();
    }

    final filteredExams = _filteredExams;

    if (filteredExams.isEmpty) {
      return _NoExamResultsState(onClearFilters: _clearFilters);
    }

    return Column(
      children: [
        for (var index = 0; index < filteredExams.length; index++) ...[
          StudentExamCard(exam: filteredExams[index], onPressed: () {}),
          if (index < filteredExams.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _ExamFilters extends StatelessWidget {
  const _ExamFilters({
    required this.subjects,
    required this.selectedSubject,
    required this.selectedStatus,
    required this.onSubjectChanged,
    required this.onStatusChanged,
    required this.onClear,
    required this.hasActiveFilters,
  });

  final List<String> subjects;
  final String? selectedSubject;
  final StudentExamStatus? selectedStatus;
  final ValueChanged<String?> onSubjectChanged;
  final ValueChanged<StudentExamStatus?> onStatusChanged;
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
        DropdownButtonFormField<StudentExamStatus?>(
          initialValue: selectedStatus,
          decoration: const InputDecoration(
            labelText: 'Estado',
            prefixIcon: Icon(Icons.filter_alt_outlined),
          ),
          items: const [
            DropdownMenuItem<StudentExamStatus?>(
              value: null,
              child: Text('Todos los estados'),
            ),
            DropdownMenuItem<StudentExamStatus?>(
              value: StudentExamStatus.available,
              child: Text('Disponible'),
            ),
            DropdownMenuItem<StudentExamStatus?>(
              value: StudentExamStatus.upcoming,
              child: Text('Próximo'),
            ),
            DropdownMenuItem<StudentExamStatus?>(
              value: StudentExamStatus.completed,
              child: Text('Finalizado'),
            ),
            DropdownMenuItem<StudentExamStatus?>(
              value: StudentExamStatus.closed,
              child: Text('Cerrado'),
            ),
          ],
          onChanged: onStatusChanged,
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

class _EmptyExamsState extends StatelessWidget {
  const _EmptyExamsState();

  @override
  Widget build(BuildContext context) {
    return _ExamMessageCard(
      icon: Icons.assignment_outlined,
      title: 'Sin exámenes disponibles',
      description:
          'Los exámenes asignados aparecerán en esta sección cuando sean '
          'publicados.',
    );
  }
}

class _NoExamResultsState extends StatelessWidget {
  const _NoExamResultsState({required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return _ExamMessageCard(
      icon: Icons.search_off_outlined,
      title: 'Sin resultados',
      description:
          'No existen exámenes que coincidan con la búsqueda y los filtros.',
      action: OutlinedButton(
        onPressed: onClearFilters,
        child: const Text('Limpiar filtros'),
      ),
    );
  }
}

class _ExamMessageCard extends StatelessWidget {
  const _ExamMessageCard({
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

import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart';
import '../../domain/entities/teacher.dart';
import '../../domain/repositories/exams_repository.dart';
import '../../domain/repositories/groups_repository.dart';
import '../../domain/repositories/results_repository.dart';
import '../../domain/usecases/get_teacher_summary.dart';
import '../screens/teacher/exams/teacher_exams_screen.dart';
import '../screens/teacher/groups/teacher_groups_screen.dart';
import '../screens/teacher/home/teacher_home_screen.dart';
import '../screens/teacher/results/teacher_results_screen.dart';

/// Contenedor principal de navegación del portal móvil del docente.
class TeacherAppShell extends StatefulWidget {
  const TeacherAppShell({
    super.key,
    required this.teacher,
    required this.groupsRepository,
    required this.examsRepository,
    required this.resultsRepository,
    required this.getTeacherSummary,
    required this.themeController,
    required this.onLogout,
  });

  final Teacher teacher;
  final GroupsRepository groupsRepository;
  final ExamsRepository examsRepository;
  final ResultsRepository resultsRepository;
  final GetTeacherSummary getTeacherSummary;
  final ThemeController themeController;
  final VoidCallback onLogout;

  @override
  State<TeacherAppShell> createState() => _TeacherAppShellState();
}

class _TeacherAppShellState extends State<TeacherAppShell> {
  int _selectedIndex = 0;

  void _selectDestination(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TeacherHomeScreen(
            teacher: widget.teacher,
            getSummary: widget.getTeacherSummary,
            themeController: widget.themeController,
            onOpenTab: _selectDestination,
            onLogout: widget.onLogout,
          ),
          TeacherGroupsScreen(repository: widget.groupsRepository),
          TeacherExamsScreen(
            examsRepository: widget.examsRepository,
            groupsRepository: widget.groupsRepository,
          ),
          TeacherResultsScreen(
            examsRepository: widget.examsRepository,
            groupsRepository: widget.groupsRepository,
            resultsRepository: widget.resultsRepository,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Grupos',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Exámenes',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Resultados',
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../domain/entities/teacher.dart';
import '../../domain/repositories/exams_repository.dart';
import '../../domain/repositories/groups_repository.dart';
import '../screens/teacher/exams/teacher_exams_screen.dart';
import '../screens/teacher/groups/teacher_groups_screen.dart';

/// Contenedor principal de navegación del portal móvil del docente.
class TeacherAppShell extends StatefulWidget {
  const TeacherAppShell({
    super.key,
    required this.teacher,
    required this.groupsRepository,
    required this.examsRepository,
    required this.onLogout,
  });

  final Teacher teacher;
  final GroupsRepository groupsRepository;
  final ExamsRepository examsRepository;
  final VoidCallback onLogout;

  @override
  State<TeacherAppShell> createState() => _TeacherAppShellState();
}

class _TeacherAppShellState extends State<TeacherAppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _PlaceholderScreen(
            title: 'Hola, ${widget.teacher.name}',
            onLogout: widget.onLogout,
          ),
          TeacherGroupsScreen(repository: widget.groupsRepository),
          TeacherExamsScreen(
            examsRepository: widget.examsRepository,
            groupsRepository: widget.groupsRepository,
          ),
          const _PlaceholderScreen(title: 'Resultados'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
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

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, this.onLogout});

  final String title;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (onLogout != null)
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: onLogout,
            ),
        ],
      ),
      body: const Center(child: Text('Próximamente')),
    );
  }
}
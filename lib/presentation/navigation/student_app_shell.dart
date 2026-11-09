import 'package:flutter/material.dart';

import '../screens/student/exams/student_exams_screen.dart';
import '../screens/student/grades/student_grades_screen.dart';
import '../screens/student/groups/student_groups_screen.dart';
import '../screens/student/home/student_home_screen.dart';

/// Contenedor principal de navegación del portal móvil del alumno.
/// `IndexedStack` conserva el estado básico de cada pantalla cuando el alumno
/// cambia de destino.
class StudentAppShell extends StatefulWidget {
  const StudentAppShell({super.key});

  @override
  State<StudentAppShell> createState() => _StudentAppShellState();
}

class _StudentAppShellState extends State<StudentAppShell> {
  int _selectedIndex = 0;

  /// Cambia el destino seleccionado en la navegación inferior.
  void _selectDestination(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      StudentHomeScreen(
        onOpenExams: () => _selectDestination(1),
        onOpenGrades: () => _selectDestination(2),
        onOpenGroups: () => _selectDestination(3),
      ),
      const StudentExamsScreen(),
      const StudentGradesScreen(),
      const StudentGroupsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: destinations),
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
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Exámenes',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Calificaciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Mis grupos',
          ),
        ],
      ),
    );
  }
}

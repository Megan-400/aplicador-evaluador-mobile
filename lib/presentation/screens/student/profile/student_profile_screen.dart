import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/student_dashboard.dart';
import '../../../../domain/entities/student_group_summary.dart';

/// Muestra la información de la sesión local del alumno.
class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({
    required this.dashboard,
    required this.onSignOut,
    super.key,
  });

  final StudentDashboard dashboard;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    StudentGroupSummary? selectedGroup;

    for (final group in dashboard.groups) {
      if (group.id == dashboard.student.selectedGroupId.toString()) {
        selectedGroup = group;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('student-profile-back-button'),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Atrás',
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Mi perfil'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: AppDimensions.iconLarge,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              dashboard.student.name,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Alumno',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _ProfileInformationRow(
                      icon: Icons.badge_outlined,
                      label: 'Identificador',
                      value: dashboard.student.id.toString(),
                    ),
                    const Divider(height: AppSpacing.lg),
                    _ProfileInformationRow(
                      icon: Icons.menu_book_outlined,
                      label: 'Grupo seleccionado',
                      value: selectedGroup?.subject ?? 'Grupo no disponible',
                    ),
                    if (selectedGroup != null) ...[
                      const Divider(height: AppSpacing.lg),
                      _ProfileInformationRow(
                        icon: Icons.tag,
                        label: 'Folio',
                        value: selectedGroup.folioCode,
                      ),
                      if (selectedGroup.teacherName != null) ...[
                        const Divider(height: AppSpacing.lg),
                        _ProfileInformationRow(
                          icon: Icons.person_outline,
                          label: 'Docente',
                          value: selectedGroup.teacherName!,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              key: const Key('student-sign-out-button'),
              onPressed: onSignOut,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadii.control),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: colors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'La sesión se conserva solamente mientras '
                      'la aplicación permanece abierta.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInformationRow extends StatelessWidget {
  const _ProfileInformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: AppDimensions.minimumTouchTarget,
          height: AppDimensions.minimumTouchTarget,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          child: Icon(icon, color: colors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(value, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

/// Muestra los componentes principales del sistema visual compartido.
///
/// Esta pantalla se utiliza únicamente para validar el tema durante TK-004.
class DesignSystemPreviewScreen extends StatelessWidget {
  const DesignSystemPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sistema visual')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
          children: [
            Text('Aplicador/Evaluador', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Vista de validación para los modos claro y oscuro.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _secondaryTextColor(theme.brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Tipografía',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Título de página',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Título de sección', style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Título de tarjeta', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Texto principal de dieciséis píxeles.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Texto secundario y auxiliar.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Botones',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Continuar'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Acción secundaria'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(onPressed: () {}, child: const Text('Cancelar')),
                  const SizedBox(height: AppSpacing.md),
                  const ElevatedButton(
                    onPressed: null,
                    child: Text('Acción deshabilitada'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _Section(
              title: 'Campos',
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Folio',
                      hintText: 'Ingresa el folio del grupo',
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Código',
                      hintText: 'Ejemplo: ABC123',
                      errorText: 'El código no es válido.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Tarjeta y opción',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Examen de Matemáticas',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '20 preguntas · 45 minutos',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: AppDimensions.answerOptionMinHeight,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadii.control),
                      border: Border.all(color: colors.primary),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.radio_button_checked, color: colors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Opción de respuesta seleccionada',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Estados',
              child: Column(
                children: [
                  _StatusMessage(
                    icon: Icons.check_circle_outline,
                    text: 'La operación se completó correctamente.',
                    color: AppColors.success,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StatusMessage(
                    icon: Icons.warning_amber_rounded,
                    text: 'Revisa los datos antes de continuar.',
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StatusMessage(
                    icon: Icons.error_outline,
                    text: 'No fue posible completar la operación.',
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _secondaryTextColor(Brightness brightness) {
    return brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

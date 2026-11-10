import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'join_group_code.dart';

typedef JoinGroupSubmitCallback = Future<JoinGroupResult> Function(String code);

/// Formulario para solicitar la unión del alumno a un grupo.
class JoinGroupSheet extends StatefulWidget {
  const JoinGroupSheet({required this.onSubmit, super.key});

  final JoinGroupSubmitCallback onSubmit;

  @override
  State<JoinGroupSheet> createState() => _JoinGroupSheetState();
}

class _JoinGroupSheetState extends State<JoinGroupSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  bool _isSubmitting = false;
  JoinGroupResult? _result;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final code = JoinGroupCode.normalize(_codeController.text);

    final confirmed = await _requestConfirmation(code);

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _result = null;
    });

    final result = await widget.onSubmit(code);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
      _result = result;
    });
  }

  Future<bool> _requestConfirmation(String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar código'),
          content: Text(
            '¿Deseas solicitar tu incorporación al grupo con el código '
            '$code?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  void _normalizeCode(String value) {
    final normalized = JoinGroupCode.normalize(value);

    if (normalized == value) {
      return;
    }

    _codeController.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.mobileHorizontal,
          right: AppSpacing.mobileHorizontal,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: AppDimensions.minimumTouchTarget,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Unirse a un grupo', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ingresa el código proporcionado por el docente.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  key: const Key('join-group-code-field'),
                  controller: _codeController,
                  enabled: !_isSubmitting,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  maxLength: JoinGroupCode.requiredLength,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Código del grupo',
                    hintText: 'Ejemplo: ABC123',
                    prefixIcon: Icon(Icons.key_outlined),
                    counterText: '',
                  ),
                  validator: JoinGroupCode.validate,
                  onChanged: _normalizeCode,
                  onFieldSubmitted: (_) {
                    if (!_isSubmitting) {
                      _continue();
                    }
                  },
                ),
                if (_result != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _JoinGroupFeedback(result: _result!),
                ],
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  key: const Key('join-group-submit-button'),
                  onPressed: _isSubmitting ? null : _continue,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: AppDimensions.iconMedium,
                          height: AppDimensions.iconMedium,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continuar'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JoinGroupFeedback extends StatelessWidget {
  const _JoinGroupFeedback({required this.result});

  final JoinGroupResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final success = result.isSuccess;

    final color = success ? colors.primary : colors.error;
    final icon = success ? Icons.check_circle_outline : Icons.error_outline;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    success ? 'Solicitud completada' : 'No fue posible unirse',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(result.message, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

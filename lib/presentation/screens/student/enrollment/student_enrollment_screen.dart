import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/enrollment/student_enrollment.dart';
import '../../../state/enrollment/student_enrollment_controller.dart';
import 'student_name_input_formatter.dart';
import 'student_name_validator.dart';

/// Crea el perfil de un alumno que ingresa por primera vez.
/// El código personal permanece únicamente en memoria y se presenta
/// después de que el backend confirma la inscripción.
class StudentEnrollmentScreen extends StatefulWidget {
  const StudentEnrollmentScreen({
    required this.groupFolio,
    required this.controller,
    required this.onContinue,
    super.key,
  });

  final String groupFolio;
  final StudentEnrollmentController controller;

  /// Permite continuar al dashboard usando el código recién generado.
  final Future<void> Function({
    required String groupFolio,
    required String accessCode,
  })
  onContinue;

  @override
  State<StudentEnrollmentScreen> createState() {
    return _StudentEnrollmentScreenState();
  }
}

class _StudentEnrollmentScreenState extends State<StudentEnrollmentScreen> {
  final TextEditingController _nameController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();

  bool _codeAcknowledged = false;
  bool _isContinuing = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);

    _nameController.dispose();
    _nameFocusNode.dispose();

    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  String? _validateName() {
    return StudentNameValidator.validate(_nameController.text);
  }

  Future<void> _createProfile() async {
    if (widget.controller.isLoading) {
      return;
    }

    final validationError = _validateName();

    setState(() {
      _nameError = validationError;
    });

    if (validationError != null) {
      _nameFocusNode.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();

    final normalizedName = StudentNameValidator.normalize(_nameController.text);

    _nameController.value = TextEditingValue(
      text: normalizedName,
      selection: TextSelection.collapsed(offset: normalizedName.length),
    );

    await widget.controller.create(
      groupFolio: widget.groupFolio,
      studentName: normalizedName,
    );
  }

  Future<void> _copyCode() async {
    final code = widget.controller.accessCode;

    if (code == null || code.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: code));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Código personal copiado.')));
  }

  Future<void> _continueToPortal() async {
    final enrollment = widget.controller.enrollment;

    if (enrollment == null || !_codeAcknowledged || _isContinuing) {
      return;
    }

    setState(() {
      _isContinuing = true;
    });

    try {
      await widget.onContinue(
        groupFolio: widget.groupFolio,
        accessCode: enrollment.accessCode,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isContinuing = false;
        });
      }
    }
  }

  Future<bool> _confirmExit() async {
    if (!widget.controller.isSuccess || _codeAcknowledged) {
      return true;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('¿Ya guardaste tu código?'),
          content: const Text(
            'El código personal puede no volver a mostrarse. '
            'Cópialo o anótalo antes de salir.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Permanecer aquí'),
            ),
            ElevatedButton(
              key: const Key('confirm-exit-enrollment-button'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Salir de todos modos'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _requestExit() async {
    final confirmed = await _confirmExit();

    if (!confirmed || !mounted) {
      return;
    }

    widget.controller.reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.controller.isSuccess || _codeAcknowledged,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _requestExit();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: const Key('enrollment-exit-button'),
            onPressed: widget.controller.isLoading ? null : _requestExit,
            tooltip: 'Salir de la inscripción',
            icon: const Icon(Icons.close),
          ),
          title: const Text('Crear perfil'),
        ),
        body: SafeArea(
          child: switch (widget.controller.status) {
            StudentEnrollmentStatus.success => _buildSuccess(
              widget.controller.enrollment!,
            ),
            _ => _buildForm(),
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    final theme = Theme.of(context);
    final controller = widget.controller;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.person_add_alt_1_outlined,
                size: AppDimensions.iconLarge,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Primera vez',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Crea tu perfil para ingresar al grupo.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              _GroupFolioCard(groupFolio: widget.groupFolio),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                key: const Key('student-enrollment-name-field'),
                controller: _nameController,
                focusNode: _nameFocusNode,
                enabled: !controller.isLoading,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                maxLength: 150,
                autofillHints: const [AutofillHints.name],
                inputFormatters: [
                  StudentNameInputFormatter(),
                  LengthLimitingTextInputFormatter(150),
                ],
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() {
                      _nameError = null;
                    });
                  }
                },
                onSubmitted: (_) {
                  _createProfile();
                },
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  hintText: 'Escribe tu nombre completo',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  errorText: _nameError,
                  helperText: 'Este nombre quedará asociado con el grupo.',
                ),
              ),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _EnrollmentErrorMessage(message: controller.errorMessage!),
              ],
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                key: const Key('create-student-profile-button'),
                onPressed: controller.isLoading ? null : _createProfile,
                icon: controller.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_outlined),
                label: Text(
                  controller.isLoading ? 'Creando perfil...' : 'Crear perfil',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'El sistema generará un código personal de acceso. '
                'Guárdalo para ingresar nuevamente.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess(StudentEnrollment enrollment) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.mobileHorizontal),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.check_circle_outline, size: 72, color: colors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Inscripción completada',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                enrollment.studentName,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              _EnrollmentResultCard(
                subject: enrollment.subject,
                groupFolio: widget.groupFolio,
              ),
              const SizedBox(height: AppSpacing.md),
              _AccessCodeCard(
                accessCode: enrollment.accessCode,
                onCopy: _copyCode,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: colors.onErrorContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Guarda este código. Puede no volver '
                        'a mostrarse y lo necesitarás para '
                        'ingresar nuevamente.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              CheckboxListTile(
                key: const Key('enrollment-code-acknowledgement'),
                value: _codeAcknowledged,
                onChanged: _isContinuing
                    ? null
                    : (value) {
                        setState(() {
                          _codeAcknowledged = value ?? false;
                        });
                      },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text('Ya guardé mi código personal'),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton.icon(
                key: const Key('continue-after-enrollment-button'),
                onPressed: !_codeAcknowledged || _isContinuing
                    ? null
                    : _continueToPortal,
                icon: _isContinuing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward),
                label: Text(
                  _isContinuing ? 'Cargando portal...' : 'Continuar al portal',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupFolioCard extends StatelessWidget {
  const _GroupFolioCard({required this.groupFolio});

  final String groupFolio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      child: Row(
        children: [
          Icon(Icons.groups_outlined, color: colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Folio del grupo', style: theme.textTheme.bodySmall),
                Text(
                  groupFolio,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EnrollmentResultCard extends StatelessWidget {
  const _EnrollmentResultCard({
    required this.subject,
    required this.groupFolio,
  });

  final String subject;
  final String groupFolio;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Materia'),
            const SizedBox(height: AppSpacing.xs),
            Text(subject, style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: AppSpacing.lg),
            const Text('Folio del grupo'),
            const SizedBox(height: AppSpacing.xs),
            SelectableText(
              groupFolio,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessCodeCard extends StatelessWidget {
  const _AccessCodeCard({required this.accessCode, required this.onCopy});

  final String accessCode;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      label: 'Código personal de acceso',
      value: accessCode,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.control),
          border: Border.all(color: colors.primary, width: 2),
        ),
        child: Column(
          children: [
            Text('Tu código personal', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            SelectableText(
              accessCode,
              key: const Key('generated-access-code'),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              key: const Key('copy-enrollment-code-button'),
              onPressed: onCopy,
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copiar código'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentErrorMessage extends StatelessWidget {
  const _EnrollmentErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

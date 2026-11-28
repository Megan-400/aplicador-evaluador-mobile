import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../state/enrollment/student_enrollment_controller.dart';
import '../../../state/student_dashboard_controller.dart';
import '../enrollment/student_enrollment_screen.dart';
import 'student_access_code.dart';

/// Pantalla de identificación inicial del alumno.
/// El acceso se divide en dos pasos:
/// 1. Identificación del grupo.
/// 2. Selección entre crear un perfil o ingresar con código.

/// El folio, el código personal y la inscripción permanecen únicamente
/// en memoria durante la sesión.
class StudentAccessScreen extends StatefulWidget {
  const StudentAccessScreen({
    required this.controller,
    required this.enrollmentController,
    super.key,
  });

  final StudentDashboardController controller;
  final StudentEnrollmentController enrollmentController;

  @override
  State<StudentAccessScreen> createState() {
    return _StudentAccessScreenState();
  }
}

enum StudentAccessMode { firstTime, existingStudent }

class _StudentAccessScreenState extends State<StudentAccessScreen> {
  final GlobalKey<FormState> _folioFormKey = GlobalKey<FormState>();

  final GlobalKey<FormState> _accessFormKey = GlobalKey<FormState>();

  final TextEditingController _folioController = TextEditingController();

  final TextEditingController _accessCodeController = TextEditingController();

  StudentAccessMode _accessMode = StudentAccessMode.existingStudent;

  int _currentStep = 0;
  bool _isFolioValid = false;
  bool _isAccessCodeValid = false;
  bool _obscureAccessCode = true;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);

    _folioController.dispose();
    _accessCodeController.dispose();

    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _normalizeFolio(String value) {
    final normalized = StudentAccessCode.normalize(value);

    if (normalized != value) {
      _folioController.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    final isValid = StudentAccessCode.validateFolio(normalized) == null;

    if (_isFolioValid != isValid) {
      setState(() {
        _isFolioValid = isValid;
      });
    }
  }

  void _normalizeAccessCode(String value) {
    final normalized = StudentAccessCode.normalize(value);

    if (normalized != value) {
      _accessCodeController.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    final isValid = StudentAccessCode.validateAccessCode(normalized) == null;

    if (_isAccessCodeValid != isValid) {
      setState(() {
        _isAccessCodeValid = isValid;
      });
    }
  }

  void _continueToAccess() {
    FocusScope.of(context).unfocus();

    final formIsValid = _folioFormKey.currentState?.validate() ?? false;

    if (!_isFolioValid || !formIsValid) {
      return;
    }

    widget.enrollmentController.reset();

    setState(() {
      _currentStep = 1;
      _accessMode = StudentAccessMode.existingStudent;
      _accessCodeController.clear();
      _isAccessCodeValid = false;
      _obscureAccessCode = true;
    });
  }

  void _returnToGroup() {
    FocusScope.of(context).unfocus();

    widget.enrollmentController.reset();

    setState(() {
      _currentStep = 0;
      _accessMode = StudentAccessMode.existingStudent;
      _accessCodeController.clear();
      _isAccessCodeValid = false;
      _obscureAccessCode = true;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final formIsValid = _accessFormKey.currentState?.validate() ?? false;

    if (widget.controller.isLoading ||
        !_isFolioValid ||
        !_isAccessCodeValid ||
        !formIsValid) {
      return;
    }

    final success = await widget.controller.signIn(
      folio: StudentAccessCode.normalize(_folioController.text),
      accessCode: StudentAccessCode.normalize(_accessCodeController.text),
    );

    _accessCodeController.clear();

    if (mounted) {
      setState(() {
        _isAccessCodeValid = false;
      });
    }

    if (!success || !mounted) {
      return;
    }
  }

  Future<void> _openEnrollment() async {
    final groupFolio = StudentAccessCode.normalize(_folioController.text);

    if (!_isFolioValid || groupFolio.isEmpty) {
      return;
    }

    widget.enrollmentController.reset();

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (enrollmentContext) {
          return StudentEnrollmentScreen(
            groupFolio: groupFolio,
            controller: widget.enrollmentController,
            onContinue:
                ({
                  required String groupFolio,
                  required String accessCode,
                }) async {
                  final signedIn = await widget.controller.signIn(
                    folio: groupFolio,
                    accessCode: accessCode,
                  );

                  if (!signedIn || !enrollmentContext.mounted) {
                    return;
                  }

                  Navigator.of(enrollmentContext).pop();
                },
          );
        },
      ),
    );
  }

  void _changeAccessMode(Set<StudentAccessMode> selection) {
    if (selection.isEmpty || widget.controller.isLoading) {
      return;
    }

    final nextMode = selection.first;

    if (nextMode == _accessMode) {
      return;
    }

    FocusScope.of(context).unfocus();

    widget.enrollmentController.reset();

    setState(() {
      _accessMode = nextMode;
      _accessCodeController.clear();
      _isAccessCodeValid = false;
      _obscureAccessCode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _AccessBackground()),
          SafeArea(
            child: Column(
              children: [
                const _AccessSiteHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.mobileHorizontal,
                      vertical: AppSpacing.lg,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          children: [
                            const _AccessEyebrow(),
                            const SizedBox(height: AppSpacing.md),
                            Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  Container(height: 4, color: colors.primary),
                                  Padding(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.lg,
                                    ),
                                    child: Column(
                                      children: [
                                        _AccessSteps(currentStep: _currentStep),
                                        const SizedBox(height: AppSpacing.lg),
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          child: _currentStep == 0
                                              ? _buildGroupStep()
                                              : _buildAccessStep(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const _AccessCardFooter(),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const _AccessTagline(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const _AccessSiteFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupStep() {
    final theme = Theme.of(context);
    final isLoading = widget.controller.isLoading;

    return Form(
      key: _folioFormKey,
      child: Column(
        key: const ValueKey<String>('folio-step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AccessBrandLogo(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Bienvenido a BigBitByte',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ingresa al grupo de tu docente',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            key: const Key('student-folio-field'),
            controller: _folioController,
            enabled: !isLoading,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            maxLength: 20,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Folio del grupo',
              hintText: 'Ejemplo: BBB2026',
              prefixIcon: Icon(Icons.tag),
              counterText: '',
              helperText:
                  'Tu docente te compartirá el folio '
                  'de tu grupo.',
            ),
            validator: StudentAccessCode.validateFolio,
            onChanged: _normalizeFolio,
            onFieldSubmitted: (_) {
              if (_isFolioValid && !isLoading) {
                _continueToAccess();
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            key: const Key('student-folio-continue-button'),
            onPressed: isLoading || !_isFolioValid ? null : _continueToAccess,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continuar'),
                SizedBox(width: AppSpacing.xs),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Form(
      key: _accessFormKey,
      child: Column(
        key: const ValueKey<String>('access-step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AccessWelcomeIcon(icon: Icons.person_outline),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Identifícate',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _accessMode == StudentAccessMode.firstTime
                ? 'Crea tu perfil para ingresar '
                      'por primera vez.'
                : 'Usa tu código para consultar '
                      'tu perfil y tus resultados.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildValidatedFolioCard(theme: theme, colors: colors),
          const SizedBox(height: AppSpacing.lg),
          _buildAccessModeSelector(),
          const SizedBox(height: AppSpacing.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _accessMode == StudentAccessMode.firstTime
                ? _buildFirstTimeAccess()
                : _buildExistingStudentAccess(),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            key: const Key('return-to-group-button'),
            onPressed: widget.controller.isLoading ? null : _returnToGroup,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Cambiar grupo'),
          ),
        ],
      ),
    );
  }

  Widget _buildValidatedFolioCard({
    required ThemeData theme,
    required ColorScheme colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.control),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_outlined, color: colors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FOLIO DEL GRUPO', style: theme.textTheme.labelSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(_folioController.text, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Formato del grupo verificado.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: colors.primary),
        ],
      ),
    );
  }

  Widget _buildAccessModeSelector() {
    return SegmentedButton<StudentAccessMode>(
      key: const Key('student-access-mode-selector'),
      segments: const [
        ButtonSegment<StudentAccessMode>(
          value: StudentAccessMode.firstTime,
          icon: Icon(Icons.person_add_outlined),
          label: Text('Primera vez'),
        ),
        ButtonSegment<StudentAccessMode>(
          value: StudentAccessMode.existingStudent,
          icon: Icon(Icons.key_outlined),
          label: Text('Ya tengo código'),
        ),
      ],
      selected: {_accessMode},
      onSelectionChanged: widget.controller.isLoading
          ? null
          : _changeAccessMode,
    );
  }

  Widget _buildFirstTimeAccess() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      key: const ValueKey<String>('first-time-access'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                  'Crea tu perfil y recibe un '
                  'código personal. Deberás guardar '
                  'ese código para ingresar nuevamente.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          key: const Key('open-student-enrollment-button'),
          onPressed: _openEnrollment,
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Crear perfil'),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Tu código será generado por el sistema '
          'cuando la inscripción sea confirmada.',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildExistingStudentAccess() {
    final theme = Theme.of(context);
    final isLoading = widget.controller.isLoading;

    return Column(
      key: const ValueKey<String>('existing-student-access'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('student-access-code-field'),
          controller: _accessCodeController,
          enabled: !isLoading,
          obscureText: _obscureAccessCode,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          maxLength: 6,
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          ],
          decoration: InputDecoration(
            labelText: 'Código de acceso',
            hintText: 'Ejemplo: ABCD27',
            prefixIcon: const Icon(Icons.lock_outline),
            counterText: '',
            helperText:
                'Escribe las cuatro letras y '
                'dos números de tu código.',
            suffixIcon: IconButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        _obscureAccessCode = !_obscureAccessCode;
                      });
                    },
              tooltip: _obscureAccessCode ? 'Mostrar código' : 'Ocultar código',
              icon: Icon(
                _obscureAccessCode
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: StudentAccessCode.validateAccessCode,
          onChanged: _normalizeAccessCode,
          onFieldSubmitted: (_) {
            if (_isAccessCodeValid && !isLoading) {
              _submit();
            }
          },
        ),
        if (widget.controller.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          _AccessErrorMessage(message: widget.controller.errorMessage!),
        ],
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(
          key: const Key('student-access-button'),
          onPressed: isLoading || !_isAccessCodeValid ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  width: AppDimensions.iconMedium,
                  height: AppDimensions.iconMedium,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Ingresar al portal'),
                    SizedBox(width: AppSpacing.xs),
                    Icon(Icons.arrow_forward),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Tu código es personal y no se '
          'almacena en el dispositivo.',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AccessBackground extends StatelessWidget {
  const _AccessBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0, 0.48, 1],
          colors: [
            isDark ? const Color(0xFF0C1523) : colors.primaryContainer,
            theme.scaffoldBackgroundColor,
            isDark ? const Color(0xFF101C2C) : colors.surface,
          ],
        ),
      ),
    );
  }
}

class _AccessSiteHeader extends StatelessWidget {
  const _AccessSiteHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mobileHorizontal,
        vertical: AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showPortalLabel = constraints.maxWidth >= 340;

          return Row(
            children: [
              SizedBox(
                width: AppDimensions.minimumTouchTarget,
                height: AppDimensions.minimumTouchTarget,
                child: Image.asset(
                  'assets/images/branding/logo.png',
                  fit: BoxFit.contain,
                  semanticLabel: 'Logotipo de BigBitByte',
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.school_outlined,
                      color: colors.primary,
                      size: AppDimensions.iconLarge,
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'BigBit'),
                      TextSpan(
                        text: 'Byte.',
                        style: TextStyle(color: colors.primary),
                      ),
                    ],
                  ),
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showPortalLabel) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.circular),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: colors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Portal del estudiante',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AccessEyebrow extends StatelessWidget {
  const _AccessEyebrow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 24, height: 2, color: colors.primary),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            'TU SIGUIENTE GRAN IDEA EMPIEZA AQUÍ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.primary,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _AccessSteps extends StatelessWidget {
  const _AccessSteps({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AccessStep(
            number: 1,
            label: 'Tu grupo',
            active: currentStep == 0,
            completed: currentStep > 0,
          ),
        ),
        Container(
          width: AppSpacing.lg,
          height: 2,
          color: Theme.of(context).colorScheme.outline,
        ),
        Expanded(
          child: _AccessStep(
            number: 2,
            label: 'Tu acceso',
            active: currentStep == 1,
            completed: false,
          ),
        ),
      ],
    );
  }
}

class _AccessStep extends StatelessWidget {
  const _AccessStep({
    required this.number,
    required this.label,
    required this.active,
    required this.completed,
  });

  final int number;
  final String label;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final highlighted = active || completed;

    return Column(
      children: [
        Container(
          width: AppDimensions.iconLarge,
          height: AppDimensions.iconLarge,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: highlighted ? colors.primary : colors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: highlighted ? colors.primary : colors.outline,
            ),
          ),
          child: completed
              ? Icon(
                  Icons.check,
                  color: colors.onPrimary,
                  size: AppDimensions.iconSmall,
                )
              : Text(
                  number.toString(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: highlighted ? colors.onPrimary : colors.onSurface,
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: active ? colors.primary : colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _AccessWelcomeIcon extends StatelessWidget {
  const _AccessWelcomeIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: AppDimensions.accessLogoSize,
        height: AppDimensions.accessLogoSize,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadii.dialog),
        ),
        child: Icon(icon, size: AppDimensions.iconLarge, color: colors.primary),
      ),
    );
  }
}

class _AccessCardFooter extends StatelessWidget {
  const _AccessCardFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        '◇  Un espacio seguro para aprender y crear.',
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AccessTagline extends StatelessWidget {
  const _AccessTagline();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Pequeños pasos. '),
          TextSpan(
            text: 'Grandes posibilidades.',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }
}

class _AccessSiteFooter extends StatelessWidget {
  const _AccessSiteFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        '© 2026 BigBitByte · Aprender. Crear. Crecer.',
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AccessErrorMessage extends StatelessWidget {
  const _AccessErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadii.control),
          border: Border.all(color: colors.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colors.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessBrandLogo extends StatelessWidget {
  const _AccessBrandLogo();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: AppDimensions.accessLogoSize,
        height: AppDimensions.accessLogoSize,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadii.dialog),
          border: Border.all(color: colors.primary.withValues(alpha: 0.20)),
        ),
        child: Image.asset(
          'assets/images/branding/logo.png',
          fit: BoxFit.contain,
          semanticLabel: 'Logotipo de BigBitByte',
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.school_outlined,
              color: colors.primary,
              size: AppDimensions.iconLarge,
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/auth_session.dart';
import '../../../../domain/repositories/auth_repository.dart';

/// Pantalla de inicio de sesión del docente.
class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({
    super.key,
    required this.authRepository,
    required this.onLoggedIn,
  });

  final AuthRepository authRepository;
  final ValueChanged<AuthSession> onLoggedIn;

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _ocultarPass = true;
  bool _cargando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _cargando = true);

    try {
      final sesion = await widget.authRepository.login(
        email: _correoCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) {
        return;
      }

      widget.onLoggedIn(sesion);
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final secundario = theme.brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.dialog),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 96,
                        height: 96,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'BigBitByte',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Portal del docente',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: secundario,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Escribe tu correo.';
                      }
                      if (!valor.contains('@')) {
                        return 'El correo no es válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _ocultarPass,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarPass
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _ocultarPass = !_ocultarPass),
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Escribe tu contraseña.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _cargando ? null : _entrar,
                    child: _cargando
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : const Text('Iniciar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
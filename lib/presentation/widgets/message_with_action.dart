import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Mensaje centrado con un botón de acción (reintentar, actualizar...).
class MessageWithAction extends StatelessWidget {
  const MessageWithAction({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
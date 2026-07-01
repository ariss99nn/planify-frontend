import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberDialog {
  static Future<void> error({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.person_off_outlined,
    String buttonLabel = 'Entendido',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.border),
        ),
        icon: Icon(icon, color: Colors.redAccent, size: 48),
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  static Future<T?> confirm<T>({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel  = 'Cancelar',
    IconData icon       = Icons.help_outline,
    bool destructive    = false,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.border),
        ),
        icon: Icon(
          icon,
          color: destructive ? Colors.redAccent : AppTheme.primary,
          size: 40,
        ),
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            style: destructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                  )
                : null,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../api/api_service.dart';
import '../theme/theme.dart';
import 'cyber_snackbar.dart';

class CyberEmailChangeDialog {
  /// Paso 1 — solicitar cambio de email.
  /// Retorna true si se envió el código correctamente.
  static Future<bool> requestChange(BuildContext context) async {
    final emailCtrl = TextEditingController();
    final formKey   = GlobalKey<FormState>();

    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => _RequestDialog(
        emailCtrl: emailCtrl,
        formKey: formKey,
      ),
    );

    emailCtrl.dispose();
    return sent ?? false;
  }

  /// Paso 2 — confirmar con el código recibido.
  static Future<void> confirmChange(BuildContext context) async {
    final codeCtrl = TextEditingController();
    final formKey  = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        codeCtrl: codeCtrl,
        formKey: formKey,
      ),
    );

    codeCtrl.dispose();
  }

  /// Flujo completo: paso 1 → si OK, paso 2.
  static Future<void> show(BuildContext context) async {
    final sent = await requestChange(context);
    if (sent && context.mounted) {
      await confirmChange(context);
    }
  }
}

// ── Diálogo paso 1 ────────────────────────────────────────────────────────

class _RequestDialog extends StatefulWidget {
  final TextEditingController emailCtrl;
  final GlobalKey<FormState> formKey;

  const _RequestDialog({
    required this.emailCtrl,
    required this.formKey,
  });

  @override
  State<_RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<_RequestDialog> {
  bool sending = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      title: const Text('Cambiar correo'),
      content: Form(
        key: widget.formKey,
        child: TextFormField(
          controller: widget.emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Nuevo correo',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Ingresa el correo';
            if (!v.contains('@')) return 'Email inválido';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: sending ? null : _submit,
          child: sending
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                )
              : const Text('Enviar código'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!widget.formKey.currentState!.validate()) return;
    setState(() => sending = true);
    try {
      await context
          .read<AuthProvider>()
          .requestEmailChange(widget.emailCtrl.text.trim());
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}

// ── Diálogo paso 2 ────────────────────────────────────────────────────────

class _ConfirmDialog extends StatefulWidget {
  final TextEditingController codeCtrl;
  final GlobalKey<FormState> formKey;

  const _ConfirmDialog({
    required this.codeCtrl,
    required this.formKey,
  });

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  bool confirming = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      title: const Text('Verificar nuevo correo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ingresa el código que enviamos a tu nuevo correo.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          Form(
            key: widget.formKey,
            child: TextFormField(
              controller: widget.codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                letterSpacing: 6,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              decoration: const InputDecoration(
                labelText: 'Código de verificación',
                prefixIcon: Icon(Icons.pin_outlined),
                counterText: '',
              ),
              validator: (v) =>
                  v == null || v.trim().length < 4 ? 'Ingresa el código' : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: confirming ? null : _submit,
          child: confirming
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                )
              : const Text('Confirmar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!widget.formKey.currentState!.validate()) return;
    setState(() => confirming = true);
    try {
      await context
          .read<AuthProvider>()
          .confirmEmailChange(widget.codeCtrl.text.trim());
      if (!mounted) return;
      Navigator.pop(context);
      CyberSnackbar.success(context, 'Correo actualizado correctamente.');
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => confirming = false);
    }
  }
}
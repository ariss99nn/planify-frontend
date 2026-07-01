import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../../../core/api/api_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final codeCtrl  = TextEditingController();
  final passCtrl  = TextEditingController();
  final pass2Ctrl = TextEditingController();
  final _formKey  = GlobalKey<FormState>();

  bool loading = false;
  bool obscure1 = true;
  bool obscure2 = true;

  // ── Deep link / query param extraction: intacto ───────────────────────────
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      codeCtrl.text = args;
      return;
    }

    final uri = Uri.base;
    final queryCode = uri.queryParameters['code'];
    if (queryCode != null && queryCode.isNotEmpty) {
      codeCtrl.text = queryCode;
      return;
    }

    if (uri.pathSegments.length >= 2 &&
        uri.pathSegments[uri.pathSegments.length - 2] == 'reset-password') {
      codeCtrl.text = uri.pathSegments.last;
      return;
    }

    final fragment = uri.fragment;
    if (fragment.isNotEmpty) {
      final parts = fragment.split('/');
      if (parts.length >= 3 &&
          parts[parts.length - 2] == 'reset-password') {
        codeCtrl.text = parts.last;
      }
    }
  }

  // ── Lógica intacta ────────────────────────────────────────────────────────
  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      await AuthService.confirmPasswordReset(
        code:     codeCtrl.text.trim(),
        password: passCtrl.text,
      );
      if (!mounted) return;
      CyberSnackbar.success(context, 'Contraseña actualizada. Inicia sesión.');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      child: CyberPageWrapper(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CyberIconHero(
                icon: Icons.lock_reset_outlined,
                title: 'PLANIFY SENA',
                subtitle: 'Restablece tu contraseña',
              ),
              const SizedBox(height: 32),

              CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CyberDividerLabel(label: 'Nueva contraseña'),
                    const SizedBox(height: 20),

                    Text(
                      'Ingresa el código recibido por correo y tu nueva contraseña.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 24),

                    // Código — mismo estilo OTP que VerifyEmailScreen
                    TextFormField(
                      controller: codeCtrl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        letterSpacing: 6,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Código de recuperación',
                        prefixIcon: Icon(Icons.vpn_key_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Ingresa el código' : null,
                    ),
                    const SizedBox(height: 14),

                    // Nueva contraseña
                    TextFormField(
                      controller: passCtrl,
                      obscureText: obscure1,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscure1
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => obscure1 = !obscure1),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 8
                          ? 'Mínimo 8 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Confirmar contraseña
                    TextFormField(
                      controller: pass2Ctrl,
                      obscureText: obscure2,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscure2
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => obscure2 = !obscure2),
                        ),
                      ),
                      validator: (v) => v != passCtrl.text
                          ? 'Las contraseñas no coinciden'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    CyberButton(
                      label: 'Restablecer contraseña',
                      loading: loading,
                      onPressed: resetPassword,
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (_) => false),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                      ),
                      child: const Text('← Volver al login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
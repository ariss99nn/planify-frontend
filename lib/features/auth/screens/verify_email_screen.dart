import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../../core/api/api_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading   = false;
  bool resending = false;

  // ── Lógica intacta ────────────────────────────────────────────────────────
  Future<void> verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      await context.read<AuthProvider>().verifyEmail(
            email: widget.email,
            code:  codeCtrl.text.trim(),
          );
      if (!mounted) return;
      CyberSnackbar.success(context, 'Correo verificado correctamente. Inicia sesión.');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resendCode() async {
    setState(() => resending = true);
    try {
      await context.read<AuthProvider>().resendVerification(widget.email);
      if (!mounted) return;
      CyberSnackbar.success(context, 'Nuevo código enviado a tu correo.');
    } catch (_) {
      if (!mounted) return;
      CyberSnackbar.error(context, 'No se pudo reenviar el código.');
    } finally {
      if (mounted) setState(() => resending = false);
    }
  }

  @override
  void dispose() {
    codeCtrl.dispose();
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
                icon: Icons.verified_outlined,
                title: 'PLANIFY SENA',
                subtitle: 'Verificación de correo',
              ),
              const SizedBox(height: 32),

              CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CyberDividerLabel(label: 'Verifica tu correo'),
                    const SizedBox(height: 20),

                    Text(
                      'Ingresa el código de 6 dígitos que enviamos a:',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 12),

                    CyberEmailChip(email: widget.email),
                    const SizedBox(height: 28),

                    TextFormField(
                      controller: codeCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 8,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Código de verificación',
                        hintText: '— — — — — —',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa el código';
                        if (v.length != 6) return 'Debe tener 6 dígitos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    CyberButton(
                      label: 'Verificar correo',
                      loading: loading,
                      onPressed: verify,
                    ),
                    const SizedBox(height: 8),

                    // Reenviar código
                    TextButton.icon(
                      onPressed: resending ? null : resendCode,
                      icon: resending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            )
                          : const Icon(Icons.refresh_outlined,
                              size: 18, color: AppTheme.primary),
                      label: Text(
                        resending ? 'Reenviando...' : 'Reenviar código',
                        style: const TextStyle(color: AppTheme.primary),
                      ),
                    ),

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
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../../../core/api/api_service.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  bool loading    = false;

  // ── Lógica intacta ────────────────────────────────────────────────────────
  Future<void> sendRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      await AuthService.checkEmailExists(emailCtrl.text.trim());
      await AuthService.requestPasswordReset(emailCtrl.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/reset-password');

    } on ApiException catch (e) {
      if (!mounted) return;

      final esCorreoInexistente =
          e.statusCode == 400 &&
          e.message.toLowerCase().contains('no existe una cuenta');

      if (esCorreoInexistente) {
        await CyberDialog.error(              // ← antes era showDialog inline
          context: context,
          icon: Icons.person_off_outlined,
          title: 'Correo no registrado',
          message:
              'El correo "${emailCtrl.text.trim()}" no está asociado a ninguna cuenta.\n\n'
              'Verifica que sea el correo con el que te registraste.',
        );
      } else {
        CyberSnackbar.error(context, e.message);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      showBackButton: true,
      child: CyberPageWrapper(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero sin imagen — ícono grande con glow
              _buildIconHero(),
              const SizedBox(height: 32),

              CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CyberDividerLabel(label: 'Recuperar contraseña'),
                    const SizedBox(height: 20),

                    Text(
                      'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email institucional',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa tu email';
                        }
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(v.trim())) {
                          return 'Ingresa un correo válido (ej: usuario@dominio.com)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    CyberButton(
                      label: 'Enviar recuperación',
                      loading: loading,
                      onPressed: sendRequest,
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

  // Hero alternativo: ícono con glow en vez de imagen
  // Reutilizable para pantallas sin logo dedicado (reset, verify, etc.)
  Widget _buildIconHero() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.25),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.4),
              width: 1.5,
            ),
            color: AppTheme.surface.withOpacity(0.6),
          ),
          child: const Icon(
            Icons.lock_reset_outlined,
            size: 44,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'PLANIFY SENA',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Recuperación de acceso',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(letterSpacing: 0.4),
        ),
      ],
    );
  }
}
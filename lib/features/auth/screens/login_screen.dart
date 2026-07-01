import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../../core/api/api_service.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/widgets/widgets.dart';   // ← un solo import

import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../home/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl      = TextEditingController();
  final passCtrl       = TextEditingController();
  final _formKey       = GlobalKey<FormState>();
  bool loading         = false;
  bool obscurePassword = true;

  // ← SingleTickerProviderStateMixin ya NO está aquí,
  //   lo maneja CyberPageWrapper internamente

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => loading = true);

    try {
      await context.read<AuthProvider>().login(
            emailCtrl.text.trim(),
            passCtrl.text,
          );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'not_verified') {
        _showNotVerifiedDialog(emailCtrl.text.trim());
        return;
      }
      final msg = switch (e.code) {
        'inactive'            => 'Tu cuenta está desactivada. Contacta al administrador.',
        'invalid_credentials' => 'Correo o contraseña incorrectos.',
        'session_expired'     => 'Sesión expirada. Inicia sesión nuevamente.',
        _                     => e.message,
      };
      CyberSnackbar.error(context, msg);   // ← antes era _showError()
    } catch (_) {
      if (!mounted) return;
      CyberSnackbar.error(context, 'Error de conexión con el servidor.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showNotVerifiedDialog(String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Correo no verificado'),
        content: const Text(
          'Tu cuenta aún no está verificada. ¿Quieres que te enviemos un nuevo código?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/verify-email', arguments: email);
            },
            child: const Text('Ir a verificar'),
          ),
        ],
      ),
    );
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
              CyberHeroLogo(
                imagePath: AppImages.logoLogin,
                title: 'PLANIFY SENA',
                subtitle: 'Sistema de gestión académica',
              ),
              const SizedBox(height: 32),
              CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CyberDividerLabel(label: 'Inicia sesión'),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email institucional',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        final email = v?.trim() ?? '';
                        if (email.isEmpty) return 'Ingresa tu email';
                        if (!email.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: passCtrl,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => login(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                              () => obscurePassword = !obscurePassword),
                        ),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingresa tu contraseña' : null,
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen()),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    CyberButton(
                      label: 'Iniciar sesión',
                      loading: loading,
                      onPressed: login,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿No tienes cuenta?',
                            style: Theme.of(context).textTheme.bodySmall),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text('Regístrate'),
                        ),
                      ],
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
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/auth_provider.dart';
import '../../../core/api/api_service.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombreCtrl   = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final emailCtrl    = TextEditingController();
  final passCtrl     = TextEditingController();
  final pass2Ctrl    = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _picker  = ImagePicker();

  bool       loading      = false;
  XFile?     _imagenXFile;
  Uint8List? _imagenBytes;

  // ── Lógica de imagen: intacta, solo se mueve a método privado ─────────────
  Future<void> _seleccionarImagen() async {
    if (kIsWeb) {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() { _imagenXFile = picked; _imagenBytes = bytes; });
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle visual
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primary),
              title: const Text('Tomar foto'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (picked == null) return;
                final bytes = await picked.readAsBytes();
                setState(() { _imagenXFile = picked; _imagenBytes = bytes; });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primary),
              title: const Text('Elegir de galería'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (picked == null) return;
                final bytes = await picked.readAsBytes();
                setState(() { _imagenXFile = picked; _imagenBytes = bytes; });
              },
            ),
            if (_imagenXFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Quitar foto',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() { _imagenXFile = null; _imagenBytes = null; });
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Lógica de registro: intacta ───────────────────────────────────────────
  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      await context.read<AuthProvider>().register(
        nombre:    nombreCtrl.text.trim(),
        apellido:  apellidoCtrl.text.trim(),
        email:     emailCtrl.text.trim(),
        password:  passCtrl.text,
        password2: pass2Ctrl.text,
        imagen:    _imagenXFile,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/verify-email',
        (_) => false,
        arguments: emailCtrl.text.trim().toLowerCase(),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      CyberSnackbar.error(context, 'Error al registrar. Intenta nuevamente.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    apellidoCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CyberScaffold(
      showBackButton: true,           // ← muestra la flecha back automático
      child: CyberPageWrapper(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CyberHeroLogo(
                imagePath: AppImages.logoRegistro,
                title: 'PLANIFY SENA',
                subtitle: 'Crea tu cuenta',
              ),
              const SizedBox(height: 32),
              CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CyberDividerLabel(label: 'Datos de registro'),
                    const SizedBox(height: 24),

                    // Avatar
                    CyberAvatarPicker(
                      imageBytes: _imagenBytes,
                      onTap: _seleccionarImagen,
                    ),
                    const SizedBox(height: 24),

                    // Nombre + Apellido en fila (solo desktop/tablet)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 340) {
                          return Row(
                            children: [
                              Expanded(child: _fieldNombre()),
                              const SizedBox(width: 12),
                              Expanded(child: _fieldApellido()),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _fieldNombre(),
                            const SizedBox(height: 14),
                            _fieldApellido(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // Email
                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Ingresa tu email';
                        if (!v.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Contraseña
                    TextFormField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) =>
                          v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
                    ),
                    const SizedBox(height: 14),

                    // Confirmar contraseña
                    TextFormField(
                      controller: pass2Ctrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) => v != passCtrl.text
                          ? 'Las contraseñas no coinciden'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    CyberButton(
                      label: 'Crear cuenta',
                      loading: loading,
                      onPressed: register,
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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

  // Extraídos para el LayoutBuilder sin repetir código
  Widget _fieldNombre() => TextFormField(
        controller: nombreCtrl,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Nombre',
          prefixIcon: Icon(Icons.person_outline),
        ),
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null,
      );

  Widget _fieldApellido() => TextFormField(
        controller: apellidoCtrl,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Apellido',
          prefixIcon: Icon(Icons.person_outline),
        ),
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Ingresa tu apellido' : null,
      );
}
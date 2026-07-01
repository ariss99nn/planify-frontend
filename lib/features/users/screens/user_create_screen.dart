import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../providers/user_provider.dart';
import '../../../core/api/api_service.dart';
import '../../../core/theme/theme.dart';

class UserCreateScreen extends StatefulWidget {
  const UserCreateScreen({super.key});

  @override
  State<UserCreateScreen> createState() => _UserCreateScreenState();
}

class _UserCreateScreenState extends State<UserCreateScreen> {
  final nombreCtrl    = TextEditingController();
  final apellidoCtrl  = TextEditingController();
  final emailCtrl     = TextEditingController();
  final passwordCtrl  = TextEditingController();
  final password2Ctrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  final _picker       = ImagePicker();

  bool loading         = false;
  bool obscurePassword  = true;
  bool obscurePassword2 = true;
  String selectedRol   = 'ESTUDIANTE';

  XFile?     _imagenXFile;   // para enviar al servidor
  Uint8List? _imagenBytes;   // para preview (web + móvil)

  final roles = ['ESTUDIANTE', 'ADMINISTRATIVO', 'DOCENTE'];

  // ── Selección de imagen ──────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imagenXFile = picked;
      _imagenBytes = bytes;
    });
  }

  Future<void> _seleccionarImagen() async {
    // En web no hay cámara nativa confiable — mostrar solo galería
    if (kIsWeb) {
      await _pickImage(ImageSource.gallery);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagenXFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Quitar foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imagenXFile = null;
                    _imagenBytes = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  // ── Crear usuario ────────────────────────────────────────────────────────

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      await UserService.createUser(
        nombre:   nombreCtrl.text.trim(),
        apellido: apellidoCtrl.text.trim(),
        email:    emailCtrl.text.trim().toLowerCase(),
        password: passwordCtrl.text,
        rol:      selectedRol,
        imagen:   _imagenXFile,
      );

      if (!mounted) return;
      context.read<UserProvider>().fetchUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario creado exitosamente'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    apellidoCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    password2Ctrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Usuario'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Avatar picker ────────────────────────────────────
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: AppTheme.primary.withOpacity(0.12),
                      backgroundImage: _imagenBytes != null
                          ? MemoryImage(_imagenBytes!)
                          : null,
                      child: _imagenBytes == null
                          ? const Icon(
                              Icons.person,
                              size: 52,
                              color: AppTheme.primary,
                            )
                          : null,
                    ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primary,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _imagenBytes == null
                    ? 'Agregar foto (opcional)'
                    : 'Toca para cambiar',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // ── Nombre ───────────────────────────────────────────
              TextFormField(
                controller: nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el nombre';
                  if (v.length < 2) return 'Mínimo 2 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Apellido ─────────────────────────────────────────
              TextFormField(
                controller: apellidoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el apellido';
                  if (v.length < 2) return 'Mínimo 2 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Email ────────────────────────────────────────────
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa el email';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Contraseña ───────────────────────────────────────
              TextFormField(
                controller: passwordCtrl,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                  if (v.length < 8) return 'Mínimo 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Confirmar contraseña ─────────────────────────────
              TextFormField(
                controller: password2Ctrl,
                obscureText: obscurePassword2,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword2
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => obscurePassword2 = !obscurePassword2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirma la contraseña';
                  if (v != passwordCtrl.text)
                    return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Rol ──────────────────────────────────────────────
              DropdownButtonFormField<String>(
                value: selectedRol,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.security),
                ),
                items: roles
                    .map((rol) =>
                        DropdownMenuItem(value: rol, child: Text(rol)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedRol = value);
                },
              ),
              const SizedBox(height: 32),

              // ── Botón crear ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _createUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppTheme.textPrimary),
                          ),
                        )
                      : const Text(
                          'Crear Usuario',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
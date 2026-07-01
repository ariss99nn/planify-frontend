import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../../core/api/api_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nombreCtrl   = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final _formKey     = GlobalKey<FormState>();
  final _picker      = ImagePicker();

  bool       saving          = false;
  XFile?     _imagenXFile;
  Uint8List? _imagenBytes;
  String?    _imagenUrlActual;
  bool       _imagenEliminada = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      nombreCtrl.text   = user.nombre;
      apellidoCtrl.text = user.apellido;
      _imagenUrlActual  = ApiService.buildMediaUrl(user.imagenUrl);
    }
  }

  // ── Lógica de imagen: intacta ─────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imagenXFile     = picked;
      _imagenBytes     = bytes;
      _imagenEliminada = false;
    });
  }

  Future<void> _seleccionarImagen() async {
    if (kIsWeb) { await _pickImage(ImageSource.gallery); return; }

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
            Container(
              width: 36, height: 4,
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
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primary),
              title: const Text('Elegir de galería'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
            if (_imagenXFile != null || _imagenUrlActual != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Quitar foto',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imagenXFile     = null;
                    _imagenBytes     = null;
                    _imagenUrlActual = null;
                    _imagenEliminada = true;
                  });
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  ImageProvider? get _avatarImage {
    if (_imagenBytes != null) return MemoryImage(_imagenBytes!);
    if (_imagenUrlActual != null && _imagenUrlActual!.isNotEmpty) {
      return NetworkImage(_imagenUrlActual!);
    }
    return null;
  }

  // ── Guardar perfil: intacto ───────────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await context.read<AuthProvider>().updateProfile(
            nombre:         nombreCtrl.text.trim(),
            apellido:       apellidoCtrl.text.trim(),
            imagen:         _imagenXFile,
            eliminarImagen: _imagenEliminada,
          );
      if (!mounted) return;
      CyberSnackbar.success(context, 'Perfil actualizado exitosamente.');
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    apellidoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: CyberCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CyberDividerLabel(label: 'Editar perfil'),
                    const SizedBox(height: 24),

                    // Avatar
                    Center(
                      child: CyberEditAvatar(
                        image: _avatarImage,
                        onTap: _seleccionarImagen,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Nombre + Apellido responsive
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
                        return Column(children: [
                          _fieldNombre(),
                          const SizedBox(height: 14),
                          _fieldApellido(),
                        ]);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email solo lectura + botón cambiar
                    TextFormField(
                      initialValue: user?.email ?? '',
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: const Icon(Icons.email_outlined),
                        suffixIcon: TextButton(
                          onPressed: () =>
                              CyberEmailChangeDialog.show(context),
                          child: const Text('Cambiar'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    CyberButton(
                      label: 'Guardar cambios',
                      loading: saving,
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
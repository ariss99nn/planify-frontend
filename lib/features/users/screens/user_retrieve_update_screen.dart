import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../providers/user_provider.dart';
import '../../../core/api/api_service.dart';
import '../../../core/theme/theme.dart';

class UserRetrieveUpdateScreen extends StatefulWidget {
  final int userId;

  const UserRetrieveUpdateScreen({super.key, required this.userId});

  @override
  State<UserRetrieveUpdateScreen> createState() =>
      _UserRetrieveUpdateScreenState();
}

class _UserRetrieveUpdateScreenState extends State<UserRetrieveUpdateScreen> {
  final nombreCtrl   = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final emailCtrl    = TextEditingController();
  final _formKey     = GlobalKey<FormState>();
  final _picker      = ImagePicker();

  bool loading          = true;
  bool updating         = false;
  bool _imagenEliminada = false;
  bool _isActive        = true;
  String selectedRol    = 'ESTUDIANTE';

  String?    _imagenUrlActual;
  XFile?     _imagenXFile;
  Uint8List? _imagenBytes;

  final roles = ['ESTUDIANTE', 'ADMINISTRATIVO', 'DOCENTE'];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await UserService.getUser(widget.userId);
      if (!mounted) return;

      setState(() {
        nombreCtrl.text   = user['nombre']    ?? '';
        apellidoCtrl.text = user['apellido']  ?? '';
        emailCtrl.text    = user['email']     ?? '';
        selectedRol       = user['rol']       ?? 'ESTUDIANTE';
        _isActive         = user['is_active'] as bool? ?? true;
        _imagenUrlActual  = ApiService.buildMediaUrl(user['imagen_url'] as String?);
        loading           = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700),
      );
      Navigator.pop(context);
    }
  }

  // ── Placeholder ───────────────────────────────────────────────────────────

  Widget _placeholder() {
    return Container(
      color: AppTheme.primary.withOpacity(0.12),
      child: const Center(
        child: Icon(Icons.person, size: 52, color: AppTheme.primary),
      ),
    );
  }

  bool get _tieneImagen =>
      _imagenBytes != null ||
      (_imagenUrlActual != null && _imagenUrlActual!.isNotEmpty);

  // ── Selección de imagen ───────────────────────────────────────────────────

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
            if (_tieneImagen)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Quitar foto',
                    style: TextStyle(color: Colors.red)),
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
          ],
        ),
      ),
    );
  }

  // ── Actualizar ────────────────────────────────────────────────────────────

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => updating = true);

    try {
      final result = await UserService.updateUser(
        id: widget.userId,
        data: {
          'nombre':   nombreCtrl.text.trim(),
          'apellido': apellidoCtrl.text.trim(),
          'email':    emailCtrl.text.trim().toLowerCase(),
          'rol':      selectedRol,
        },
        imagen:         _imagenXFile,
        eliminarImagen: _imagenEliminada,
      );

      debugPrint('📦 updateUser response: $result');

      if (!mounted) return;
      context.read<UserProvider>().fetchUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario actualizado exitosamente'),
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
      if (mounted) setState(() => updating = false);
    }
  }

  // ── Desactivar ────────────────────────────────────────────────────────────

  Future<void> _deactivateUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.person_off_outlined,
            color: Colors.red, size: 40),
        title: const Text('Desactivar usuario'),
        content: const Text('¿Estás seguro de desactivar este usuario?\n\nEl usuario no podrá iniciar sesión.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desactivar',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => updating = true);

    try {
      await UserService.deactivateUser(widget.userId);
      if (!mounted) return;
      setState(() => _isActive = false);
      context.read<UserProvider>().fetchUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario desactivado exitosamente'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      if (mounted) setState(() => updating = false);
    }
  }

  // ── Activar ───────────────────────────────────────────────────────────────

  Future<void> _activateUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.person_add_outlined,
            color: Colors.green, size: 40),
        title: const Text('Activar usuario'),
        content: const Text('¿Estás seguro de activar este usuario?\n\nEl usuario podrá iniciar sesión nuevamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Activar',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => updating = true);

    try {
      await UserService.activateUser(widget.userId);
      if (!mounted) return;
      setState(() => _isActive = true);
      context.read<UserProvider>().fetchUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario activado exitosamente'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      if (mounted) setState(() => updating = false);
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    apellidoCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuario'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textPrimary,
        actions: [
          if (!_isActive)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              onPressed: updating ? null : _activateUser,
              tooltip: 'Activar usuario',
            )
          else
            IconButton(
              icon: const Icon(Icons.person_off_outlined),
              onPressed: updating ? null : _deactivateUser,
              tooltip: 'Desactivar usuario',
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Avatar picker ──────────────────────────────────
                    GestureDetector(
                      onTap: _seleccionarImagen,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 104,
                              height: 104,
                              child: _imagenBytes != null
                                  ? Image.memory(
                                      _imagenBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : (_imagenUrlActual != null &&
                                          _imagenUrlActual!.isNotEmpty)
                                      ? Image.network(
                                          _imagenUrlActual!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _placeholder(),
                                        )
                                      : _placeholder(),
                            ),
                          ),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primary,
                            child: const Icon(Icons.camera_alt,
                                size: 16, color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _tieneImagen
                          ? 'Toca para cambiar'
                          : 'Agregar foto (opcional)',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),

                    // Badge de estado activo/inactivo
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isActive
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isActive
                              ? Colors.green.shade300
                              : Colors.red.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isActive
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            size: 14,
                            color: _isActive
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isActive ? 'Activo' : 'Inactivo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isActive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Nombre ─────────────────────────────────────────
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

                    // ── Apellido ───────────────────────────────────────
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

                    // ── Email ──────────────────────────────────────────
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

                    // ── Rol ────────────────────────────────────────────
                    DropdownButtonFormField<String>(
                      value: selectedRol,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        prefixIcon: Icon(Icons.security),
                      ),
                      items: roles
                          .map((rol) => DropdownMenuItem(
                                value: rol,
                                child: Text(rol),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null)
                          setState(() => selectedRol = value);
                      },
                    ),
                    const SizedBox(height: 32),

                    // ── Botón actualizar ───────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: updating ? null : _updateUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: updating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(AppTheme.textPrimary),
                                ),
                              )
                            : const Text(
                                'Actualizar Usuario',
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
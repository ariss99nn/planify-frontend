// lib/features/docentes/presentation/widgets/views/docente_list_view.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../core/api/api_service.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../providers/docente_provider.dart';
import '../../../domain/entities/docente_entity.dart';
import '../../../../../features/users/services/user_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Lista principal de docentes
// ─────────────────────────────────────────────────────────────────────────────

class DocenteListView extends StatefulWidget {
  final void Function(int id) onDetail;
  final VoidCallback onCreateTap;

  const DocenteListView({
    super.key,
    required this.onDetail,
    required this.onCreateTap,
  });

  @override
  State<DocenteListView> createState() => _DocenteListViewState();
}

class _DocenteListViewState extends State<DocenteListView> {
  final _searchCtrl = TextEditingController();
  bool? _filtroEstado;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DocenteProvider>().fetchDocentes());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<DocenteProvider>().fetchDocentes(
      search: _searchCtrl.text,
      estado: _filtroEstado,
    );
  }

  Widget _buildAvatar(DocenteEntity d) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primary, width: 2),
      ),
      child: ClipOval(
        child: SizedBox(
          width: 52,
          height: 52,
          child: d.imagenUrl != null && d.imagenUrl!.isNotEmpty
              ? Image.network(
                  d.imagenUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _inicialAvatar(d.iniciales),
                )
              : d.avatarUrl != null && d.avatarUrl!.isNotEmpty
              ? Image.network(
                  d.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _inicialAvatar(d.iniciales),
                )
              : _inicialAvatar(d.iniciales),
        ),
      ),
    );
  }

  Widget _inicialAvatar(String iniciales) => Container(
    color: AppTheme.primary.withOpacity(0.12),
    child: Center(
      child: Text(
        iniciales,
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ),
  );

  void _showDeactivateDialog(DocenteEntity d) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.person_off_outlined,
          color: Colors.red,
          size: 40,
        ),
        title: const Text('Desactivar docente'),
        content: Text(
          '¿Estás seguro de desactivar a ${d.nombre}?\n\n'
          'El perfil y su usuario quedarán inactivos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deactivate(d.id);
            },
            child: const Text(
              'Desactivar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivate(int id) async {
    try {
      await context.read<DocenteProvider>().deactivateDocente(id);
      if (!mounted) return;
      _applyFilters();
      CyberSnackbar.success(context, 'Docente desactivado exitosamente');
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocenteProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: const Text(
          'DOCENTES',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          PopupMenuButton<bool?>(
            icon: Icon(
              Icons.filter_list,
              color: _filtroEstado == null ? AppTheme.primary : AppTheme.accent,
            ),
            tooltip: 'Filtrar por estado',
            onSelected: (val) {
              setState(() => _filtroEstado = val);
              _applyFilters();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('Todos')),
              PopupMenuItem(value: true, child: Text('Activos')),
              PopupMenuItem(value: false, child: Text('Inactivos')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primary),
            onPressed: _applyFilters,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CyberSearchBar(
              controller: _searchCtrl,
              hint: 'Buscar por nombre, email o especialidad...',
              onSubmitted: (_) => _applyFilters(),
              onClear: () {
                _searchCtrl.clear();
                _applyFilters();
              },
            ),
          ),
          if (!provider.loading && provider.docentes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${provider.totalCount} docentes encontrados',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          if (provider.loading)
            const Expanded(
              child: CyberLoadingView(mensaje: 'Cargando docentes…'),
            )
          else if (provider.error != null && provider.docentes.isEmpty)
            Expanded(
              child: CyberErrorView(
                message: 'Error al cargar docentes',
                onRetry: _applyFilters,
              ),
            )
          else if (provider.docentes.isEmpty)
            Expanded(
              child: CyberEmptyView(
                icon: Icons.school_outlined,
                title: 'No hay docentes',
                subtitle: 'Prueba con otra búsqueda',
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: provider.docentes.length,
                itemBuilder: (_, i) {
                  final d = provider.docentes[i];
                  return _DocenteCard(
                    docente: d,
                    avatar: _buildAvatar(d),
                    onDetail: () => widget.onDetail(d.id),
                    onDeactivate: d.estado
                        ? () => _showDeactivateDialog(d)
                        : null,
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_docentes',
        onPressed: widget.onCreateTap,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        tooltip: 'Crear docente',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Tarjeta de docente ───────────────────────────────────────────────────────

class _DocenteCard extends StatelessWidget {
  final DocenteEntity docente;
  final Widget avatar;
  final VoidCallback onDetail;
  final VoidCallback? onDeactivate;

  const _DocenteCard({
    required this.docente,
    required this.avatar,
    required this.onDetail,
    this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final d = docente;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (d.estaSobrecargado == true) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message:
                              'Sobrecargado: '
                              '${d.horasAsignadasSemana?.toStringAsFixed(1)} h '
                              '/ ${d.horasMaxEfectivasLocal} h',
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    d.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _Badge(label: d.especialidad, color: AppTheme.accent),
                      _Badge(
                        label: d.estado ? 'Activo' : 'Inactivo',
                        color: d.estado ? AppTheme.primary : Colors.red,
                      ),
                      if (d.estaSobrecargado == true)
                        _Badge(
                          label:
                              '${d.horasAsignadasSemana?.toStringAsFixed(1)} h',
                          color: Colors.orange,
                          icon: Icons.warning_amber_outlined,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionBtn(
                  icon: Icons.visibility_outlined,
                  color: AppTheme.accent,
                  tooltip: 'Ver detalle',
                  onTap: onDetail,
                ),
                if (onDeactivate != null) ...[
                  const SizedBox(height: 6),
                  _ActionBtn(
                    icon: Icons.person_off_outlined,
                    color: Colors.red.shade400,
                    tooltip: 'Desactivar',
                    onTap: onDeactivate!,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _Badge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Formulario crear docente
// ─────────────────────────────────────────────────────────────────────────────

class DocenteCreateView extends StatefulWidget {
  final VoidCallback onCreated;
  const DocenteCreateView({super.key, required this.onCreated});

  @override
  State<DocenteCreateView> createState() => _DocenteCreateViewState();
}

class _DocenteCreateViewState extends State<DocenteCreateView> {
  final _especialidadCtrl = TextEditingController();
  final _horasCtrl = TextEditingController(text: '40');
  final _horasExtraCtrl = TextEditingController(text: '0');
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  bool _loading = false;
  bool _loadingUsuarios = false;
  int? _selectedUserId;
  List<Map<String, dynamic>> _usuariosDocentes = [];
  bool _permiteHorasExtra = false;
  XFile? _imagenXFile;
  Uint8List? _imagenBytes;

  @override
  void initState() {
    super.initState();
    _loadUsuariosDocentes();
  }

  @override
  void dispose() {
    _especialidadCtrl.dispose();
    _horasCtrl.dispose();
    _horasExtraCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsuariosDocentes() async {
    setState(() => _loadingUsuarios = true);
    try {
      final data = await UserService.getUsersDocentes();
      final results = data['results'] as List;
      setState(() {
        _usuariosDocentes = results
            .map(
              (e) => {
                'id': e['id'] as int,
                'nombre': '${e['nombre']} ${e['apellido']}',
                'email': e['email'] as String,
              },
            )
            .toList();
      });
    } catch (_) {
      setState(() => _usuariosDocentes = []);
    } finally {
      setState(() => _loadingUsuarios = false);
    }
  }

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

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<DocenteProvider>().createDocente(
        userId: _selectedUserId!,
        especialidad: _especialidadCtrl.text.trim(),
        horasMaxSemanales: int.parse(_horasCtrl.text.trim()),
        permiteHorasExtra: _permiteHorasExtra,
        horasExtraAutorizadas: _permiteHorasExtra
            ? int.parse(_horasExtraCtrl.text.trim())
            : 0,
        imagen: _imagenXFile,
      );
      if (!mounted) return;
      await context.read<DocenteProvider>().fetchDocentes();
      CyberSnackbar.success(context, 'Docente creado exitosamente');
      widget.onCreated();
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Docente'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                              Icons.school,
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
                        color: AppTheme.background,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _imagenBytes == null
                    ? 'Foto institucional (opcional)'
                    : 'Toca para cambiar',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _loadingUsuarios
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: _selectedUserId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Usuario docente',
                        prefixIcon: Icon(Icons.person_search_outlined),
                      ),
                      items: _usuariosDocentes.map((u) {
                        return DropdownMenuItem<int>(
                          value: u['id'] as int,
                          child: Text(
                            '${u['nombre']}  ·  ${u['email']}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedUserId = v),
                      validator: (_) => _selectedUserId == null
                          ? 'Selecciona un usuario'
                          : null,
                    ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _especialidadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Especialidad',
                  prefixIcon: Icon(Icons.psychology_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa la especialidad';
                  if (v.length < 3) return 'Mínimo 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horasCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Horas máx. semanales (máx. 40)',
                  prefixIcon: Icon(Icons.access_time_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Ingresa las horas máximas';
                  final n = int.tryParse(v);
                  if (n == null) return 'Debe ser un número';
                  if (n <= 0) return 'Debe ser mayor a 0';
                  if (n > 40) return 'No puede superar 40h regulares';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border.withOpacity(0.4)),
                ),
                child: SwitchListTile(
                  value: _permiteHorasExtra,
                  onChanged: (v) => setState(() {
                    _permiteHorasExtra = v;
                    if (!v) _horasExtraCtrl.text = '0';
                  }),
                  title: const Text(
                    'Permite horas extra',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: Text(
                    _permiteHorasExtra
                        ? 'El docente puede superar el máximo regular'
                        : 'Sin horas adicionales autorizadas',
                    style: TextStyle(
                      color: _permiteHorasExtra
                          ? AppTheme.accent
                          : AppTheme.textSecondary.withOpacity(0.6),
                    ),
                  ),
                  activeColor: AppTheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (_permiteHorasExtra) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _horasExtraCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Horas extra autorizadas',
                    prefixIcon: Icon(Icons.more_time_outlined),
                    helperText: 'Horas adicionales sobre el máximo regular.',
                  ),
                  validator: (v) {
                    if (!_permiteHorasExtra) return null;
                    if (v == null || v.isEmpty)
                      return 'Ingresa las horas extra';
                    final n = int.tryParse(v);
                    if (n == null) return 'Debe ser un número';
                    if (n <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              AppTheme.background,
                            ),
                          ),
                        )
                      : const Text(
                          'Crear Docente',
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

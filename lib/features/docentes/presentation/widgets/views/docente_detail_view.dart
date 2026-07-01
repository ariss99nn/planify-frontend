// lib/features/docentes/presentation/widgets/views/docente_detail_view.dart

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

// ─────────────────────────────────────────────────────────────────────────────
// Vista de detalle del docente
// ─────────────────────────────────────────────────────────────────────────────

class DocenteDetailView extends StatefulWidget {
  final int                   docenteId;
  final void Function(int id) onEditTap;
  final void Function(int id) onDisponibilidadTap;
  final void Function(int id) onHabilitacionesTap;

  const DocenteDetailView({
    super.key,
    required this.docenteId,
    required this.onEditTap,
    required this.onDisponibilidadTap,
    required this.onHabilitacionesTap,
  });

  @override
  State<DocenteDetailView> createState() => _DocenteDetailViewState();
}

class _DocenteDetailViewState extends State<DocenteDetailView> {
  DocenteEntity? _docente;
  bool           _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    final d = await context.read<DocenteProvider>().fetchDocente(widget.docenteId);
    if (!mounted) return;
    if (d == null) {
      CyberSnackbar.error(context, 'No se pudo cargar el docente');
      Navigator.pop(context);
      return;
    }
    setState(() { _docente = d; _loading = false; });
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.person_off_outlined, color: Colors.red, size: 40),
        title: const Text('Desactivar docente'),
        content: Text(
          '¿Estás seguro de desactivar a ${_docente!.nombre}?\n\n'
          'El perfil y su usuario quedarán inactivos.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _deactivate(); },
            child: const Text('Desactivar',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivate() async {
    try {
      await context.read<DocenteProvider>().deactivateDocente(widget.docenteId);
      if (!mounted) return;
      await context.read<DocenteProvider>().fetchDocentes();
      CyberSnackbar.success(context, 'Docente desactivado exitosamente');
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    }
  }

  Widget _buildAvatar() {
    final d   = _docente!;
    final img = d.imagenUrl ?? d.avatarUrl;
    return Container(
      decoration: BoxDecoration(
        shape:     BoxShape.circle,
        border:    Border.all(color: AppTheme.primary, width: 3),
        boxShadow: [BoxShadow(color: AppTheme.glow, blurRadius: 16)],
      ),
      child: ClipOval(
        child: SizedBox(
          width: 96, height: 96,
          child: img != null && img.isNotEmpty
              ? Image.network(img, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _inicialAvatar())
              : _inicialAvatar(),
        ),
      ),
    );
  }

  Widget _inicialAvatar() => Container(
    color: AppTheme.primary.withOpacity(0.12),
    child: Center(child: Text(_docente!.iniciales,
        style: const TextStyle(color: AppTheme.primary,
            fontWeight: FontWeight.bold, fontSize: 28))),
  );

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Text('$label: ',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Expanded(child: Text(value,
            style: TextStyle(color: valueColor ?? AppTheme.textPrimary,
                fontSize: 14, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _divider() => Divider(color: AppTheme.border.withOpacity(0.3));

  Widget _sectionCard({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color:        AppTheme.surface.withOpacity(0.4),
      borderRadius: BorderRadius.circular(16),
      border:       Border.all(color: AppTheme.border.withOpacity(0.4)),
    ),
    child: Column(children: children),
  );

  Widget _statusBadge({required String label, required Color color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
        Text(label, style: TextStyle(
            fontWeight: FontWeight.w600, color: color, fontSize: 13)),
      ]),
    );
  }

  Widget _buildCargaBar(DocenteEntity d) {
    final asignadas = d.horasAsignadasSemana ?? 0;
    final techo     = d.horasMaxEfectivasLocal.toDouble();
    final pct       = techo > 0 ? (asignadas / techo).clamp(0.0, 1.0) : 0.0;
    final color     = pct >= 1.0 ? Colors.red : pct >= 0.8 ? Colors.orange : AppTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Carga semanal',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withOpacity(0.7))),
          Text('${(pct * 100).toStringAsFixed(0)} %',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 8,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${asignadas.toStringAsFixed(1)} h de ${d.horasMaxEfectivasLocal} h disponibles',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _navButton({
    required String    label,
    required IconData  icon,
    required Color     color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon:  Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side:    BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _docente;

    return Scaffold(
      appBar: AppBar(
        title:           const Text('Detalle Docente'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        actions: [
          if (d != null) ...[
            IconButton(
              icon:     const Icon(Icons.edit_outlined, color: AppTheme.primary),
              tooltip:  'Editar',
              onPressed: () async {
                widget.onEditTap(widget.docenteId);
              },
            ),
            IconButton(
              icon:     const Icon(Icons.calendar_month_outlined, color: AppTheme.accent),
              tooltip:  'Disponibilidad',
              onPressed: () => widget.onDisponibilidadTap(widget.docenteId),
            ),
            if (d.estado)
              IconButton(
                icon:     const Icon(Icons.person_off_outlined, color: Colors.red),
                tooltip:  'Desactivar',
                onPressed: _showDeactivateDialog,
              ),
          ],
        ],
      ),
      body: _loading
          ? const CyberLoadingView(mensaje: 'Cargando docente…')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 16),
                  Text(d!.nombre,
                      style: const TextStyle(color: AppTheme.textPrimary,
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(d.email,
                      style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.7),
                          fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _statusBadge(
                      label: d.estado ? 'Activo' : 'Inactivo',
                      color: d.estado ? AppTheme.primary : Colors.red,
                    ),
                    if (d.estaSobrecargado == true) ...[
                      const SizedBox(width: 8),
                      _statusBadge(
                        label: 'Sobrecargado',
                        color: Colors.orange,
                        icon:  Icons.warning_amber_outlined,
                      ),
                    ],
                  ]),
                  const SizedBox(height: 28),
                  _sectionCard(children: [
                    _infoRow(Icons.psychology_outlined, 'Especialidad', d.especialidad),
                    _divider(),
                    _infoRow(Icons.access_time_outlined, 'Horas máx. regulares',
                        '${d.horasMaxSemanales} h'),
                    if (d.permiteHorasExtra) ...[
                      _divider(),
                      _infoRow(Icons.more_time_outlined, 'Horas extra autorizadas',
                          '+${d.horasExtraAutorizadas} h', valueColor: AppTheme.accent),
                      _divider(),
                      _infoRow(Icons.schedule_outlined, 'Techo efectivo',
                          '${d.horasMaxEfectivasLocal} h', valueColor: AppTheme.primary),
                    ],
                  ]),
                  if (d.horasAsignadasSemana != null) ...[
                    const SizedBox(height: 16),
                    _sectionCard(children: [
                      _infoRow(
                        Icons.bar_chart_outlined,
                        'Horas asignadas/semana',
                        '${d.horasAsignadasSemana} h',
                        valueColor: d.estaSobrecargado == true
                            ? Colors.orange : AppTheme.textPrimary,
                      ),
                      _divider(),
                      _buildCargaBar(d),
                    ]),
                  ],
                  const SizedBox(height: 20),
                  _navButton(
                    label:     'Ver disponibilidad',
                    icon:      Icons.calendar_month_outlined,
                    color:     AppTheme.accent,
                    onPressed: () => widget.onDisponibilidadTap(widget.docenteId),
                  ),
                  const SizedBox(height: 12),
                  _navButton(
                    label:     'Ver habilitaciones',
                    icon:      Icons.assignment_outlined,
                    color:     AppTheme.primary,
                    onPressed: () => widget.onHabilitacionesTap(widget.docenteId),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vista de edición del docente
// ─────────────────────────────────────────────────────────────────────────────

class DocenteEditView extends StatefulWidget {
  final int          docenteId;
  final VoidCallback onUpdated;

  const DocenteEditView({
    super.key,
    required this.docenteId,
    required this.onUpdated,
  });

  @override
  State<DocenteEditView> createState() => _DocenteEditViewState();
}

class _DocenteEditViewState extends State<DocenteEditView> {
  final _especialidadCtrl = TextEditingController();
  final _horasCtrl        = TextEditingController();
  final _horasExtraCtrl   = TextEditingController(text: '0');
  final _formKey          = GlobalKey<FormState>();
  final _picker           = ImagePicker();

  bool       _loading          = true;
  bool       _updating         = false;
  bool       _imagenEliminada  = false;
  bool       _estado           = true;
  bool       _permiteHorasExtra = false;
  String?    _imagenUrlActual;
  XFile?     _imagenXFile;
  Uint8List? _imagenBytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _especialidadCtrl.dispose();
    _horasCtrl.dispose();
    _horasExtraCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final d = await context.read<DocenteProvider>().fetchDocente(widget.docenteId);
      if (!mounted || d == null) return;
      setState(() {
        _especialidadCtrl.text = d.especialidad;
        _horasCtrl.text        = '${d.horasMaxSemanales}';
        _estado                = d.estado;
        _permiteHorasExtra     = d.permiteHorasExtra;
        _horasExtraCtrl.text   = '${d.horasExtraAutorizadas}';
        _imagenUrlActual       = d.imagenUrl;
        _loading               = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
      Navigator.pop(context);
    }
  }

  bool get _tieneImagen =>
      _imagenBytes != null ||
      (_imagenUrlActual != null && _imagenUrlActual!.isNotEmpty);

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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title:   const Text('Tomar foto'),
              onTap:   () async { Navigator.pop(context); await _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title:   const Text('Elegir de galería'),
              onTap:   () async { Navigator.pop(context); await _pickImage(ImageSource.gallery); },
            ),
            if (_tieneImagen)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:   const Text('Quitar foto', style: TextStyle(color: Colors.red)),
                onTap:   () {
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

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _updating = true);
    try {
      await context.read<DocenteProvider>().updateDocente(
        id: widget.docenteId,
        data: {
          'especialidad':            _especialidadCtrl.text.trim(),
          'horas_max_semanales':     int.parse(_horasCtrl.text.trim()),
          'estado':                  _estado,
          'permite_horas_extra':     _permiteHorasExtra,
          'horas_extra_autorizadas': _permiteHorasExtra
              ? int.parse(_horasExtraCtrl.text.trim())
              : 0,
        },
        imagen:        _imagenXFile,
        eliminarImagen: _imagenEliminada,
      );
      if (!mounted) return;
      await context.read<DocenteProvider>().fetchDocentes();
      CyberSnackbar.success(context, 'Docente actualizado exitosamente');
      widget.onUpdated();
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Widget _placeholder() => Container(
    color: AppTheme.primary.withOpacity(0.12),
    child: const Center(child: Icon(Icons.school, size: 52, color: AppTheme.primary)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:           const Text('Editar Docente'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
      ),
      body: _loading
          ? const CyberLoadingView(mensaje: 'Cargando datos…')
          : SingleChildScrollView(
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
                          ClipOval(
                            child: SizedBox(
                              width: 104, height: 104,
                              child: _imagenBytes != null
                                  ? Image.memory(_imagenBytes!, fit: BoxFit.cover)
                                  : (_imagenUrlActual != null && _imagenUrlActual!.isNotEmpty)
                                      ? Image.network(
                                          _imagenUrlActual!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _placeholder(),
                                        )
                                      : _placeholder(),
                            ),
                          ),
                          CircleAvatar(
                            radius:          16,
                            backgroundColor: AppTheme.primary,
                            child: const Icon(Icons.camera_alt, size: 16,
                                color: AppTheme.background),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _tieneImagen ? 'Toca para cambiar' : 'Agregar foto institucional',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _especialidadCtrl,
                      decoration: const InputDecoration(
                        labelText:  'Especialidad',
                        prefixIcon: Icon(Icons.psychology_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa la especialidad';
                        if (v.length < 3)           return 'Mínimo 3 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller:   _horasCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText:  'Horas máx. semanales (máx. 40)',
                        prefixIcon: Icon(Icons.access_time_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa las horas';
                        final n = int.tryParse(v);
                        if (n == null) return 'Debe ser un número';
                        if (n <= 0)    return 'Debe ser mayor a 0';
                        if (n > 40)    return 'No puede superar 40h regulares';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color:        AppTheme.surface.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border:       Border.all(color: AppTheme.border.withOpacity(0.4)),
                      ),
                      child: SwitchListTile(
                        value:     _permiteHorasExtra,
                        onChanged: (v) => setState(() {
                          _permiteHorasExtra = v;
                          if (!v) _horasExtraCtrl.text = '0';
                        }),
                        title: const Text('Permite horas extra',
                            style: TextStyle(color: AppTheme.textPrimary)),
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
                        activeColor:    AppTheme.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (_permiteHorasExtra) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller:   _horasExtraCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText:  'Horas extra autorizadas',
                          prefixIcon: Icon(Icons.more_time_outlined),
                          helperText: 'Horas adicionales sobre el máximo regular.',
                        ),
                        validator: (v) {
                          if (!_permiteHorasExtra) return null;
                          if (v == null || v.isEmpty) return 'Ingresa las horas extra';
                          final n = int.tryParse(v);
                          if (n == null) return 'Debe ser un número';
                          if (n <= 0)    return 'Debe ser mayor a 0';
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color:        AppTheme.surface.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border:       Border.all(color: AppTheme.border.withOpacity(0.4)),
                      ),
                      child: SwitchListTile(
                        value:     _estado,
                        onChanged: (v) => setState(() => _estado = v),
                        title: const Text('Estado activo',
                            style: TextStyle(color: AppTheme.textPrimary)),
                        subtitle: Text(
                          _estado ? 'Docente activo' : 'Docente inactivo',
                          style: TextStyle(
                            color: _estado ? AppTheme.primary : Colors.red.shade400,
                          ),
                        ),
                        activeColor:    AppTheme.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updating ? null : _update,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding:         const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _updating
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(AppTheme.background),
                                ),
                              )
                            : const Text('Actualizar Docente',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

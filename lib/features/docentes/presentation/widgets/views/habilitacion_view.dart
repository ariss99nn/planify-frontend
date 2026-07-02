// lib/features/docentes/presentation/widgets/views/habilitacion_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/api/api_service.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../providers/docente_provider.dart';
import '../../../domain/entities/habilitacion_entity.dart';

const _nivelesOpciones = [
  (value: 'MODULO', label: 'Módulo completo'),
  (value: 'ASIGNATURA', label: 'Asignatura específica'),
];

// ─────────────────────────────────────────────────────────────────────────────

class HabilitacionView extends StatefulWidget {
  final int? docenteId;
  final bool canManage;

  const HabilitacionView({super.key, this.docenteId, this.canManage = false});

  @override
  State<HabilitacionView> createState() => _HabilitacionViewState();
}

class _HabilitacionViewState extends State<HabilitacionView> {
  String? _filtroNivel;
  bool? _filtroActivo = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  void _load() {
    context.read<DocenteProvider>().fetchHabilitaciones(
      docenteId: widget.docenteId,
      nivel: _filtroNivel,
      activo: _filtroActivo,
    );
  }

  Widget _buildFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: _filtroActivo == null
                ? 'Todas'
                : (_filtroActivo! ? 'Activas' : 'Inactivas'),
            selected: true,
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => SimpleDialog(
                title: const Text('Estado'),
                children: [
                  _dialogOpt(ctx, 'Activas', () {
                    setState(() => _filtroActivo = true);
                    _load();
                  }),
                  _dialogOpt(ctx, 'Inactivas', () {
                    setState(() => _filtroActivo = false);
                    _load();
                  }),
                  _dialogOpt(ctx, 'Todas', () {
                    setState(() => _filtroActivo = null);
                    _load();
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: _filtroNivel == null
                ? 'Todos los niveles'
                : (_filtroNivel == 'MODULO' ? 'Módulos' : 'Asignaturas'),
            selected: _filtroNivel != null,
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => SimpleDialog(
                title: const Text('Nivel'),
                children: [
                  _dialogOpt(ctx, 'Todos', () {
                    setState(() => _filtroNivel = null);
                    _load();
                  }),
                  _dialogOpt(ctx, 'Módulos', () {
                    setState(() => _filtroNivel = 'MODULO');
                    _load();
                  }),
                  _dialogOpt(ctx, 'Asignaturas', () {
                    setState(() => _filtroNivel = 'ASIGNATURA');
                    _load();
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogOpt(BuildContext ctx, String label, VoidCallback onTap) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(ctx);
        onTap();
      },
      child: Text(label),
    );
  }

  void _showEditSheet(HabilitacionEntity hab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditHabilitacionSheet(habilitacion: hab, onSaved: _load),
    );
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _CreateHabilitacionSheet(docenteId: widget.docenteId, onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocenteProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habilitaciones'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primary),
            onPressed: _load,
            tooltip: 'Recargar',
          ),
        ],
      ),
      floatingActionButton: widget.canManage
          ? FloatingActionButton(
              heroTag: 'fab_habilitaciones',
              onPressed: _showCreateSheet,
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.background,
              tooltip: 'Agregar habilitación',
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          _buildFiltros(),
          if (!provider.loadingHabilitaciones &&
              provider.habilitaciones.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${provider.habilitacionesTotal} habilitaciones',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          if (provider.loadingHabilitaciones)
            const Expanded(
              child: CyberLoadingView(mensaje: 'Cargando habilitaciones…'),
            )
          else if (provider.errorHabilitaciones != null &&
              provider.habilitaciones.isEmpty)
            Expanded(
              child: CyberErrorView(
                message: 'Error al cargar habilitaciones',
                onRetry: _load,
              ),
            )
          else if (provider.habilitaciones.isEmpty)
            Expanded(
              child: CyberEmptyView(
                icon: Icons.assignment_outlined,
                title: 'Sin habilitaciones registradas',
                subtitle: widget.canManage ? 'Toca + para agregar' : null,
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: provider.habilitaciones.length,
                itemBuilder: (_, i) {
                  final h = provider.habilitaciones[i];
                  return _HabilitacionCard(
                    habilitacion: h,
                    canManage: widget.canManage,
                    onTap: widget.canManage ? () => _showEditSheet(h) : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Tarjeta ──────────────────────────────────────────────────────────────────

class _HabilitacionCard extends StatelessWidget {
  final HabilitacionEntity habilitacion;
  final bool canManage;
  final VoidCallback? onTap;

  const _HabilitacionCard({
    required this.habilitacion,
    required this.canManage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final h = habilitacion;
    final color = h.activo ? AppTheme.primary : AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(
            h.nivel == HabilitacionNivel.modulo
                ? Icons.library_books_outlined
                : Icons.menu_book_outlined,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          h.moduloNombre ?? h.asignaturaNombre ?? '',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              h.docenteNombre,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                _SmallBadge(label: h.nivelDisplay, color: AppTheme.accent),
                _SmallBadge(
                  label: h.activo ? 'Activa' : 'Inactiva',
                  color: h.activo ? AppTheme.primary : Colors.grey,
                ),
                if (h.fechaHasta != null)
                  _SmallBadge(
                    label:
                        'Hasta ${h.fechaHasta!.day}/${h.fechaHasta!.month}/${h.fechaHasta!.year}',
                    color: Colors.orange,
                    icon: Icons.event_outlined,
                  ),
              ],
            ),
          ],
        ),
        trailing: canManage
            ? Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppTheme.primary.withOpacity(0.6),
              )
            : null,
      ),
    );
  }
}

// ─── Sheet editar ─────────────────────────────────────────────────────────────

class _EditHabilitacionSheet extends StatefulWidget {
  final HabilitacionEntity habilitacion;
  final VoidCallback onSaved;

  const _EditHabilitacionSheet({
    required this.habilitacion,
    required this.onSaved,
  });

  @override
  State<_EditHabilitacionSheet> createState() => _EditHabilitacionSheetState();
}

class _EditHabilitacionSheetState extends State<_EditHabilitacionSheet> {
  final _observCtrl = TextEditingController();
  bool _activo = true;
  DateTime? _fechaHasta;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final h = widget.habilitacion;
    _activo = h.activo;
    _observCtrl.text = h.observaciones;
    _fechaHasta = h.fechaHasta;
  }

  @override
  void dispose() {
    _observCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaHasta ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _fechaHasta = picked);
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<DocenteProvider>().updateHabilitacion(
        habilitacionId: widget.habilitacion.id,
        activo: _activo,
        fechaHasta: _fechaHasta != null ? _dateStr(_fechaHasta!) : null,
        observaciones: _observCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.habilitacion;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.moduloNombre ?? h.asignaturaNombre ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      h.nivelDisplay,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: AppTheme.textSecondary,
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border.withOpacity(0.4)),
            ),
            child: SwitchListTile(
              value: _activo,
              onChanged: (v) => setState(() => _activo = v),
              title: Text(
                _activo ? 'Habilitación activa' : 'Habilitación inactiva',
                style: TextStyle(
                  color: _activo ? AppTheme.primary : Colors.red.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              activeColor: AppTheme.primary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickFecha,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_outlined,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha hasta (opcional)',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _fechaHasta != null
                              ? _dateStr(_fechaHasta!)
                              : 'Indefinida',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _fechaHasta != null
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_fechaHasta != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      color: Colors.red.shade300,
                      onPressed: () => setState(() => _fechaHasta = null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _observCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observaciones',
              prefixIcon: Icon(Icons.notes_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppTheme.background),
                      ),
                    )
                  : const Text(
                      'Guardar cambios',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet crear ──────────────────────────────────────────────────────────────

class _CreateHabilitacionSheet extends StatefulWidget {
  final int? docenteId;
  final VoidCallback onSaved;

  const _CreateHabilitacionSheet({this.docenteId, required this.onSaved});

  @override
  State<_CreateHabilitacionSheet> createState() =>
      _CreateHabilitacionSheetState();
}

class _CreateHabilitacionSheetState extends State<_CreateHabilitacionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _docenteCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _observCtrl = TextEditingController();

  String _nivel = 'MODULO';
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.docenteId != null) {
      _docenteCtrl.text = '${widget.docenteId}';
    }
  }

  @override
  void dispose() {
    _docenteCtrl.dispose();
    _targetCtrl.dispose();
    _observCtrl.dispose();
    super.dispose();
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isDesde) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isDesde
          ? (_fechaDesde ?? now)
          : (_fechaHasta ?? now.add(const Duration(days: 30))),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    setState(() => isDesde ? _fechaDesde = picked : _fechaHasta = picked);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaDesde == null) {
      _showSnack('Selecciona la fecha de inicio');
      return;
    }

    final docenteId = int.tryParse(_docenteCtrl.text.trim());
    final targetId = int.tryParse(_targetCtrl.text.trim());

    if (docenteId == null) {
      _showSnack('ID de docente inválido');
      return;
    }
    if (targetId == null) {
      _showSnack(
        'ID de ${_nivel == 'MODULO' ? 'módulo' : 'asignatura'} inválido',
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<DocenteProvider>().createHabilitacion(
        docenteId: docenteId,
        nivel: _nivel,
        moduloId: _nivel == 'MODULO' ? targetId : null,
        asignaturaId: _nivel == 'ASIGNATURA' ? targetId : null,
        fechaDesde: _dateStr(_fechaDesde!),
        fechaHasta: _fechaHasta != null ? _dateStr(_fechaHasta!) : null,
        observaciones: _observCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nueva habilitación',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppTheme.textSecondary,
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _docenteCtrl,
                readOnly: widget.docenteId != null,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ID Docente',
                  prefixIcon: const Icon(Icons.person_outlined),
                  filled: widget.docenteId != null,
                  fillColor: widget.docenteId != null
                      ? AppTheme.surface.withOpacity(0.3)
                      : null,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _nivel,
                decoration: const InputDecoration(
                  labelText: 'Nivel',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
                items: _nivelesOpciones
                    .map(
                      (n) => DropdownMenuItem(
                        value: n.value,
                        child: Text(n.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _nivel = v!;
                  _targetCtrl.clear();
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      'ID ${_nivel == 'MODULO' ? 'Módulo' : 'Asignatura'}',
                  prefixIcon: Icon(
                    _nivel == 'MODULO'
                        ? Icons.library_books_outlined
                        : Icons.menu_book_outlined,
                  ),
                  helperText:
                      'Ingresa el ID del '
                      '${_nivel == 'MODULO' ? 'módulo' : 'asignatura'} a habilitar.',
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      label: 'Fecha desde *',
                      date: _fechaDesde,
                      required: true,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateTile(
                      label: 'Fecha hasta',
                      date: _fechaHasta,
                      onTap: () => _pickDate(false),
                      onClear: _fechaHasta != null
                          ? () => setState(() => _fechaHasta = null)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
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
                          'Guardar habilitación',
                          style: TextStyle(
                            fontSize: 15,
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

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primary : AppTheme.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _SmallBadge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
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

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool required;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
    this.required = false,
    this.onClear,
  });

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final hasValue = date != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: required && !hasValue
                ? Colors.red.shade300
                : AppTheme.border.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: required && !hasValue
                          ? Colors.red.shade400
                          : AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? _fmt(date!) : 'Seleccionar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasValue
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.clear, size: 16, color: Colors.red.shade300),
              ),
          ],
        ),
      ),
    );
  }
}

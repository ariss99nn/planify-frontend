// lib/features/docentes/presentation/widgets/views/disponibilidad_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/api/api_service.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../providers/docente_provider.dart';
import '../../../domain/entities/disponibilidad_entity.dart';

const _diasSemana = [
  ('LUNES', 'Lunes'),
  ('MARTES', 'Martes'),
  ('MIERCOLES', 'Miércoles'),
  ('JUEVES', 'Jueves'),
  ('VIERNES', 'Viernes'),
  ('SABADO', 'Sábado'),
];

const _tiposRestriccion = [
  ('PERMANENTE', 'Permanente'),
  ('TEMPORAL', 'Temporal'),
];

String _timeToStr(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

String _dateToStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ─────────────────────────────────────────────────────────────────────────────

class DisponibilidadView extends StatefulWidget {
  final int docenteId;
  const DisponibilidadView({super.key, required this.docenteId});

  @override
  State<DisponibilidadView> createState() => _DisponibilidadViewState();
}

class _DisponibilidadViewState extends State<DisponibilidadView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          context.read<DocenteProvider>().fetchDisponibilidad(widget.docenteId),
    );
  }

  void _refresh() =>
      context.read<DocenteProvider>().fetchDisponibilidad(widget.docenteId);

  void _showEditDialog(DisponibilidadEntity disp) {
    bool disponible = disp.disponible;
    final motivoCtrl = TextEditingController(text: disp.motivo);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(
            disp.bloqueDetalle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  value: disponible,
                  onChanged: (v) => setD(() => disponible = v),
                  title: Text(
                    disponible ? 'Disponible' : 'No disponible',
                    style: TextStyle(
                      color: disponible
                          ? AppTheme.primary
                          : Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  activeColor: AppTheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!disponible) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: motivoCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Motivo (obligatorio)',
                      prefixIcon: Icon(Icons.comment_outlined),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa el motivo'
                        : null,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                await _saveEdit(
                  dispId: disp.id,
                  disponible: disponible,
                  motivo: motivoCtrl.text.trim(),
                );
              },
              child: const Text(
                'Guardar',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEdit({
    required int dispId,
    required bool disponible,
    required String motivo,
  }) async {
    try {
      await context.read<DocenteProvider>().updateDisponibilidad(
        docenteId: widget.docenteId,
        disponibilidadId: dispId,
        disponible: disponible,
        motivo: motivo,
      );
      if (!mounted) return;
      _refresh();
      CyberSnackbar.success(context, 'Disponibilidad actualizada');
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    }
  }

  void _confirmDelete(DisponibilidadEntity disp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 36),
        title: const Text('Eliminar disponibilidad'),
        content: Text('¿Eliminar el slot "${disp.bloqueDetalle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _delete(disp.id);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(int dispId) async {
    try {
      await context.read<DocenteProvider>().deleteDisponibilidad(
        docenteId: widget.docenteId,
        disponibilidadId: dispId,
      );
      if (!mounted) return;
      _refresh();
      CyberSnackbar.success(context, 'Disponibilidad eliminada');
    } on ApiException catch (e) {
      if (!mounted) return;
      CyberSnackbar.error(context, e.message);
    }
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CreateDisponibilidadSheet(
        docenteId: widget.docenteId,
        onSaved: _refresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocenteProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disponibilidad'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primary),
            onPressed: _refresh,
            tooltip: 'Recargar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_disponibilidad',
        onPressed: _showCreateSheet,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        tooltip: 'Agregar disponibilidad',
        child: const Icon(Icons.add),
      ),
      body: provider.loadingDisponibilidad
          ? const CyberLoadingView(mensaje: 'Cargando disponibilidad…')
          : provider.errorDisponibilidad != null &&
                provider.disponibilidades.isEmpty
          ? CyberErrorView(message: 'Error al cargar', onRetry: _refresh)
          : provider.disponibilidades.isEmpty
          ? CyberEmptyView(
              icon: Icons.calendar_today_outlined,
              title: 'Sin disponibilidades registradas',
              subtitle: 'Toca + para agregar',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: provider.disponibilidades.length,
              itemBuilder: (_, i) {
                final d = provider.disponibilidades[i];
                final color = d.disponible
                    ? AppTheme.primary
                    : Colors.red.shade400;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Icon(
                        d.disponible
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        color: color,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      d.bloqueDetalle,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (d.esTemporal) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Temporal: ${d.fechaInicioRestriccion ?? ''} → '
                            '${d.fechaFinRestriccion ?? ''}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.accent.withOpacity(0.8),
                            ),
                          ),
                        ],
                        if (d.motivo.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            d.motivo,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            d.disponible ? 'Disponible' : 'No disp.',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: Colors.red.shade300,
                          tooltip: 'Eliminar',
                          onPressed: () => _confirmDelete(d),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    onTap: () => _showEditDialog(d),
                  ),
                );
              },
            ),
    );
  }
}

// ─── Sheet crear disponibilidad ───────────────────────────────────────────────

class _CreateDisponibilidadSheet extends StatefulWidget {
  final int docenteId;
  final VoidCallback onSaved;

  const _CreateDisponibilidadSheet({
    required this.docenteId,
    required this.onSaved,
  });

  @override
  State<_CreateDisponibilidadSheet> createState() =>
      _CreateDisponibilidadSheetState();
}

class _CreateDisponibilidadSheetState
    extends State<_CreateDisponibilidadSheet> {
  final _formKey = GlobalKey<FormState>();
  final _motivoCtrl = TextEditingController();

  String _diaSemana = 'LUNES';
  TimeOfDay _horaInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _horaFin = const TimeOfDay(hour: 10, minute: 0);
  bool _disponible = true;
  String _tipoRestriccion = 'PERMANENTE';
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _saving = false;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isInicio ? _horaInicio : _horaFin,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => isInicio ? _horaInicio = picked : _horaFin = picked);
  }

  Future<void> _pickDate(bool isInicio) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isInicio
          ? (_fechaInicio ?? now)
          : (_fechaFin ?? now.add(const Duration(days: 1))),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() => isInicio ? _fechaInicio = picked : _fechaFin = picked);
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
    if (_horaFin.hour < _horaInicio.hour ||
        (_horaFin.hour == _horaInicio.hour &&
            _horaFin.minute <= _horaInicio.minute)) {
      _showSnack('La hora de fin debe ser posterior a la de inicio');
      return;
    }
    if (_tipoRestriccion == 'TEMPORAL' &&
        (_fechaInicio == null || _fechaFin == null)) {
      _showSnack('Selecciona las fechas de la restricción temporal');
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<DocenteProvider>().createDisponibilidad(
        docenteId: widget.docenteId,
        diaSemana: _diaSemana,
        horaInicio: _timeToStr(_horaInicio),
        horaFin: _timeToStr(_horaFin),
        disponible: _disponible,
        motivo: _motivoCtrl.text.trim(),
        tipoRestriccion: _tipoRestriccion,
        fechaInicioRestriccion: _fechaInicio != null
            ? _dateToStr(_fechaInicio!)
            : null,
        fechaFinRestriccion: _fechaFin != null ? _dateToStr(_fechaFin!) : null,
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

  Widget _timeButton(String label, TimeOfDay t, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
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
                      'Nueva disponibilidad',
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
              DropdownButtonFormField<String>(
                value: _diaSemana,
                decoration: const InputDecoration(
                  labelText: 'Día de la semana',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                items: _diasSemana
                    .map(
                      (d) => DropdownMenuItem(value: d.$1, child: Text(d.$2)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _diaSemana = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _timeButton(
                      'Hora inicio',
                      _horaInicio,
                      () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timeButton(
                      'Hora fin',
                      _horaFin,
                      () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border.withOpacity(0.4)),
                ),
                child: SwitchListTile(
                  value: _disponible,
                  onChanged: (v) => setState(() => _disponible = v),
                  title: Text(
                    _disponible ? 'Disponible' : 'No disponible',
                    style: TextStyle(
                      color: _disponible
                          ? AppTheme.primary
                          : Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  activeColor: AppTheme.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              if (!_disponible) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _motivoCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Motivo (obligatorio)',
                    prefixIcon: Icon(Icons.comment_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa el motivo'
                      : null,
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoRestriccion,
                decoration: const InputDecoration(
                  labelText: 'Tipo de restricción',
                  prefixIcon: Icon(Icons.rule_outlined),
                ),
                items: _tiposRestriccion
                    .map(
                      (t) => DropdownMenuItem(value: t.$1, child: Text(t.$2)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _tipoRestriccion = v!),
              ),
              if (_tipoRestriccion == 'TEMPORAL') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        label: 'Fecha inicio',
                        date: _fechaInicio,
                        onTap: () => _pickDate(true),
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateButton(
                        label: 'Fecha fin',
                        date: _fechaFin,
                        onTap: () => _pickDate(false),
                        required: true,
                      ),
                    ),
                  ],
                ),
              ],
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
                          'Guardar disponibilidad',
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

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool required;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
    this.required = false,
  });

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: required && !hasValue
                    ? Colors.red.shade400
                    : AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasValue
                  ? '${date!.day}/${date!.month}/${date!.year}'
                  : 'Seleccionar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hasValue ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

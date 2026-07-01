// lib/features/ficha/presentation/widgets/views/ficha_edit_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/cyber_loading_view.dart';
import '../../providers/ficha_provider.dart';
import '../../../data/models/ficha_request_model.dart';
import '../ficha_form_fields.dart';

class FichaEditView extends StatefulWidget {
  final int fichaId;
  const FichaEditView({super.key, required this.fichaId});

  @override
  State<FichaEditView> createState() => _FichaEditViewState();
}

class _FichaEditViewState extends State<FichaEditView> {
  final _formKey         = GlobalKey<FormState>();
  final _estudiantesCtrl = TextEditingController();
  final _horasCtrl       = TextEditingController();
  final _trimestreCtrl   = TextEditingController();
  final _jefeGrupoIdCtrl = TextEditingController();

  String?   _jornada;
  String?   _estado;
  bool?     _cadenaFormacion;
  DateTime? _fechaInicio;
  DateTime? _fechaFinalizacion;
  bool      _clearJefeGrupo = false;
  bool      _cargado        = false;

  static const _jornadas = {
    'MANANA': 'Mañana', 'TARDE': 'Tarde', 'NOCHE': 'Noche', 'MIXTA': 'Mixta',
  };
  static const _estados = {
    'ACTIVA': 'Activa', 'INACTIVA': 'Inactiva', 'CERRADA': 'Cerrada',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cargado) {
      _cargado = true;
      final ficha = context.read<FichaProvider>().fichaDetalle;
      if (ficha != null && ficha.id == widget.fichaId) {
        _estudiantesCtrl.text = ficha.numeroEstudiantesEstimado.toString();
        _horasCtrl.text       = ficha.horasSemanalesObjetivo.toString();
        _trimestreCtrl.text   = ficha.trimestre.toString();
        _jefeGrupoIdCtrl.text = ficha.jefeGrupo?.toString() ?? '';
        _jornada              = ficha.jornada;
        _estado               = ficha.estado;
        _cadenaFormacion      = ficha.cadenaFormacion;
        _fechaInicio          = ficha.fechaInicio;
        _fechaFinalizacion    = ficha.fechaFinalizacion;
      }
    }
  }

  @override
  void dispose() {
    _estudiantesCtrl.dispose();
    _horasCtrl.dispose();
    _trimestreCtrl.dispose();
    _jefeGrupoIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha({required bool esInicio}) async {
    final initial = esInicio
        ? (_fechaInicio ?? DateTime.now())
        : (_fechaFinalizacion ?? (_fechaInicio ?? DateTime.now()));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2015),
      lastDate:  DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (esInicio) {
        _fechaInicio = picked;
      } else {
        _fechaFinalizacion = picked;
      }
    });
  }

  String _fmtFecha(DateTime? d) {
    if (d == null) return 'Sin fecha';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaFinalizacion != null &&
        _fechaInicio != null &&
        _fechaFinalizacion!.isBefore(_fechaInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La fecha de finalización no puede ser anterior al inicio.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    int? jefeId;
    if (!_clearJefeGrupo && _jefeGrupoIdCtrl.text.trim().isNotEmpty) {
      jefeId = int.tryParse(_jefeGrupoIdCtrl.text.trim());
    }

    final request = FichaUpdateRequest(
      jornada:                   _jornada,
      numeroEstudiantesEstimado: int.tryParse(_estudiantesCtrl.text.trim()),
      horasSemanalesObjetivo:    int.tryParse(_horasCtrl.text.trim()),
      trimestre:                 int.tryParse(_trimestreCtrl.text.trim()),
      estado:                    _estado,
      cadenaFormacion:           _cadenaFormacion,
      jefeGrupoId:               jefeId,
      clearJefeGrupo:            _clearJefeGrupo,
      fechaInicio:               _fechaInicio,
      fechaFinalizacion:         _fechaFinalizacion,
    );

    final provider = context.read<FichaProvider>();
    final ficha    = await provider.updateFicha(widget.fichaId, request);

    if (!mounted) return;

    if (ficha != null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            provider.mutationError ?? 'No se pudo actualizar la ficha.'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primary) : null,
        labelStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8)),
      );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FichaProvider>();

    if (provider.loadingDetalle) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: CyberLoadingView(mensaje: 'Cargando ficha…'),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: const Text('EDITAR FICHA',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 2)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const FichaSeccionLabel('Configuración'),
            if (_jornada != null)
              FichaDropdownField(
                label:     'Jornada',
                value:     _jornada!,
                opciones:  _jornadas,
                onChanged: (v) => setState(() => _jornada = v),
              )
            else
              FichaDropdownField(
                label:     'Jornada',
                value:     'MANANA',
                opciones:  _jornadas,
                onChanged: (v) => setState(() => _jornada = v),
              ),
            const SizedBox(height: 14),
            if (_estado != null)
              FichaDropdownField(
                label:     'Estado',
                value:     _estado!,
                opciones:  _estados,
                onChanged: (v) => setState(() => _estado = v),
              )
            else
              FichaDropdownField(
                label:     'Estado',
                value:     'ACTIVA',
                opciones:  _estados,
                onChanged: (v) => setState(() => _estado = v),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _estudiantesCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration:
                        _dec('Cupo estimado', icon: Icons.people_outline),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (int.tryParse(v.trim()) == null) return 'Numérico';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _horasCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _dec('Horas/semana', icon: Icons.schedule),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (int.tryParse(v.trim()) == null) return 'Numérico';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _trimestreCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration:
                  _dec('Trimestre', icon: Icons.calendar_view_month),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = int.tryParse(v.trim());
                if (n == null || n < 1) return '≥ 1';
                return null;
              },
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.accent,
                title: const Text('Cadena de formación',
                    style: TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14)),
                value:     _cadenaFormacion ?? false,
                onChanged: (v) => setState(() => _cadenaFormacion = v),
              ),
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Jefe de grupo'),
            TextFormField(
              controller: _jefeGrupoIdCtrl,
              keyboardType: TextInputType.number,
              enabled: !_clearJefeGrupo,
              style: TextStyle(
                  color: _clearJefeGrupo
                      ? AppTheme.textSecondary.withOpacity(0.4)
                      : AppTheme.textPrimary),
              decoration: _dec('ID del docente', icon: Icons.person_outline),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (int.tryParse(v.trim()) == null) return 'Numérico';
                return null;
              },
            ),
            const SizedBox(height: 6),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.red.shade400,
              title: const Text('Quitar jefe de grupo actual',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              value:     _clearJefeGrupo,
              onChanged: (v) => setState(() => _clearJefeGrupo = v ?? false),
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Fechas'),
            Row(
              children: [
                Expanded(
                  child: FichaFechaTile(
                    label: 'Inicio',
                    value: _fmtFecha(_fechaInicio),
                    onTap: () => _pickFecha(esInicio: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FichaFechaTile(
                    label: 'Fin estimado',
                    value: _fmtFecha(_fechaFinalizacion),
                    onTap: () => _pickFecha(esInicio: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: provider.loadingMutation ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: provider.loadingMutation
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar cambios',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

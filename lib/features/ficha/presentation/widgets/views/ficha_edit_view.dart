// lib/features/ficha/presentation/widgets/views/ficha_edit_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/cyber_loading_view.dart';
import '../../providers/ficha_provider.dart';
import '../../../data/models/ficha_request_model.dart';
import '../../../../docentes/domain/entities/docente_entity.dart';
import '../ficha_form_fields.dart';
import '../ficha_pickers.dart';

class FichaEditView extends StatefulWidget {
  final int fichaId;
  const FichaEditView({super.key, required this.fichaId});

  @override
  State<FichaEditView> createState() => _FichaEditViewState();
}

class _FichaEditViewState extends State<FichaEditView> {
  final _formKey         = GlobalKey<FormState>();
  final _estudiantesCtrl = TextEditingController();

  String?   _jornada;
  String?   _estado;
  DateTime? _fechaInicio;
  DateTime? _fechaFinalizacion;
  int?      _horasSemanales;
  int?      _trimestre;

  DocenteEntity? _jefeGrupo;
  String?        _jefeGrupoNombreActual;
  bool           _clearJefeGrupo = false;
  bool           _cargado        = false;

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
        _estudiantesCtrl.text  = ficha.numeroEstudiantesEstimado.toString();
        _jornada                = ficha.jornada;
        _estado                 = ficha.estado;
        _fechaInicio             = ficha.fechaInicio;
        _fechaFinalizacion       = ficha.fechaFinalizacion;
        _horasSemanales          = ficha.horasSemanalesObjetivo;
        _trimestre               = ficha.trimestre;
        _jefeGrupoNombreActual   = ficha.jefeGrupoNombre;
      }
    }
  }

  @override
  void dispose() {
    _estudiantesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate:  DateTime(2035),
    );
    if (picked == null) return;
    setState(() => _fechaInicio = picked);
  }

  Future<void> _pickJefeGrupo() async {
    final picked = await pickDocente(context);
    if (picked == null) return;
    setState(() {
      _jefeGrupo = picked;
      _clearJefeGrupo = false;
    });
  }

  String _fmtFecha(DateTime? d) {
    if (d == null) return 'Sin fecha';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = FichaUpdateRequest(
      jornada:                   _jornada,
      numeroEstudiantesEstimado: int.tryParse(_estudiantesCtrl.text.trim()),
      estado:                    _estado,
      jefeGrupoId:               _jefeGrupo?.id,
      clearJefeGrupo:            _clearJefeGrupo,
      fechaInicio:               _fechaInicio,
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

    final jefeGrupoLabel = _clearJefeGrupo
        ? 'Sin jefe de grupo'
        : (_jefeGrupo?.nombre ?? _jefeGrupoNombreActual ?? 'Seleccionar docente');

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
            TextFormField(
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
            const SizedBox(height: 14),
            // Horas/semana y trimestre son calculados/gestionados por el
            // sistema; se muestran solo como referencia, sin poder editarse.
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: _dec('Horas/semana (auto)', icon: Icons.schedule),
                    child: Text('${_horasSemanales ?? '—'}',
                        style: const TextStyle(color: AppTheme.textPrimary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputDecorator(
                    decoration: _dec('Trimestre',
                        icon: Icons.calendar_view_month),
                    child: Text('${_trimestre ?? '—'}',
                        style: const TextStyle(color: AppTheme.textPrimary)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Jefe de grupo'),
            FichaPickerTile(
              label: jefeGrupoLabel,
              icon: Icons.person_outline,
              tieneValor: !_clearJefeGrupo &&
                  (_jefeGrupo != null || _jefeGrupoNombreActual != null),
              enabled: !_clearJefeGrupo,
              onTap: _pickJefeGrupo,
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
                    onTap: _pickFechaInicio,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputDecorator(
                    decoration: _dec('Fin estimado (auto)',
                        icon: Icons.calendar_today),
                    child: Text(_fmtFecha(_fechaFinalizacion),
                        style: const TextStyle(color: AppTheme.textPrimary)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'La fecha fin estimada se recalcula automáticamente si cambia '
              'la fecha de inicio, según el nivel del programa.',
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 11),
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

// lib/features/ficha/presentation/widgets/views/ficha_edit_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/cyber_loading_view.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/friendly_feedback.dart';
import '../../providers/ficha_provider.dart';
import '../../../data/models/ficha_request_model.dart';
import '../../../../docentes/domain/entities/docente_entity.dart';
import '../ficha_form_fields.dart';
import '../ficha_pickers.dart';

const _mesesInicioPermitidos = {1: 'Enero', 3: 'Marzo', 7: 'Julio', 10: 'Octubre'};

class FichaEditView extends StatefulWidget {
  final int fichaId;
  const FichaEditView({super.key, required this.fichaId});

  @override
  State<FichaEditView> createState() => _FichaEditViewState();
}

class _FichaEditViewState extends State<FichaEditView> {
  final _formKey = GlobalKey<FormState>();

  String?   _jornada;
  String?   _estado;
  DateTime? _fechaInicio;
  DateTime? _fechaFinalizacion;
  int?      _horasSemanales;
  int?      _trimestre;
  int?      _cupoEstimado;
  int?      _cupoReal;

  DocenteEntity? _jefeGrupo;
  int?           _jefeGrupoIdActual;
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
        _jornada               = ficha.jornada;
        _estado                = ficha.estado;
        _fechaInicio            = ficha.fechaInicio;
        _fechaFinalizacion      = ficha.fechaFinalizacion;
        _horasSemanales         = ficha.horasSemanalesObjetivo;
        _trimestre              = ficha.trimestre;
        _cupoEstimado           = ficha.numeroEstudiantesEstimado;
        _cupoReal               = ficha.numeroEstudiantesReal;
        // FIX: 'jefe_grupo_nombre' venía null en el backend por un
        // source mal apuntado (Docente no tiene campo 'nombre', solo
        // 'nombre_completo'), así que este selector nunca mostraba al
        // docente ya asignado. Con el serializer corregido, esto ahora
        // se precarga correctamente.
        _jefeGrupoIdActual      = ficha.jefeGrupo;
        _jefeGrupoNombreActual  = ficha.jefeGrupoNombre;
      }
    }
  }

  /// Restringido a los mismos cortes de matrícula que la creación.
  Future<void> _pickFechaInicio() async {
    final hoy = DateTime.now();
    final opciones = <DateTime>[];
    for (var year = hoy.year - 1; opciones.length < 8; year++) {
      for (final mes in _mesesInicioPermitidos.keys) {
        opciones.add(DateTime(year, mes, 1));
      }
    }
    opciones.sort();
    final elegido = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in opciones.take(8))
              ListTile(
                leading: const Icon(Icons.event_available, color: AppTheme.primary),
                title: Text('${_mesesInicioPermitidos[f.month]} ${f.year}',
                    style: const TextStyle(color: AppTheme.textPrimary)),
                onTap: () => Navigator.pop(context, f),
              ),
          ],
        ),
      ),
    );
    if (elegido == null) return;
    setState(() => _fechaInicio = elegido);
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

    // FIX: reemplazar un jefe de grupo ya asignado por otro distinto es
    // una acción sensible — antes se guardaba sin más aviso. Ahora se
    // pide confirmación explícita antes de enviar, y el backend además
    // la exige en 'confirmar_cambio_docente'.
    final reemplazaDocente = _jefeGrupo != null &&
        _jefeGrupoIdActual != null &&
        _jefeGrupo!.id != _jefeGrupoIdActual;
    var confirmarCambioDocente = false;
    if (reemplazaDocente) {
      confirmarCambioDocente = await showConfirmDialog(
        context,
        titulo: 'Cambiar jefe de grupo',
        mensaje:
            'Esta ficha ya tiene a $_jefeGrupoNombreActual como jefe de '
            'grupo. ¿Confirmas reemplazarlo por ${_jefeGrupo!.nombre}?',
        textoConfirmar: 'Reemplazar',
      );
      if (!confirmarCambioDocente) return;
    }

    final request = FichaUpdateRequest(
      jornada:                 _jornada,
      estado:                  _estado,
      jefeGrupoId:             _jefeGrupo?.id,
      clearJefeGrupo:          _clearJefeGrupo,
      confirmarCambioDocente:  confirmarCambioDocente,
      fechaInicio:             _fechaInicio,
    );

    final provider = context.read<FichaProvider>();
    final ficha    = await provider.updateFicha(widget.fichaId, request);

    if (!mounted) return;

    if (ficha != null) {
      Navigator.pop(context, true);
    } else {
      showFriendlyApiError(
        context,
        provider.mutationError,
        fallback: 'No se pudo actualizar la ficha.',
      );
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
            FichaDropdownField(
              label:     'Jornada',
              value:     _jornada ?? 'MANANA',
              opciones:  _jornadas,
              onChanged: (v) => setState(() => _jornada = v),
            ),
            const SizedBox(height: 14),
            FichaDropdownField(
              label:     'Estado',
              value:     _estado ?? 'ACTIVA',
              opciones:  _estados,
              onChanged: (v) => setState(() => _estado = v),
            ),
            const SizedBox(height: 14),
            // FIX: el cupo estimado ya no es editable — queda fijo desde
            // la creación de la ficha. Se muestra junto al número real de
            // estudiantes activos para que quede claro que son dos cosas
            // distintas (algunos desertan o son bloqueados).
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: _dec('Cupo estimado (fijo)', icon: Icons.people_outline),
                    child: Text('${_cupoEstimado ?? '—'}',
                        style: const TextStyle(color: AppTheme.textPrimary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputDecorator(
                    decoration: _dec('Estudiantes reales', icon: Icons.groups_2_outlined),
                    child: Text('${_cupoReal ?? '—'}',
                        style: const TextStyle(color: AppTheme.textPrimary)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
            const SizedBox(height: 4),
            Text(
              'No toda ficha necesita tener docente asignado. Reemplazar '
              'uno ya asignado pide confirmación antes de guardar.',
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.55), fontSize: 11),
            ),
            const SizedBox(height: 6),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.amber.shade400,
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
                    label: 'Inicio (corte de matrícula)',
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

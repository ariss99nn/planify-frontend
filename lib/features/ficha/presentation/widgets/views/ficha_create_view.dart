// lib/features/ficha/presentation/widgets/views/ficha_create_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/friendly_feedback.dart';
import '../../providers/ficha_provider.dart';
import '../../../data/models/ficha_request_model.dart';
import '../../../../programa/domain/entities/programa_entity.dart';
import '../../../../programa/domain/entities/version_programa_entity.dart';
import '../../../../docentes/domain/entities/docente_entity.dart';
import '../ficha_form_fields.dart';
import '../ficha_pickers.dart';

/// Meses en los que el SENA abre matrícula. Debe reflejar
/// ficha.services.ficha_calculo_service.MESES_INICIO_PERMITIDOS en el
/// backend — una ficha solo puede iniciar en uno de estos cortes.
const _mesesInicioPermitidos = {1: 'Enero', 3: 'Marzo', 7: 'Julio', 10: 'Octubre'};

class FichaCreateView extends StatefulWidget {
  const FichaCreateView({super.key});

  @override
  State<FichaCreateView> createState() => _FichaCreateViewState();
}

class _FichaCreateViewState extends State<FichaCreateView> {
  final _formKey         = GlobalKey<FormState>();
  final _codigoCtrl      = TextEditingController();
  final _estudiantesCtrl = TextEditingController();

  String    _jornada         = 'MANANA';
  String    _etapa           = 'LECTIVA';
  String    _estado          = 'ACTIVA';
  bool      _cadenaFormacion = false;
  DateTime? _fechaInicio;

  ProgramaNivel          _nivel     = ProgramaNivel.tecnico;
  ProgramaResumenEntity? _programa;
  VersionResumenEntity?  _version;
  DocenteEntity?         _jefeGrupo;

  static const _jornadas = {
    'MANANA': 'Mañana', 'TARDE': 'Tarde', 'NOCHE': 'Noche', 'MIXTA': 'Mixta',
  };
  static const _etapas  = {'LECTIVA': 'Lectiva', 'PRODUCTIVA': 'Productiva'};
  static const _estados = {
    'ACTIVA': 'Activa', 'INACTIVA': 'Inactiva', 'CERRADA': 'Cerrada',
  };

  /// La cadena de formación solo aplica a programas de Tecnología
  /// configurados explícitamente como cadena de formación — igual que
  /// valida el backend (puede_usar_cadena_formacion). Mostrar esto antes
  /// de que el usuario intente guardar evita el 400 sorpresivo.
  bool get _programaPermiteCadena =>
      _programa != null &&
      _programa!.nivel == ProgramaNivel.tecnologia &&
      _programa!.tipoFormacion == ProgramaTipoFormacion.cadenaFormacion;

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _estudiantesCtrl.dispose();
    super.dispose();
  }

  /// FIX: antes se abría un calendario libre (cualquier día), pero el
  /// backend solo acepta fichas que inicien en los cortes de matrícula
  /// del SENA (enero/marzo/julio/octubre) y rechazaba cualquier otra
  /// fecha con un 400. Ahora se ofrece directamente el próximo corte
  /// disponible de cada mes habilitado, sin dar pie al error.
  Future<void> _pickFechaInicio() async {
    final hoy = DateTime.now();
    final opciones = <DateTime>[];
    for (var year = hoy.year; opciones.length < 6; year++) {
      for (final mes in _mesesInicioPermitidos.keys) {
        final fecha = DateTime(year, mes, 1);
        if (fecha.isAfter(hoy) || _esMismoMes(fecha, hoy)) {
          opciones.add(fecha);
        }
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Cortes de matrícula disponibles',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700)),
            ),
            for (final f in opciones.take(6))
              ListTile(
                leading: const Icon(Icons.event_available, color: AppTheme.primary),
                title: Text('${_mesesInicioPermitidos[f.month]} ${f.year}',
                    style: const TextStyle(color: AppTheme.textPrimary)),
                onTap: () => Navigator.pop(context, f),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (elegido == null) return;
    setState(() => _fechaInicio = elegido);
  }

  bool _esMismoMes(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  String _fmtFecha(DateTime? d) {
    if (d == null) return 'Selecciona un corte de matrícula';
    return '${_mesesInicioPermitidos[d.month]} ${d.year}';
  }

  Future<void> _pickPrograma() async {
    final picked = await pickPrograma(context, nivel: _nivel);
    if (picked == null) return;
    setState(() {
      _programa = picked;
      _version  = null; // cambiar de programa obliga a re-elegir versión
      if (!_programaPermiteCadena) _cadenaFormacion = false;
    });
  }

  Future<void> _pickVersion() async {
    if (_programa == null) {
      showFriendlySnack(context, 'Primero selecciona el programa.',
          tono: FeedbackTono.advertencia);
      return;
    }
    final picked = await pickVersionPrograma(context, programaId: _programa!.id);
    if (picked == null) return;
    setState(() => _version = picked);
  }

  Future<void> _pickJefeGrupo() async {
    final picked = await pickDocente(context);
    if (picked == null) return;
    setState(() => _jefeGrupo = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_version == null) {
      showFriendlySnack(context, 'Selecciona el programa (versión) de la ficha.',
          tono: FeedbackTono.advertencia);
      return;
    }
    if (_fechaInicio == null) {
      showFriendlySnack(context, 'Selecciona la fecha de inicio (corte de matrícula).',
          tono: FeedbackTono.advertencia);
      return;
    }

    final request = FichaCreateRequest(
      codigoFicha:               _codigoCtrl.text.trim(),
      versionId:                 _version!.id,
      jornada:                   _jornada,
      // FIX: el cupo ya no se fuerza a 0 en cadena de formación —esa
      // regla no existía en el backend y producía el 400 "El número de
      // estudiantes estimado debe ser mayor a 0". El cupo siempre
      // representa la estimación inicial y queda fijo tras crear la
      // ficha (ver FichaUpdateRequest).
      numeroEstudiantesEstimado: int.parse(_estudiantesCtrl.text.trim()),
      etapa:                     _etapa,
      estado:                    _estado,
      cadenaFormacion:           _cadenaFormacion,
      jefeGrupoId:               _jefeGrupo?.id,
      fechaInicio:               _fechaInicio,
    );

    final provider = context.read<FichaProvider>();
    final ficha    = await provider.createFicha(request);

    if (!mounted) return;

    if (ficha != null) {
      Navigator.pop(context, true);
    } else {
      showFriendlyApiError(
        context,
        provider.mutationError,
        fallback: 'No se pudo crear la ficha.',
      );
    }
  }

  InputDecoration _dec(String label, {String? hint, IconData? icon}) =>
      InputDecoration(
        labelText: label,
        hintText:  hint,
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primary) : null,
        labelStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8)),
      );

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<FichaProvider>().loadingMutation;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: const Text('NUEVA FICHA',
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
            const FichaSeccionLabel('Identificación'),
            TextFormField(
              controller: _codigoCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: _dec('Código de ficha', icon: Icons.tag),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 14),

            // Nivel primero: acota programa y versión a la misma
            // modalidad (no se mezclan cursos cortos con técnicos ni
            // tecnólogos al buscar).
            Wrap(
              spacing: 8,
              children: ProgramaNivel.values.map((n) {
                final selected = _nivel == n;
                return ChoiceChip(
                  label: Text(n.label),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _nivel     = n;
                    _programa  = null;
                    _version   = null;
                    _cadenaFormacion = false;
                  }),
                  selectedColor: AppTheme.primary.withOpacity(0.25),
                  backgroundColor: AppTheme.surface.withOpacity(0.3),
                  labelStyle: TextStyle(
                      color: selected ? AppTheme.primary : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600),
                  side: BorderSide(
                      color: selected ? AppTheme.primary : AppTheme.border),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            FichaPickerTile(
              label: _programa?.nombre ?? 'Seleccionar programa (${_nivel.label})',
              icon: Icons.menu_book_outlined,
              tieneValor: _programa != null,
              onTap: _pickPrograma,
            ),
            const SizedBox(height: 10),
            FichaPickerTile(
              label: _version != null
                  ? 'Versión ${_version!.numero} · ${_version!.totalHoras}h'
                  : 'Seleccionar versión vigente',
              icon: Icons.layers_outlined,
              tieneValor: _version != null,
              enabled: _programa != null,
              onTap: _pickVersion,
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Configuración'),
            FichaDropdownField(
              label:     'Jornada',
              value:     _jornada,
              opciones:  _jornadas,
              onChanged: (v) => setState(() => _jornada = v!),
            ),
            const SizedBox(height: 14),
            FichaDropdownField(
              label:     'Etapa inicial',
              value:     _etapa,
              opciones:  _etapas,
              onChanged: (v) => setState(() => _etapa = v!),
            ),
            const SizedBox(height: 14),
            FichaDropdownField(
              label:     'Estado',
              value:     _estado,
              opciones:  _estados,
              onChanged: (v) => setState(() => _estado = v!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _estudiantesCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: _dec('Cupo estimado', icon: Icons.people_outline)
                  .copyWith(
                helperText:
                    'Es la estimación inicial de matrícula; una vez creada la '
                    'ficha no se puede modificar. El número real de '
                    'estudiantes activos se calcula solo.',
                helperMaxLines: 2,
              ),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return 'Debe ser mayor a 0';
                return null;
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Las horas/semana y la fecha fin estimada se calculan '
              'automáticamente a partir de las horas del programa y su '
              'nivel de formación.',
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 11),
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
                    style:
                        TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                subtitle: Text(
                  _programa == null
                      ? 'Selecciona primero un programa.'
                      : _programaPermiteCadena
                          ? 'Esta ficha se ahorrará trimestres frente a la '
                            'oferta estándar del programa. Solo se define '
                            'aquí; no podrá cambiarse después de crear la '
                            'ficha.'
                          : 'El programa "${_programa!.nombre}" no está '
                            'habilitado para cadena de formación (solo '
                            'aplica a Tecnólogos configurados para ello).',
                  style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.6),
                      fontSize: 11),
                ),
                value: _cadenaFormacion && _programaPermiteCadena,
                // FIX: en vez de fallar tras enviar el formulario, el
                // interruptor queda deshabilitado (con el motivo explicado
                // arriba) cuando el programa elegido no admite cadena de
                // formación.
                onChanged: _programaPermiteCadena
                    ? (v) => setState(() => _cadenaFormacion = v)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Jefe de grupo (opcional)'),
            FichaPickerTile(
              label: _jefeGrupo?.nombre ?? 'Seleccionar docente',
              icon: Icons.person_outline,
              tieneValor: _jefeGrupo != null,
              onTap: _pickJefeGrupo,
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Fechas'),
            FichaFechaTile(
              label: 'Inicio (corte de matrícula)',
              value: _fmtFecha(_fechaInicio),
              onTap: _pickFechaInicio,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Crear ficha',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

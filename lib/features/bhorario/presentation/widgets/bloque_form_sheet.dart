// lib/features/bhorario/presentation/widgets/bloque_form_sheet.dart

import 'package:flutter/material.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/bloque_horario_model.dart';
import '../../data/models/fk_option_model.dart';
import '../../data/repositories/form_lookup_repository.dart';
import '../../data/repositories/horario_repository.dart';
import 'fk_picker_field.dart';

class BloqueFormSheet extends StatefulWidget {
  final BloqueHorarioModel?                    existing;
  final void Function(Map<String, dynamic> data) onSave;

  const BloqueFormSheet({
    super.key,
    this.existing,
    required this.onSave,
  });

  @override
  State<BloqueFormSheet> createState() => _BloqueFormSheetState();
}

class _BloqueFormSheetState extends State<BloqueFormSheet> {
  final _formKey = GlobalKey<FormState>();

  // ── Estado principal ────────────────────────────────────────────────────────
  String    _diaSemana    = 'LUNES';
  String    _jornada      = 'MANANA';
  TimeOfDay _horaInicio   = const TimeOfDay(hour: 6,  minute: 0);
  TimeOfDay _horaFin      = const TimeOfDay(hour: 8,  minute: 0);
  bool      _esRecurrente = true;
  DateTime? _fechaEspef;
  bool      _guardando    = false;

  // ── Selecciones FK ──────────────────────────────────────────────────────────
  FkOption? _docente;
  FkOption? _aula;
  FkOption? _ficha;
  FkOption? _competencia;

  // ── Estado de disponibilidad ────────────────────────────────────────────────
  bool                  _verificando  = false;
  Map<String, dynamic>? _dispResult;

  // ── Constantes de UI ────────────────────────────────────────────────────────
  static const _dias = [
    ('LUNES',     'Lunes'), ('MARTES',    'Martes'),
    ('MIERCOLES', 'Mié'),   ('JUEVES',    'Jueves'),
    ('VIERNES',   'Vie'),   ('SABADO',    'Sáb'),
  ];
  static const _jornadas = [
    ('MANANA', 'Mañana'), ('TARDE', 'Tarde'),
    ('NOCHE',  'Noche'),  ('MIXTA', 'Mixta'),
  ];

  bool get _esEdicion     => widget.existing != null;
  bool get _puedeVerificar =>
      _docente != null || _aula != null || _ficha != null;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e == null) return;
    _diaSemana    = e.diaSemana;
    _jornada      = e.jornada;
    _esRecurrente = e.esRecurrente;
    if (e.fechaEspecifica != null) {
      _fechaEspef = DateTime.tryParse(e.fechaEspecifica!);
    }
    final ini = e.horaInicio.split(':');
    final fin = e.horaFin.split(':');
    _horaInicio = TimeOfDay(
        hour: int.parse(ini[0]), minute: int.parse(ini[1]));
    _horaFin = TimeOfDay(
        hour: int.parse(fin[0]), minute: int.parse(fin[1]));
    // Las FK se pre-cargan con data mínima del modelo existente
    if (e.docenteId != null)
      _docente = FkOption(
          id: e.docenteId!,
          display:  e.docenteNombre ?? 'Docente ${e.docenteId}',
          subtitle: e.docenteEmail);
    if (e.aulaId != null)
      _aula = FkOption(
          id: e.aulaId!,
          display:  e.aulaCodigo    != null ? 'Aula ${e.aulaCodigo}' : 'Aula ${e.aulaId}',
          subtitle: e.aulaTipo);
    if (e.fichaId != null)
      _ficha = FkOption(
          id: e.fichaId!,
          display:  e.fichaCodigo   ?? 'Ficha ${e.fichaId}',
          subtitle: e.fichaPrograma);
    if (e.competenciaId != null)
      _competencia = FkOption(
          id: e.competenciaId!,
          display: e.competenciaNombre ?? 'Competencia ${e.competenciaId}');
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:00';

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isInicio) async {
    final t = await showTimePicker(
      context:     context,
      initialTime: isInicio ? _horaInicio : _horaFin,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary:   AppTheme.primary,
            onPrimary: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (t == null) return;
    setState(() {
      if (isInicio) _horaInicio = t; else _horaFin = t;
      _dispResult = null; // invalidar resultado anterior
    });
  }

  Future<void> _pickFecha() async {
    final d = await showDatePicker(
      context:     context,
      initialDate: _fechaEspef ?? DateTime.now(),
      firstDate:   DateTime.now().subtract(const Duration(days: 365)),
      lastDate:    DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary:   AppTheme.primary,
            onPrimary: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _fechaEspef = d);
  }

  Future<void> _verificarDisponibilidad() async {
    setState(() {
      _verificando = true;
      _dispResult  = null;
    });
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) return;
      final result = await HorarioRepository.verificarDisponibilidad(
        token:      token,
        diaSemana:  _diaSemana,
        horaInicio: _fmt(_horaInicio),
        horaFin:    _fmt(_horaFin),
        docenteId:  _docente?.id,
        aulaId:     _aula?.id,
        fichaId:    _ficha?.id,
        excluirPk:  widget.existing?.id,
      );
      if (mounted) setState(() => _dispResult = result);
    } catch (_) {
      // No bloquear el form si falla la verificación
    } finally {
      if (mounted) setState(() => _verificando = false);
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final totalIni = _horaInicio.hour * 60 + _horaInicio.minute;
    final totalFin = _horaFin.hour    * 60 + _horaFin.minute;
    if (totalFin <= totalIni) {
      _snackError('La hora de fin debe ser mayor a la de inicio');
      return;
    }
    if (!_esRecurrente && _fechaEspef == null) {
      _snackError('Selecciona la fecha específica del bloque');
      return;
    }

    setState(() => _guardando = true);

    widget.onSave({
      'dia_semana':    _diaSemana,
      'hora_inicio':   _fmt(_horaInicio),
      'hora_fin':      _fmt(_horaFin),
      'jornada':       _jornada,
      'es_recurrente': _esRecurrente,
      if (!_esRecurrente && _fechaEspef != null)
        'fecha_especifica': _fmtDate(_fechaEspef!),
      if (_docente     != null) 'docente':     _docente!.id,
      if (_aula        != null) 'aula':        _aula!.id,
      if (_ficha       != null) 'ficha':       _ficha!.id,
      if (_competencia != null) 'competencia': _competencia!.id,
    });
  }

  void _snackError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:         Text(msg),
        backgroundColor: Colors.redAccent,
        behavior:        SnackBarBehavior.floating,
      ));

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color:        AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color:        AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Título
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
            child: Row(
              children: [
                Icon(
                  _esEdicion ? Icons.edit_rounded : Icons.add_rounded,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  _esEdicion ? 'Editar bloque' : 'Nuevo bloque',
                  style: const TextStyle(
                    color:      AppTheme.textPrimary,
                    fontSize:   20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.border, height: 1),

          // Formulario
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Día ────────────────────────────────────────────────
                    _Label('Día de la semana'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _dias.map((d) {
                        final sel = _diaSemana == d.$1;
                        return ChoiceChip(
                          label:           Text(d.$2),
                          selected:        sel,
                          onSelected: (_) => setState(() {
                            _diaSemana  = d.$1;
                            _dispResult = null;
                          }),
                          selectedColor:   AppTheme.primary,
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            color:      sel ? Colors.black : AppTheme.textSecondary,
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          ),
                          side: BorderSide(
                              color: sel ? AppTheme.primary : AppTheme.border),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Horario ────────────────────────────────────────────
                    _Label('Horario'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _TimePicker(
                            etiqueta: 'Inicio',
                            tiempo:   _horaInicio,
                            onTap:    () => _pickTime(true),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.arrow_forward_rounded,
                              color: AppTheme.textSecondary),
                        ),
                        Expanded(
                          child: _TimePicker(
                            etiqueta: 'Fin',
                            tiempo:   _horaFin,
                            onTap:    () => _pickTime(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Jornada ────────────────────────────────────────────
                    _Label('Jornada'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _jornadas.map((j) {
                        final sel = _jornada == j.$1;
                        return ChoiceChip(
                          label:           Text(j.$2),
                          selected:        sel,
                          onSelected: (_) => setState(() => _jornada = j.$1),
                          selectedColor:   AppTheme.primary,
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            color:      sel ? Colors.black : AppTheme.textSecondary,
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          ),
                          side: BorderSide(
                              color: sel ? AppTheme.primary : AppTheme.border),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Recurrencia ────────────────────────────────────────
                    _Label('Recurrencia'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color:        AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border:       Border.all(color: AppTheme.border),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value:     _esRecurrente,
                        onChanged: (v) => setState(() {
                          _esRecurrente = v;
                          if (v) _fechaEspef = null;
                        }),
                        activeColor: AppTheme.primary,
                        title: const Text(
                          'Bloque recurrente',
                          style: TextStyle(
                              color: AppTheme.textPrimary, fontSize: 14),
                        ),
                        subtitle: Text(
                          _esRecurrente
                              ? 'Aplica cada semana'
                              : 'Solo en fecha específica',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ),
                    ),
                    if (!_esRecurrente) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _pickFecha,
                        child: Container(
                          width:   double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color:  AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _fechaEspef != null
                                  ? AppTheme.primary
                                  : AppTheme.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size:  18,
                                color: _fechaEspef != null
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _fechaEspef != null
                                    ? _fmtDate(_fechaEspef!)
                                    : 'Seleccionar fecha',
                                style: TextStyle(
                                  color: _fechaEspef != null
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // ── Asignaciones FK ────────────────────────────────────
                    _Label('Asignaciones'),
                    const SizedBox(height: 8),

                    FkPickerField(
                      value:        _docente,
                      icon:         Icons.person_outline_rounded,
                      label:        'Docente',
                      placeholder:  'Seleccionar docente',
                      onChanged: (v) => setState(() {
                        _docente    = v;
                        _dispResult = null;
                      }),
                      fetchOptions: () async {
                        final token =
                            await TokenStorage.getAccessToken() ?? '';
                        return FormLookupRepository.getDocentes(token: token);
                      },
                    ),
                    const SizedBox(height: 10),

                    FkPickerField(
                      value:        _aula,
                      icon:         Icons.meeting_room_outlined,
                      label:        'Aula',
                      placeholder:  'Seleccionar aula',
                      onChanged: (v) => setState(() {
                        _aula       = v;
                        _dispResult = null;
                      }),
                      fetchOptions: () async {
                        final token =
                            await TokenStorage.getAccessToken() ?? '';
                        return FormLookupRepository.getAulas(token: token);
                      },
                    ),
                    const SizedBox(height: 10),

                    FkPickerField(
                      value:        _ficha,
                      icon:         Icons.group_outlined,
                      label:        'Ficha',
                      placeholder:  'Seleccionar ficha',
                      onChanged: (v) => setState(() {
                        _ficha      = v;
                        _dispResult = null;
                      }),
                      fetchOptions: () async {
                        final token =
                            await TokenStorage.getAccessToken() ?? '';
                        return FormLookupRepository.getFichas(token: token);
                      },
                    ),
                    const SizedBox(height: 10),

                    FkPickerField(
                      value:        _competencia,
                      icon:         Icons.book_outlined,
                      label:        'Competencia',
                      placeholder:  'Seleccionar competencia (opcional)',
                      onChanged:    (v) => setState(() => _competencia = v),
                      fetchOptions: () async {
                        final token =
                            await TokenStorage.getAccessToken() ?? '';
                        return FormLookupRepository.getCompetencias(token: token);
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Verificador de disponibilidad ──────────────────────
                    if (_puedeVerificar) ...[
                      _Label('Disponibilidad'),
                      const SizedBox(height: 8),
                      _DispWidget(
                        verificando: _verificando,
                        resultado:   _dispResult,
                        docente:     _docente,
                        aula:        _aula,
                        ficha:       _ficha,
                        onVerificar: _verificarDisponibilidad,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Botón guardar ──────────────────────────────────────
                    SizedBox(
                      width:  double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _guardando ? null : _guardar,
                        child: _guardando
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.black,
                                ),
                              )
                            : Text(
                                _esEdicion
                                    ? 'Guardar cambios'
                                    : 'Crear bloque',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:   16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget de disponibilidad ────────────────────────────────────────────────

class _DispWidget extends StatelessWidget {
  final bool                  verificando;
  final Map<String, dynamic>? resultado;
  final FkOption?             docente;
  final FkOption?             aula;
  final FkOption?             ficha;
  final VoidCallback          onVerificar;

  const _DispWidget({
    required this.verificando,
    required this.resultado,
    required this.docente,
    required this.aula,
    required this.ficha,
    required this.onVerificar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:     const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón verificar
          SizedBox(
            width:  double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: verificando ? null : onVerificar,
              icon: verificando
                  ? const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primary,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: Text(
                verificando
                    ? 'Verificando…'
                    : resultado == null
                        ? 'Verificar disponibilidad'
                        : 'Verificar de nuevo',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),

          // Resultado
          if (resultado != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                if (docente != null)
                  _DispChip(
                    label:       'Docente',
                    disponible:  resultado!['docente_disponible'] as bool? ?? true,
                  ),
                if (aula != null)
                  _DispChip(
                    label:       'Aula',
                    disponible:  resultado!['aula_disponible'] as bool? ?? true,
                  ),
                if (ficha != null)
                  _DispChip(
                    label:       'Ficha',
                    disponible:  resultado!['ficha_disponible'] as bool? ?? true,
                  ),
              ],
            ),
            // Conflictos detallados
            if (resultado!['conflictos'] is List) ...[
              const SizedBox(height: 8),
              ...(resultado!['conflictos'] as List<dynamic>).map(
                (c) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 14, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c.toString(),
                          style: const TextStyle(
                            color:    AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DispChip extends StatelessWidget {
  final String label;
  final bool   disponible;
  const _DispChip({required this.label, required this.disponible});

  @override
  Widget build(BuildContext context) {
    final color = disponible ? AppTheme.primary : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            disponible
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size:  14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color:      color,
              fontSize:   12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ──────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color:         AppTheme.textSecondary,
      fontSize:      13,
      fontWeight:    FontWeight.w500,
      letterSpacing: 0.4,
    ),
  );
}

class _TimePicker extends StatelessWidget {
  final String     etiqueta;
  final TimeOfDay  tiempo;
  final VoidCallback onTap;
  const _TimePicker({
    required this.etiqueta,
    required this.tiempo,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:        AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etiqueta,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 16, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  '${tiempo.hour.toString().padLeft(2, '0')}:'
                  '${tiempo.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color:      AppTheme.textPrimary,
                    fontSize:   18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
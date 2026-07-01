// lib/features/planificacion/presentation/widgets/views/plan_form_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/datasources/selector_remote_datasource.dart';
import '../../../data/models/selector_models.dart';
import '../../../domain/entities/plan_trimestral_entity.dart';
import '../../providers/planificacion_provider.dart';
import '../../providers/selector_provider.dart';
import '../planificacion_widgets.dart';
import '../search_selector_sheet.dart';

class PlanFormView extends StatefulWidget {
  /// null → crear nuevo. Non-null → editar fechas.
  final PlanTrimestralDetalle? planToEdit;

  const PlanFormView({super.key, this.planToEdit});

  bool get isEditing => planToEdit != null;

  @override
  State<PlanFormView> createState() => _PlanFormViewState();
}

class _PlanFormViewState extends State<PlanFormView> {
  final _formKey              = GlobalKey<FormState>();
  final _trimestreController  = TextEditingController();
  final _selectorDs           = SelectorRemoteDatasource();

  FichaSelector? _fichaSeleccionada;
  DateTime?      _fechaInicio;
  DateTime?      _fechaFin;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _fechaInicio = widget.planToEdit!.fechaInicio;
      _fechaFin    = widget.planToEdit!.fechaFin;
      _trimestreController.text = widget.planToEdit!.trimestre.toString();
    }
  }

  @override
  void dispose() {
    _trimestreController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFicha() async {
    final provider = SelectorProvider<FichaSelector>(
      (query) => _selectorDs.buscarFichas(query: query),
    );
    final seleccion = await SearchSelectorSheet.open<FichaSelector>(
      context,
      titulo:       'Seleccionar ficha',
      hintBusqueda: 'Buscar por código de ficha…',
      icon:         Icons.folder_outlined,
      provider:     provider,
    );
    if (seleccion != null) setState(() => _fichaSeleccionada = seleccion);
  }

  Future<void> _pickFecha({required bool isInicio}) async {
    final initial = (isInicio ? _fechaInicio : _fechaFin) ?? DateTime.now();
    final picked  = await showDatePicker(
      context:     context,
      initialDate: initial,
      firstDate:   DateTime(2020),
      lastDate:    DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary:   Color(0xFF35F58A),
            onPrimary: Colors.black,
            surface:   Color(0xFF0C1E29),
            onSurface: Color(0xFFEAFBF4),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isInicio) {
        _fechaInicio = picked;
        if (_fechaFin != null && !_fechaFin!.isAfter(picked)) {
          _fechaFin = null;
        }
      } else {
        _fechaFin = picked;
      }
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaInicio == null || _fechaFin == null) {
      _showError('Selecciona las fechas de inicio y fin.');
      return;
    }

    final provider = context.read<PlanificacionProvider>();
    provider.clearError();

    if (widget.isEditing) {
      final ok = await provider.actualizarFechas(
        widget.planToEdit!.id,
        fechaInicio: _fechaInicio,
        fechaFin:    _fechaFin,
      );
      if (ok && mounted) Navigator.pop(context);
      return;
    }

    if (_fichaSeleccionada == null) {
      _showError('Selecciona una ficha.');
      return;
    }
    final trimestre = int.tryParse(_trimestreController.text.trim());
    if (trimestre == null) {
      _showError('El trimestre debe ser un número válido.');
      return;
    }

    final nuevo = await provider.crearPlan(
      fichaId:     _fichaSeleccionada!.id,
      trimestre:   trimestre,
      fechaInicio: _fechaInicio!,
      fechaFin:    _fechaFin!,
    );
    if (nuevo != null && mounted) Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(msg),
        backgroundColor: Colors.redAccent,
        behavior:        SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Editar fechas' : 'Nuevo plan trimestral';

    return Scaffold(
      backgroundColor: const Color(0xFF06141D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06141D),
        title: Text(
          title,
          style: const TextStyle(
            color:      Color(0xFFEAFBF4),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF35F58A)),
      ),
      body: Consumer<PlanificacionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ErrorBanner(message: provider.error!),
                    ),

                  if (!widget.isEditing) ...[
                    const _SectionLabel('Datos del plan'),
                    const SizedBox(height: 12),
                    _SelectorField(
                      label:     'Ficha',
                      icon:      Icons.folder_outlined,
                      valueText: _fichaSeleccionada?.tituloPrincipal,
                      subText:   _fichaSeleccionada?.subtitulo,
                      onTap:     _seleccionarFicha,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller:   _trimestreController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Color(0xFFEAFBF4)),
                      decoration: const InputDecoration(
                        labelText:  'Trimestre',
                        prefixIcon: Icon(Icons.looks_one_outlined),
                        hintText:   'Ej: 1, 2, 3…',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        final n = int.tryParse(v.trim());
                        if (n == null || n <= 0) return 'Debe ser mayor a 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  const _SectionLabel('Período de ejecución'),
                  const SizedBox(height: 12),

                  _DatePickerField(
                    label:   'Fecha de inicio',
                    value:   _fechaInicio,
                    icon:    Icons.play_arrow_outlined,
                    onTap:   () => _pickFecha(isInicio: true),
                  ),
                  const SizedBox(height: 14),
                  _DatePickerField(
                    label:   'Fecha de fin',
                    value:   _fechaFin,
                    icon:    Icons.stop_outlined,
                    onTap:   () => _pickFecha(isInicio: false),
                    enabled: _fechaInicio != null,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isSubmitting ? null : _guardar,
                      child: provider.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width:  20,
                              child:  CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.black),
                            )
                          : Text(
                              widget.isEditing
                                  ? 'Guardar cambios'
                                  : 'Crear plan',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color:         Color(0xFF35F58A),
        fontWeight:    FontWeight.w700,
        fontSize:      13,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SelectorField extends StatelessWidget {
  final String    label;
  final IconData  icon;
  final String?   valueText;
  final String?   subText;
  final VoidCallback onTap;

  const _SelectorField({
    required this.label,
    required this.icon,
    required this.valueText,
    this.subText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = valueText != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color:        const Color(0xFF010C12),
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: const Color(0xFF1D4E42)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF35F58A)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color:    Colors.white.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valueText ?? 'Seleccionar $label',
                    style: TextStyle(
                      color:      hasValue
                          ? const Color(0xFFEAFBF4)
                          : Colors.white.withOpacity(0.3),
                      fontSize:   14,
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  if (hasValue && subText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subText!,
                      style: TextStyle(
                        color:    Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String    label;
  final DateTime? value;
  final IconData  icon;
  final VoidCallback onTap;
  final bool      enabled;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final display = value != null
        ? '${value!.day.toString().padLeft(2, '0')}/'
          '${value!.month.toString().padLeft(2, '0')}/'
          '${value!.year}'
        : 'Seleccionar fecha';

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color:        const Color(0xFF010C12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? const Color(0xFF1D4E42)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size:  20,
              color: enabled
                  ? const Color(0xFF35F58A)
                  : Colors.white.withOpacity(0.2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color:    Colors.white.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    display,
                    style: TextStyle(
                      color:      value != null
                          ? const Color(0xFFEAFBF4)
                          : Colors.white.withOpacity(0.3),
                      fontSize:   14,
                      fontWeight: value != null ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}

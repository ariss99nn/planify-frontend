// lib/features/planificacion/presentation/widgets/views/item_form_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/datasources/selector_remote_datasource.dart';
import '../../../data/models/selector_models.dart';
import '../../../domain/entities/plan_trimestral_entity.dart';
import '../../providers/planificacion_provider.dart';
import '../../providers/selector_provider.dart';
import '../planificacion_widgets.dart';
import '../search_selector_sheet.dart';

class ItemFormView extends StatefulWidget {
  final int      planId;
  final ItemPlan? itemToEdit;

  const ItemFormView({super.key, required this.planId, this.itemToEdit});

  bool get isEditing => itemToEdit != null;

  @override
  State<ItemFormView> createState() => _ItemFormViewState();
}

class _ItemFormViewState extends State<ItemFormView> {
  final _formKey        = GlobalKey<FormState>();
  final _horasController = TextEditingController();
  final _ordenController = TextEditingController();
  final _selectorDs      = SelectorRemoteDatasource();

  CompetenciaSelector? _competenciaSeleccionada;
  DocenteSelector?     _docenteSeleccionado;
  bool                 _completado = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final item = widget.itemToEdit!;
      _horasController.text = item.horasAsignadas.toString();
      _ordenController.text = item.orden.toString();
      _completado = item.completado;
      if (item.docenteId != null && item.docenteNombre != null) {
        _docenteSeleccionado = DocenteSelector(
          id:                   item.docenteId!,
          nombre:               item.docenteNombre!,
          email:                '',
          horasMaxSemanales:    0,
          horasAsignadasSemana: 0,
          estaSobrecargado:     false,
          estado:               true,
        );
      }
    }
  }

  @override
  void dispose() {
    _horasController.dispose();
    _ordenController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarCompetencia() async {
    final provider = SelectorProvider<CompetenciaSelector>(
      (query) => _selectorDs.buscarCompetencias(query: query),
    );
    final seleccion = await SearchSelectorSheet.open<CompetenciaSelector>(
      context,
      titulo:       'Seleccionar competencia',
      hintBusqueda: 'Buscar por código o nombre…',
      icon:         Icons.school_outlined,
      provider:     provider,
    );
    if (seleccion != null) setState(() => _competenciaSeleccionada = seleccion);
  }

  Future<void> _seleccionarDocente() async {
    final provider = SelectorProvider<DocenteSelector>(
      (query) => _selectorDs.buscarDocentes(query: query),
    );
    final seleccion = await SearchSelectorSheet.open<DocenteSelector>(
      context,
      titulo:       'Seleccionar docente',
      hintBusqueda: 'Buscar por nombre…',
      icon:         Icons.person_outline,
      provider:     provider,
    );
    if (seleccion != null) setState(() => _docenteSeleccionado = seleccion);
  }

  void _quitarDocente() => setState(() => _docenteSeleccionado = null);

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PlanificacionProvider>();
    final horas    = int.tryParse(_horasController.text.trim());
    final orden    = int.tryParse(_ordenController.text.trim());

    provider.clearError();

    if (widget.isEditing) {
      final ok = await provider.actualizarItem(
        widget.itemToEdit!.id,
        docenteId:      _docenteSeleccionado?.id,
        horasAsignadas: horas,
        orden:          orden,
        completado:     _completado,
      );
      if (ok && mounted) Navigator.pop(context);
      return;
    }

    if (_competenciaSeleccionada == null) {
      _showError('Selecciona una competencia.');
      return;
    }

    final item = await provider.crearItem(
      planId:         widget.planId,
      competenciaId:  _competenciaSeleccionada!.id,
      docenteId:      _docenteSeleccionado?.id,
      horasAsignadas: horas!,
      orden:          orden!,
    );
    if (item != null && mounted) Navigator.pop(context);
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
    final title =
        widget.isEditing ? 'Editar competencia' : 'Agregar competencia';

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

                  _PlanBadge(),
                  const SizedBox(height: 20),

                  if (!widget.isEditing) ...[
                    const _SectionLabel('Competencia'),
                    const SizedBox(height: 12),
                    _SelectorField(
                      label:     'Competencia',
                      icon:      Icons.school_outlined,
                      valueText: _competenciaSeleccionada?.tituloPrincipal,
                      subText:   _competenciaSeleccionada?.subtitulo,
                      onTap:     _seleccionarCompetencia,
                    ),
                    const SizedBox(height: 24),
                  ],

                  const _SectionLabel('Asignación'),
                  const SizedBox(height: 12),

                  _SelectorField(
                    label:     'Docente (opcional)',
                    icon:      Icons.person_outline,
                    valueText: _docenteSeleccionado?.tituloPrincipal,
                    subText:   _docenteSeleccionado?.subtitulo,
                    onTap:     _seleccionarDocente,
                    onClear:   _docenteSeleccionado != null ? _quitarDocente : null,
                    warning:   _docenteSeleccionado?.estaSobrecargado == true,
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:   _horasController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFFEAFBF4)),
                          decoration: const InputDecoration(
                            labelText:  'Horas asignadas',
                            prefixIcon: Icon(Icons.timer_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Requerido';
                            final n = int.tryParse(v.trim());
                            if (n == null || n <= 0) return 'Debe ser > 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller:   _ordenController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFFEAFBF4)),
                          decoration: const InputDecoration(
                            labelText:  'Orden',
                            prefixIcon: Icon(Icons.sort_rounded),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Requerido';
                            final n = int.tryParse(v.trim());
                            if (n == null || n <= 0) return 'Debe ser > 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  if (widget.isEditing) ...[
                    const SizedBox(height: 20),
                    const _SectionLabel('Estado'),
                    const SizedBox(height: 12),
                    _CompletadoSwitch(
                      value:     _completado,
                      onChanged: (v) => setState(() => _completado = v),
                    ),
                  ],

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
                                  : 'Agregar competencia',
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

class _PlanBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanificacionProvider>().selectedPlan;
    if (plan == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:        const Color(0xFF35F58A).withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(
            color: const Color(0xFF35F58A).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_outlined,
              color: Color(0xFF35F58A), size: 16),
          const SizedBox(width: 8),
          Text(
            'Ficha ${plan.fichaCodigo}  ·  Trimestre ${plan.trimestre}',
            style: const TextStyle(
              color:      Color(0xFF35F58A),
              fontSize:   12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorField extends StatelessWidget {
  final String    label;
  final IconData  icon;
  final String?   valueText;
  final String?   subText;
  final VoidCallback  onTap;
  final VoidCallback? onClear;
  final bool      warning;

  const _SelectorField({
    required this.label,
    required this.icon,
    required this.valueText,
    this.subText,
    required this.onTap,
    this.onClear,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue    = valueText != null;
    final borderColor = warning
        ? Colors.amber.withOpacity(0.5)
        : const Color(0xFF1D4E42);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color:        const Color(0xFF010C12),
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: warning ? Colors.amber : const Color(0xFF35F58A)),
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
                    valueText ?? 'Sin asignar',
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
                        color: warning
                            ? Colors.amber.withOpacity(0.8)
                            : Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: Icon(Icons.close,
                    size: 16, color: Colors.white.withOpacity(0.4)),
                onPressed:    onClear,
                visualDensity: VisualDensity.compact,
              )
            else
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}

class _CompletadoSwitch extends StatelessWidget {
  final bool             value;
  final ValueChanged<bool> onChanged;

  const _CompletadoSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        const Color(0xFF010C12),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: const Color(0xFF1D4E42)),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.radio_button_unchecked,
            color: value
                ? const Color(0xFF35F58A)
                : Colors.white.withOpacity(0.3),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Marcar como completada',
                  style: TextStyle(
                    color:      Color(0xFFEAFBF4),
                    fontSize:   13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Indica que esta competencia finalizó su ejecución.',
                  style: TextStyle(
                    color:    Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value:              value,
            onChanged:          onChanged,
            activeColor:        const Color(0xFF35F58A),
            inactiveTrackColor: Colors.white.withOpacity(0.08),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/competencia_model.dart';
import '../providers/competencia_provider.dart';
import '../../competencia_theme.dart';
import '../../../../core/widgets/widgets.dart';

class CompetenciaTransversalFormScreen extends StatefulWidget {
  final CompetenciaItem? existing;

  const CompetenciaTransversalFormScreen({super.key, this.existing});

  @override
  State<CompetenciaTransversalFormScreen> createState() =>
      _CompetenciaTransversalFormScreenState();
}

class _CompetenciaTransversalFormScreenState
    extends State<CompetenciaTransversalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigo;
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _horasTrimestre;
  bool _esInduccion    = false;
  bool _induccionActiva = true;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _codigo         = TextEditingController(text: e?.codigo ?? '');
    _nombre         = TextEditingController(text: e?.nombre ?? '');
    _descripcion    = TextEditingController(text: e?.descripcion ?? '');
    _horasTrimestre = TextEditingController(
        text: e?.horasTrimestre != null ? '${e!.horasTrimestre}' : '');
    if (e != null) {
      _esInduccion     = e.esInduccion;
      _induccionActiva = e.inductionActiva;
    }
  }

  @override
  void dispose() {
    for (final c in [_codigo, _nombre, _descripcion, _horasTrimestre]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<CompetenciaProvider>();
    prov.clearSaveError();

    CompetenciaItem? result;
    if (_isEdit) {
      result = await prov.update(widget.existing!.id, {
        'nombre':                      _nombre.text.trim(),
        'descripcion':                 _descripcion.text.trim(),
        'es_induccion':                _esInduccion,
        'induccion_activa':            _induccionActiva,
        'horas_trimestre_transversal': int.parse(_horasTrimestre.text.trim()),
      });
    } else {
      result = await prov.createTransversal({
        'codigo':                      _codigo.text.trim().toUpperCase(),
        'nombre':                      _nombre.text.trim(),
        'descripcion':                 _descripcion.text.trim(),
        'es_induccion':                _esInduccion,
        'induccion_activa':            _induccionActiva,
        'horas_trimestre_transversal': int.parse(_horasTrimestre.text.trim()),
      });
    }

    if (!mounted) return;
    if (result != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? 'Competencia actualizada.'
              : 'Competencia transversal creada.'),
          backgroundColor: CT.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CT.background,
      appBar: AppBar(
        backgroundColor: CT.background,
        title: Text(
          _isEdit
              ? 'Editar competencia transversal'
              : 'Nueva competencia transversal',
          style: const TextStyle(
              color: CT.textPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: CT.primary),
        elevation: 0,
      ),
      body: Consumer<CompetenciaProvider>(
        builder: (context, prov, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prov.saveError != null)
                    CyberErrorBanner(message: prov.saveError),

                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CT.transversal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: CT.transversal.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.public_outlined,
                            color: CT.transversal, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Esta competencia pertenece al centro educativo, no a una asignatura ni módulo específico.',
                            style: TextStyle(
                                color: CT.transversal.withOpacity(0.9),
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!_isEdit) ...[
                    _label('Código *'),
                    _textField(
                      controller: _codigo,
                      hint: 'Ej: COMP-T01',
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _readonlyField('Código', widget.existing?.codigo ?? '—'),
                    const SizedBox(height: 16),
                  ],

                  _label('Nombre *'),
                  _textField(
                    controller: _nombre,
                    hint: 'Ej: Trabajo en equipo',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Descripción'),
                  _textField(
                    controller: _descripcion,
                    hint: 'Descripción de la competencia…',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  _label('Horas por trimestre *'),
                  _textField(
                    controller: _horasTrimestre,
                    hint: 'Ej: 12',
                    inputType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null) return 'Número requerido';
                      if (n <= 0) return 'Mayor a 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  _SwitchTile(
                    title: 'Marcar como inducción',
                    subtitle:
                        'Obligatoria en el trimestre 1 para todo estudiante nuevo.',
                    value: _esInduccion,
                    onChanged: (v) => setState(() => _esInduccion = v),
                  ),
                  if (_esInduccion)
                    _SwitchTile(
                      title: 'Inducción activa',
                      subtitle:
                          'Permite desactivarla sin eliminar la competencia.',
                      value: _induccionActiva,
                      onChanged: (v) => setState(() => _induccionActiva = v),
                    ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: prov.isSaving ? null : () => _submit(context),
                      child: prov.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.black))
                          : Text(
                              _isEdit
                                  ? 'Guardar cambios'
                                  : 'Crear competencia transversal',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: CT.textSec, fontSize: 12, letterSpacing: 0.5)),
      );

  Widget _readonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: CT.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CT.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, size: 14, color: CT.textSec),
              const SizedBox(width: 8),
              Text(value,
                  style: const TextStyle(color: CT.textSec, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      textCapitalization: textCapitalization,
      inputFormatters: inputType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: validator,
      style: const TextStyle(color: CT.textPrimary, fontSize: 14),
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: CT.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CT.border),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        activeColor: CT.primary,
        title: Text(title,
            style: const TextStyle(
                color: CT.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: CT.textSec, fontSize: 11)),
      ),
    );
  }
}

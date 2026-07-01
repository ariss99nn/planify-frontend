import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/rap_model.dart';
import '../providers/rap_provider.dart';
import '../../competencia_theme.dart';
import '../../../../core/widgets/widgets.dart';

class RapFormScreen extends StatefulWidget {
  final RapItem? existing;
  final int? preCompetenciaId;

  const RapFormScreen({super.key, this.existing, this.preCompetenciaId});

  @override
  State<RapFormScreen> createState() => _RapFormScreenState();
}

class _RapFormScreenState extends State<RapFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _competenciaId;
  late final TextEditingController _codigo;
  late final TextEditingController _descripcion;
  late final TextEditingController _criterios;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _competenciaId = TextEditingController(
      text: e?.competenciaId != null
          ? '${e!.competenciaId}'
          : (widget.preCompetenciaId != null
              ? '${widget.preCompetenciaId}'
              : ''),
    );
    _codigo      = TextEditingController(text: e?.codigo ?? '');
    _descripcion = TextEditingController(text: e?.descripcion ?? '');
    _criterios   = TextEditingController(text: e?.criteriosEvaluacion ?? '');
  }

  @override
  void dispose() {
    for (final c in [_competenciaId, _codigo, _descripcion, _criterios]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<RapProvider>();
    prov.clearSaveError();

    RapItem? result;
    if (_isEdit) {
      result = await prov.update(widget.existing!.id, {
        'descripcion':          _descripcion.text.trim(),
        'criterios_evaluacion': _criterios.text.trim(),
      });
    } else {
      result = await prov.create({
        'competencia':          int.parse(_competenciaId.text.trim()),
        'codigo':               _codigo.text.trim().toUpperCase(),
        'descripcion':          _descripcion.text.trim(),
        'criterios_evaluacion': _criterios.text.trim(),
      });
    }

    if (!mounted) return;
    if (result != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEdit ? 'Resultado actualizado.' : 'Resultado creado.'),
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
          _isEdit ? 'Editar resultado' : 'Nuevo resultado de aprendizaje',
          style: const TextStyle(
              color: CT.textPrimary, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: CT.primary),
        elevation: 0,
      ),
      body: Consumer<RapProvider>(
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

                  if (!_isEdit) ...[
                    _label('ID de la competencia *'),
                    _textField(
                      controller: _competenciaId,
                      hint: 'Ej: 7',
                      inputType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (int.tryParse(v.trim()) == null)
                          return 'Debe ser un número';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _label('Código *'),
                    _textField(
                      controller: _codigo,
                      hint: 'Ej: RAP-001',
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _readonlyField('Competencia',
                        widget.existing?.competenciaNombre ?? '—'),
                    const SizedBox(height: 12),
                    _readonlyField('Código', widget.existing?.codigo ?? '—'),
                    const SizedBox(height: 16),
                  ],

                  _label('Descripción *'),
                  _textField(
                    controller: _descripcion,
                    hint: 'Descripción del resultado de aprendizaje…',
                    maxLines: 4,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Criterios de evaluación'),
                  _textField(
                    controller: _criterios,
                    hint: 'Criterios con los que se evalúa el resultado…',
                    maxLines: 4,
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
                              _isEdit ? 'Guardar cambios' : 'Crear resultado',
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
              Expanded(
                child: Text(value,
                    style: const TextStyle(color: CT.textSec, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
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

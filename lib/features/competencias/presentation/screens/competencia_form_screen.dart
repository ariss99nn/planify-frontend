import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/competencia_model.dart';
import '../providers/competencia_provider.dart';
import '../../competencia_theme.dart';
import '../../../../core/widgets/widgets.dart';

class CompetenciaFormScreen extends StatefulWidget {
  final CompetenciaItem? existing;
  final int? preAsignaturaId;

  const CompetenciaFormScreen({super.key, this.existing, this.preAsignaturaId});

  @override
  State<CompetenciaFormScreen> createState() => _CompetenciaFormScreenState();
}

class _CompetenciaFormScreenState extends State<CompetenciaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _asignaturaId;
  late final TextEditingController _codigo;
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _asignaturaId = TextEditingController(
      text: e?.asignaturaId != null
          ? '${e!.asignaturaId}'
          : (widget.preAsignaturaId != null
              ? '${widget.preAsignaturaId}'
              : ''),
    );
    _codigo      = TextEditingController(text: e?.codigo ?? '');
    _nombre      = TextEditingController(text: e?.nombre ?? '');
    _descripcion = TextEditingController(text: e?.descripcion ?? '');
  }

  @override
  void dispose() {
    for (final c in [_asignaturaId, _codigo, _nombre, _descripcion]) {
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
        'nombre':      _nombre.text.trim(),
        'descripcion': _descripcion.text.trim(),
      });
    } else {
      result = await prov.createPrincipal({
        'asignatura':  int.parse(_asignaturaId.text.trim()),
        'codigo':      _codigo.text.trim().toUpperCase(),
        'nombre':      _nombre.text.trim(),
        'descripcion': _descripcion.text.trim(),
      });
    }

    if (!mounted) return;
    if (result != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEdit ? 'Competencia actualizada.' : 'Competencia creada.'),
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
            _isEdit ? 'Editar competencia' : 'Nueva competencia principal',
            style: const TextStyle(
                color: CT.textPrimary, fontWeight: FontWeight.w700)),
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

                  if (!_isEdit) ...[
                    _label('ID de la asignatura *'),
                    _textField(
                      controller: _asignaturaId,
                      hint: 'Ej: 4',
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
                      hint: 'Ej: COMP-001',
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _readonlyField('Asignatura',
                        widget.existing?.asignaturaNombre ?? '—'),
                    const SizedBox(height: 12),
                    _readonlyField('Código', widget.existing?.codigo ?? '—'),
                    const SizedBox(height: 16),
                  ],

                  _label('Nombre *'),
                  _textField(
                    controller: _nombre,
                    hint: 'Ej: Análisis de requerimientos',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Descripción'),
                  _textField(
                      controller: _descripcion,
                      hint: 'Descripción de la competencia…',
                      maxLines: 4),
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
                                  : 'Crear competencia',
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
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

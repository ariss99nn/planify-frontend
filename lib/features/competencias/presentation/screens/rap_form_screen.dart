import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/rap_model.dart';
import '../providers/rap_provider.dart';
import '../providers/competencia_provider.dart';
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
  late final TextEditingController _codigo;
  late final TextEditingController _descripcion;
  late final TextEditingController _criterios;
  int? _competenciaId;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _competenciaId = e?.competenciaId ?? widget.preCompetenciaId;
    _codigo      = TextEditingController(text: e?.codigo ?? '');
    _descripcion = TextEditingController(text: e?.descripcion ?? '');
    _criterios   = TextEditingController(text: e?.criteriosEvaluacion ?? '');

    // Trae el listado de competencias para el selector (solo al crear).
    if (!_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<CompetenciaProvider>().fetchCompetenciasForDropdown();
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_codigo, _descripcion, _criterios]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEdit && _competenciaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una competencia.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
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
        'competencia':          _competenciaId,
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
                    _label('Competencia *'),
                    Consumer<CompetenciaProvider>(
                      builder: (context, compProv, _) {
                        if (compProv.isLoadingDropdown) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: CT.primary),
                            ),
                          );
                        }
                        if (compProv.dropdownError != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(compProv.dropdownError!,
                                  style: const TextStyle(
                                      color: Colors.redAccent, fontSize: 12)),
                              TextButton(
                                onPressed: () => compProv
                                    .fetchCompetenciasForDropdown(force: true),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          );
                        }
                        final competencias = compProv.dropdownItems;
                        final valorValido = competencias
                            .any((c) => c.id == _competenciaId);
                        return _dropdown<int>(
                          value: valorValido ? _competenciaId : null,
                          hint: 'Selecciona una competencia',
                          items: {
                            for (final c in competencias)
                              c.id: '${c.codigo} — ${c.nombre}',
                          },
                          onChanged: (v) =>
                              setState(() => _competenciaId = v),
                        );
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

  Widget _dropdown<T>({
    required T?  value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: CT.surfaceLight,
      style: const TextStyle(color: CT.textPrimary, fontSize: 14),
      icon: const Icon(Icons.keyboard_arrow_down, color: CT.primary),
      decoration: InputDecoration(hintText: hint),
      items: items.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

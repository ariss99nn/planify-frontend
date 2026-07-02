import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/competencia_model.dart';
import '../providers/competencia_provider.dart';
import '../providers/asignatura_provider.dart';
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
  late final TextEditingController _codigo;
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  int? _asignaturaId;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _asignaturaId = e?.asignaturaId ?? widget.preAsignaturaId;
    _codigo      = TextEditingController(text: e?.codigo ?? '');
    _nombre      = TextEditingController(text: e?.nombre ?? '');
    _descripcion = TextEditingController(text: e?.descripcion ?? '');

    // Trae el listado de asignaturas para el selector (solo hace falta al crear).
    if (!_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AsignaturaProvider>().fetchAsignaturasForDropdown();
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_codigo, _nombre, _descripcion]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEdit && _asignaturaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una asignatura.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
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
        'asignatura':  _asignaturaId,
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
                    _label('Asignatura *'),
                    Consumer<AsignaturaProvider>(
                      builder: (context, asigProv, _) {
                        if (asigProv.isLoadingDropdown) {
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
                        if (asigProv.dropdownError != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(asigProv.dropdownError!,
                                  style: const TextStyle(
                                      color: Colors.redAccent, fontSize: 12)),
                              TextButton(
                                onPressed: () => asigProv
                                    .fetchAsignaturasForDropdown(force: true),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          );
                        }
                        final asignaturas = asigProv.dropdownItems;
                        final valorValido =
                            asignaturas.any((a) => a.id == _asignaturaId);
                        return _dropdown<int>(
                          value: valorValido ? _asignaturaId : null,
                          hint: 'Selecciona una asignatura',
                          items: {
                            for (final a in asignaturas)
                              a.id: '${a.moduloNombre} — ${a.nombre}',
                          },
                          onChanged: (v) =>
                              setState(() => _asignaturaId = v),
                        );
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models/asignatura_model.dart';
import '../providers/asignatura_provider.dart';
import '../../competencia_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../programa/presentation/providers/modulo_provider.dart';

class AsignaturaFormScreen extends StatefulWidget {
  final AsignaturaItem? existing;

  const AsignaturaFormScreen({super.key, this.existing});

  @override
  State<AsignaturaFormScreen> createState() => _AsignaturaFormScreenState();
}

class _AsignaturaFormScreenState extends State<AsignaturaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _horasLectivas;
  late final TextEditingController _horasPracticas;
  late final TextEditingController _orden;
  String  _tipo   = 'TEORICO_PRACTICA';
  String  _estado = 'ACTIVA';
  int?    _moduloId;

  // Casilla "Teórica": si está marcada, la asignatura es solo TEORICA y no
  // tiene horas prácticas (se envían en 0 automáticamente). Si no está
  // marcada, es TEORICO_PRACTICA y las horas prácticas son editables.
  bool get _esTeorica => _tipo == 'TEORICA';

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nombre         = TextEditingController(text: e?.nombre ?? '');
    _descripcion    = TextEditingController(text: e?.descripcion ?? '');
    _horasLectivas  = TextEditingController(
        text: e != null ? '${e.horasLectivas}' : '');
    _horasPracticas = TextEditingController(
        text: e != null ? '${e.horasPracticas}' : '');
    _orden          = TextEditingController(
        text: e != null ? '${e.orden}' : '');
    if (e != null) {
      _tipo     = e.tipo;
      _estado   = e.estado;
      _moduloId = e.moduloId;
    }

    // Trae el listado de módulos para el selector (solo hace falta al crear).
    if (!_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ModuloProvider>().fetchModulosForDropdown();
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nombre, _descripcion, _horasLectivas, _horasPracticas, _orden
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTeoricaChanged(bool checked) {
    setState(() {
      if (checked) {
        _tipo = 'TEORICA';
        _horasPracticas.text = '0';
      } else {
        _tipo = 'TEORICO_PRACTICA';
        if (_horasPracticas.text.trim() == '0') _horasPracticas.text = '';
      }
    });
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEdit && _moduloId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un módulo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    final prov = context.read<AsignaturaProvider>();
    prov.clearSaveError();

    final payload = {
      if (!_isEdit) 'modulo': _moduloId,
      'nombre':          _nombre.text.trim(),
      'descripcion':     _descripcion.text.trim(),
      'tipo':            _tipo,
      'horas_lectivas':  int.parse(_horasLectivas.text.trim()),
      // Si es teórica, siempre 0 sin importar lo que muestre el campo.
      'horas_practicas':
          _esTeorica ? 0 : int.parse(_horasPracticas.text.trim()),
      'orden':           int.parse(_orden.text.trim()),
      'estado':          _estado,
    };

    final result = _isEdit
        ? await prov.update(widget.existing!.id, payload)
        : await prov.create(payload);

    if (!mounted) return;
    if (result != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEdit ? 'Asignatura actualizada.' : 'Asignatura creada.'),
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
        title: Text(_isEdit ? 'Editar asignatura' : 'Nueva asignatura',
            style: const TextStyle(
                color: CT.textPrimary, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: CT.primary),
        elevation: 0,
      ),
      body: Consumer<AsignaturaProvider>(
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
                    _label('Módulo *'),
                    Consumer<ModuloProvider>(
                      builder: (context, moduloProv, _) {
                        if (moduloProv.isLoadingDropdown) {
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
                        if (moduloProv.dropdownError != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(moduloProv.dropdownError!,
                                  style: const TextStyle(
                                      color: Colors.redAccent, fontSize: 12)),
                              TextButton(
                                onPressed: () => moduloProv
                                    .fetchModulosForDropdown(force: true),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          );
                        }
                        final modulos = moduloProv.dropdownItems;
                        // Si el módulo seleccionado (ej. al editar/precargar)
                        // no está en la lista activa, igual se conserva.
                        final valorValido =
                            modulos.any((m) => m.id == _moduloId);
                        return _dropdown<int>(
                          value: valorValido ? _moduloId : null,
                          hint: 'Selecciona un módulo',
                          items: {
                            for (final m in modulos) m.id: m.nombre,
                          },
                          onChanged: (v) => setState(() => _moduloId = v),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  _label('Nombre *'),
                  _textField(
                    controller: _nombre,
                    hint: 'Ej: Introducción a la programación',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  _label('Descripción'),
                  _textField(
                      controller: _descripcion,
                      hint: 'Descripción de la asignatura…',
                      maxLines: 3),
                  const SizedBox(height: 16),
                  // Casilla "Teórica": si se marca, la asignatura es solo
                  // teórica y no tiene horas prácticas (0 automático).
                  // Si se desmarca, es teórico-práctica y las horas
                  // prácticas vuelven a ser editables.
                  InkWell(
                    onTap: () => _onTeoricaChanged(!_esTeorica),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _esTeorica,
                            activeColor: CT.primary,
                            onChanged: (v) => _onTeoricaChanged(v ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              'Es teórica (sin horas prácticas)',
                              style: TextStyle(
                                  color: CT.textPrimary, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Horas lectivas *'),
                            _textField(
                              controller: _horasLectivas,
                              hint: '0',
                              inputType: TextInputType.number,
                              validator: (v) {
                                final n = int.tryParse(v?.trim() ?? '');
                                if (n == null) return 'Número requerido';
                                if (n <= 0) return 'Mayor a 0';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Horas prácticas *'),
                            _textField(
                              controller: _horasPracticas,
                              hint: '0',
                              enabled: !_esTeorica,
                              inputType: TextInputType.number,
                              validator: (v) {
                                if (_esTeorica) return null;
                                final n = int.tryParse(v?.trim() ?? '');
                                if (n == null) return 'Número requerido';
                                if (n <= 0) return 'Mayor a 0';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _label('Orden en el módulo *'),
                  _textField(
                    controller: _orden,
                    hint: 'Ej: 1',
                    inputType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null) return 'Número requerido';
                      if (n < 1) return 'Mínimo 1';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _label('Estado'),
                  _dropdown(
                    value: _estado,
                    items: const {'ACTIVA': 'Activa', 'INACTIVA': 'Inactiva'},
                    onChanged: (v) => setState(() => _estado = v!),
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
                                  : 'Crear asignatura',
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

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool enabled = true,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: inputType,
      inputFormatters: inputType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      validator: validator,
      style: TextStyle(
          color: enabled ? CT.textPrimary : CT.textSec, fontSize: 14),
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

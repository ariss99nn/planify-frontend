// lib/features/programa/presentation/widgets/views/modulo_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/modulo_entity.dart';
import '../../providers/modulo_provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/common/state_views.dart';

class ModuloFormView extends StatefulWidget {
  final int versionId;
  final int versionNumero;
  final int? moduloId; // null = crear

  const ModuloFormView({
    super.key,
    required this.versionId,
    required this.versionNumero,
    this.moduloId,
  });

  bool get isEditing => moduloId != null;

  @override
  State<ModuloFormView> createState() => _ModuloFormViewState();
}

class _ModuloFormViewState extends State<ModuloFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ordenController = TextEditingController();
  final _horasLectivasController = TextEditingController();
  final _horasPracticasController = TextEditingController();
  ModuloEstado _estado = ModuloEstado.activo;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ModuloProvider>().fetchDetail(widget.moduloId!);
      });
    } else {
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ordenController.dispose();
    _horasLectivasController.dispose();
    _horasPracticasController.dispose();
    super.dispose();
  }

  void _populateFrom(ModuloEntity m) {
    _nombreController.text = m.nombre;
    _descripcionController.text = m.descripcion;
    _ordenController.text = '${m.orden}';
    _horasLectivasController.text = '${m.horasLectivas}';
    _horasPracticasController.text = '${m.horasPracticas}';
    _estado = m.estado;
    _initialized = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ModuloProvider>();
    final result = widget.isEditing
        ? await provider.update(
            id: widget.moduloId!,
            nombre: _nombreController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            orden: int.parse(_ordenController.text.trim()),
            horasLectivas: int.parse(_horasLectivasController.text.trim()),
            horasPracticas: int.parse(_horasPracticasController.text.trim()),
            estado: _estado,
          )
        : await provider.create(
            versionId: widget.versionId,
            nombre: _nombreController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            orden: int.parse(_ordenController.text.trim()),
            horasLectivas: int.parse(_horasLectivasController.text.trim()),
            horasPracticas: int.parse(_horasPracticasController.text.trim()),
            estado: _estado,
          );

    if (result != null && mounted) Navigator.pop(context, result);
  }

  String? _validatePositivo(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null || n <= 0) return 'Debe ser mayor a 0.';
    return null;
  }

  String? _validateNoNegativo(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null || n < 0) return 'No puede ser negativo.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ModuloProvider>();

    if (widget.isEditing && !_initialized) {
      if (provider.isLoadingDetail) {
        return Scaffold(
          appBar: AppBar(title: const Text('Editar módulo')),
          body: const LoadingView(),
        );
      }
      if (provider.detailError != null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Editar módulo')),
          body: ErrorRetryView(
            message: provider.detailError!,
            onRetry: () => provider.fetchDetail(widget.moduloId!),
          ),
        );
      }
      if (provider.selected != null && provider.selected!.id == widget.moduloId) {
        _populateFrom(provider.selected!);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar módulo' : 'Nuevo módulo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InlineFormError(message: provider.saveError),
                Text(
                  'Versión ${widget.versionNumero}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del módulo'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ordenController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Orden',
                    helperText: 'Posición del módulo dentro de la versión.',
                  ),
                  validator: _validatePositivo,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _horasLectivasController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Horas lectivas'),
                        validator: _validatePositivo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _horasPracticasController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Horas prácticas'),
                        validator: _validateNoNegativo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ModuloEstado>(
                  value: _estado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: ModuloEstado.values
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _estado = v!),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isSaving ? null : _submit,
                    child: provider.isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(widget.isEditing
                            ? 'Guardar cambios'
                            : 'Crear módulo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

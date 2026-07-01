// lib/features/programa/presentation/widgets/views/version_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/date_format.dart';
import '../../../domain/entities/version_programa_entity.dart';
import '../../providers/version_provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/common/state_views.dart';

class VersionFormView extends StatefulWidget {
  final int programaId;
  final String programaNombre;
  final int? versionId; // null = crear

  const VersionFormView({
    super.key,
    required this.programaId,
    required this.programaNombre,
    this.versionId,
  });

  bool get isEditing => versionId != null;

  @override
  State<VersionFormView> createState() => _VersionFormViewState();
}

class _VersionFormViewState extends State<VersionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _vigente = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VersionProvider>().fetchDetail(widget.versionId!);
      });
    } else {
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _populateFrom(VersionEntity v) {
    _numeroController.text = '${v.numero}';
    _descripcionController.text = v.descripcion;
    _fechaInicio = v.fechaInicio;
    _fechaFin = v.fechaFin;
    _vigente = v.vigente;
    _initialized = true;
  }

  Future<void> _pickDate({required bool isInicio}) async {
    final initial = isInicio
        ? (_fechaInicio ?? DateTime.now())
        : (_fechaFin ?? _fechaInicio ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: AppTheme.dark, child: child!),
    );
    if (picked == null) return;
    setState(() {
      if (isInicio) {
        _fechaInicio = picked;
      } else {
        _fechaFin = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de inicio.')),
      );
      return;
    }
    if (_fechaFin != null && !_fechaFin!.isAfter(_fechaInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de fin debe ser posterior a la de inicio.')),
      );
      return;
    }

    final provider = context.read<VersionProvider>();
    final result = widget.isEditing
        ? await provider.update(
            id: widget.versionId!,
            descripcion: _descripcionController.text.trim(),
            vigente: _vigente,
            fechaInicio: _fechaInicio,
            fechaFin: _fechaFin,
          )
        : await provider.create(
            programaId: widget.programaId,
            numero: int.parse(_numeroController.text.trim()),
            descripcion: _descripcionController.text.trim(),
            vigente: _vigente,
            fechaInicio: _fechaInicio!,
            fechaFin: _fechaFin,
          );

    if (result != null && mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VersionProvider>();

    if (widget.isEditing && !_initialized) {
      if (provider.isLoadingDetail) {
        return Scaffold(
          appBar: AppBar(title: const Text('Editar versión')),
          body: const LoadingView(),
        );
      }
      if (provider.detailError != null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Editar versión')),
          body: ErrorRetryView(
            message: provider.detailError!,
            onRetry: () => provider.fetchDetail(widget.versionId!),
          ),
        );
      }
      if (provider.selected != null && provider.selected!.id == widget.versionId) {
        _populateFrom(provider.selected!);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Editar versión' : 'Nueva versión')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InlineFormError(message: provider.saveError),
                Text('Programa', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(widget.programaNombre, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _numeroController,
                  enabled: !widget.isEditing,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número de versión',
                    helperText: 'Ej: 1, 2. No se puede modificar luego.',
                  ),
                  validator: (value) {
                    final n = int.tryParse(value?.trim() ?? '');
                    if (n == null || n <= 0) return 'Ingresa un número válido.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _pickDate(isInicio: true),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(_fechaInicio != null
                      ? formatDate(_fechaInicio)
                      : 'Seleccionar fecha de inicio'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isInicio: false),
                        icon: const Icon(Icons.event_outlined, size: 18),
                        label: Text(_fechaFin != null
                            ? formatDate(_fechaFin)
                            : 'Seleccionar fecha de fin (opcional)'),
                      ),
                    ),
                    if (_fechaFin != null)
                      IconButton(
                        onPressed: () => setState(() => _fechaFin = null),
                        icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _vigente,
                  activeColor: AppTheme.primary,
                  title: const Text('Versión vigente'),
                  subtitle: const Text(
                    'Al activarla, las demás versiones de este programa dejarán de ser vigentes.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  onChanged: (value) => setState(() => _vigente = value),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: provider.isSaving ? null : _submit,
                  child: provider.isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(widget.isEditing ? 'Guardar cambios' : 'Crear versión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

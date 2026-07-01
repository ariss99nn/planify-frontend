// lib/features/aulas/presentation/widgets/views/aula_form_view.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../core/api/api_service.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entities/aula_entity.dart';
import '../../../domain/entities/equipamiento_entity.dart';
import '../../providers/aula_provider.dart';

class AulaFormView extends StatefulWidget {
  final AulaEntity? aula;
  const AulaFormView({super.key, this.aula});

  @override
  State<AulaFormView> createState() => _AulaFormViewState();
}

class _AulaFormViewState extends State<AulaFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codigoCtrl;
  late final TextEditingController _capacidadCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _pisoCtrl;

  String?    _tipoAula;
  String?    _estado;
  int?       _bloqueId;
  XFile?     _imagen;
  Uint8List? _imagenBytes;
  late List<int> _equipamientoIds;

  bool get _isEdit => widget.aula != null;

  static const _tipos = [
    ('LAB', 'Laboratorio'),
    ('TEO', 'Teórica'),
    ('SIS', 'Sistemas de Información'),
    ('OTR', 'Otro'),
  ];
  static const _estados = [
    ('ACT',  'Activa'),
    ('MANT', 'Mantenimiento'),
    ('INAC', 'Inactiva'),
  ];

  @override
  void initState() {
    super.initState();
    final a          = widget.aula;
    _codigoCtrl      = TextEditingController(text: a?.codigoAula ?? '');
    _capacidadCtrl   = TextEditingController(text: a != null ? a.capacidad.toString() : '');
    _descripcionCtrl = TextEditingController(text: a?.descripcion ?? '');
    _pisoCtrl        = TextEditingController(text: a != null ? a.piso.toString() : '');
    _tipoAula        = a?.tipoAula;
    _estado          = a?.estado ?? 'ACT';
    _bloqueId        = a?.bloque.id;
    _equipamientoIds = a?.equipamiento.map((e) => e.id).toList() ?? [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AulaProvider>();
      provider.resetForm();
      provider.fetchBloques();
      provider.fetchEquipamientos();
    });
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _capacidadCtrl.dispose();
    _descripcionCtrl.dispose();
    _pisoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() { _imagen = picked; _imagenBytes = bytes; });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final fields = <String, String>{
      if (!_isEdit) 'codigo_aula': _codigoCtrl.text.trim(),
      'capacidad':   _capacidadCtrl.text.trim(),
      'tipo_aula':   _tipoAula!,
      'estado':      _estado!,
      'bloque':      _bloqueId!.toString(),
      'piso':        _pisoCtrl.text.trim(),
      'descripcion': _descripcionCtrl.text.trim(),
    };

    final provider = context.read<AulaProvider>();
    final ok = _isEdit
        ? await provider.updateAula(widget.aula!.id, fields, imagen: _imagen, equipamientoIds: _equipamientoIds)
        : await provider.createAula(fields, imagen: _imagen, equipamientoIds: _equipamientoIds);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      CyberSnackbar.success(context, _isEdit ? 'Aula actualizada.' : 'Aula creada.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<AulaProvider>();
    final isLoading = provider.formStatus == AulaStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar aula' : 'Nueva aula'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (provider.formStatus == AulaStatus.error)
                CyberErrorBanner(message: provider.formError),
              if (!_isEdit) ...[
                const CyberFieldLabel('Código del aula', required: true),
                TextFormField(
                  controller: _codigoCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(hintText: 'Ej. A-101'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
              ],
              const CyberFieldLabel('Capacidad (personas)', required: true),
              TextFormField(
                controller: _capacidadCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: 'Ej. 30'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Tipo de aula', required: true),
              DropdownButtonFormField<String>(
                value: _tipoAula,
                decoration: const InputDecoration(hintText: 'Selecciona un tipo'),
                items: _tipos.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
                onChanged: (v) => setState(() => _tipoAula = v),
                validator: (v) => v == null ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Estado', required: true),
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(hintText: 'Selecciona el estado'),
                items: _estados.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
                onChanged: (v) => setState(() => _estado = v),
                validator: (v) => v == null ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Bloque', required: true),
              if (provider.bloquesStatus == AulaStatus.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                )
              else
                DropdownButtonFormField<int>(
                  value: _bloqueId,
                  decoration: const InputDecoration(hintText: 'Selecciona un bloque'),
                  items: provider.bloques.map((b) => DropdownMenuItem(value: b.id, child: Text(b.nombre))).toList(),
                  onChanged: (v) => setState(() => _bloqueId = v),
                  validator: (v) => v == null ? 'Campo requerido' : null,
                ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Piso', required: true),
              TextFormField(
                controller: _pisoCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: 'Ej. 2'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Equipamiento (opcional)'),
              const SizedBox(height: 8),
              _EquipamientoSelector(
                status: provider.equipamientosStatus,
                equipamientos: provider.equipamientos,
                selectedIds: _equipamientoIds,
                onToggle: (id, selected) {
                  setState(() {
                    if (selected) {
                      _equipamientoIds.add(id);
                    } else {
                      _equipamientoIds.remove(id);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Descripción (opcional)'),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Descripción del aula…'),
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Imagen (opcional)'),
              CyberImagePickerField(
                onTap: _pickImage,
                localBytes: _imagenBytes,
                networkUrl: widget.aula?.imagenUrl != null
                    ? ApiService.buildMediaUrl(widget.aula!.imagenUrl)
                    : null,
              ),
              const SizedBox(height: 28),
              CyberButton(
                label: _isEdit ? 'Guardar cambios' : 'Crear aula',
                loading: isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipamientoSelector extends StatelessWidget {
  final AulaStatus status;
  final List<EquipamientoResumenEntity> equipamientos;
  final List<int> selectedIds;
  final void Function(int id, bool selected) onToggle;

  const _EquipamientoSelector({
    required this.status,
    required this.equipamientos,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (status == AulaStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    if (status == AulaStatus.error) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text('No se pudo cargar el equipamiento.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      );
    }
    if (equipamientos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Text('Sin equipamiento disponible.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Wrap(
        spacing: 8, runSpacing: 6,
        children: equipamientos.map((e) {
          final isSelected = selectedIds.contains(e.id);
          return FilterChip(
            label: Text(e.nombre),
            selected: isSelected,
            showCheckmark: true,
            checkmarkColor: Colors.white,
            selectedColor: AppTheme.primary,
            labelStyle: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            backgroundColor: AppTheme.surface,
            side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
            onSelected: (val) => onToggle(e.id, val),
          );
        }).toList(),
      ),
    );
  }
}
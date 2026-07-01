// lib/features/aulas/presentation/widgets/views/equipamiento_form_view.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../core/api/api_service.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entities/equipamiento_entity.dart';
import '../../providers/equipamiento_provider.dart';

class EquipamientoFormView extends StatefulWidget {
  final EquipamientoDetalleEntity? equipamiento;
  const EquipamientoFormView({super.key, this.equipamiento});

  @override
  State<EquipamientoFormView> createState() => _EquipamientoFormViewState();
}

class _EquipamientoFormViewState extends State<EquipamientoFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _cantidadCtrl;
  late final TextEditingController _serieCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _fechaCtrl;

  String?    _estado;
  XFile?     _imagen;
  Uint8List? _imagenBytes;

  bool get _isEdit => widget.equipamiento != null;

  static const _estados = [
    ('FUNC', 'Funcional'),
    ('DAN',  'Dañado'),
    ('MANT', 'En mantenimiento'),
  ];

  @override
  void initState() {
    super.initState();
    final e          = widget.equipamiento;
    _nombreCtrl      = TextEditingController(text: e?.nombre ?? '');
    _cantidadCtrl    = TextEditingController(text: e != null ? e.cantidad.toString() : '1');
    _serieCtrl       = TextEditingController(text: e?.numeroSerie ?? '');
    _descripcionCtrl = TextEditingController(text: e?.descripcion ?? '');
    _fechaCtrl       = TextEditingController(text: e?.fechaAdquisicion ?? '');
    _estado          = e?.estado ?? 'FUNC';

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<EquipamientoProvider>().resetForm());
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    _serieCtrl.dispose();
    _descripcionCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() { _imagen = picked; _imagenBytes = bytes; });
  }

  Future<void> _pickDate() async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppTheme.primary, onPrimary: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _fechaCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final fields = <String, String>{
      'nombre':      _nombreCtrl.text.trim(),
      'cantidad':    _cantidadCtrl.text.trim(),
      'estado':      _estado!,
      'descripcion': _descripcionCtrl.text.trim(),
      if (_serieCtrl.text.trim().isNotEmpty)      'numero_serie':      _serieCtrl.text.trim(),
      if (_fechaCtrl.text.trim().isNotEmpty) 'fecha_adquisicion': _fechaCtrl.text.trim(),
    };

    final provider = context.read<EquipamientoProvider>();
    final ok = _isEdit
        ? await provider.updateEquipamiento(widget.equipamiento!.id, fields, imagen: _imagen)
        : await provider.createEquipamiento(fields, imagen: _imagen);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      CyberSnackbar.success(context, _isEdit ? 'Equipamiento actualizado.' : 'Equipamiento creado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<EquipamientoProvider>();
    final isLoading = provider.formStatus == EquipamientoStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar equipamiento' : 'Nuevo equipamiento'),
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
              if (provider.formStatus == EquipamientoStatus.error)
                CyberErrorBanner(message: provider.formError),
              const CyberFieldLabel('Nombre', required: true),
              TextFormField(
                controller: _nombreCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Ej. Proyector Epson'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Cantidad', required: true),
              TextFormField(
                controller: _cantidadCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: 'Ej. 5'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
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
              const CyberFieldLabel('Número de serie (opcional)'),
              TextFormField(controller: _serieCtrl, decoration: const InputDecoration(hintText: 'Ej. SN-12345')),
              const SizedBox(height: 16),
              const CyberFieldLabel('Fecha de adquisición (opcional)'),
              TextFormField(
                controller: _fechaCtrl,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Descripción (opcional)'),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Descripción del equipamiento…'),
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Imagen (opcional)'),
              CyberImagePickerField(
                onTap: _pickImage,
                height: 160,
                localBytes: _imagenBytes,
                networkUrl: widget.equipamiento?.imagenUrl != null
                    ? ApiService.buildMediaUrl(widget.equipamiento!.imagenUrl)
                    : null,
              ),
              const SizedBox(height: 28),
              CyberButton(
                label: _isEdit ? 'Guardar cambios' : 'Crear equipamiento',
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
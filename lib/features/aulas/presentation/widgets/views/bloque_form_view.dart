// lib/features/aulas/presentation/widgets/views/bloque_form_view.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../core/api/api_service.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entities/bloque_entity.dart';
import '../../providers/bloque_provider.dart';

class BloqueFormView extends StatefulWidget {
  final BloqueDetalleEntity? bloque;
  const BloqueFormView({super.key, this.bloque});

  @override
  State<BloqueFormView> createState() => _BloqueFormViewState();
}

class _BloqueFormViewState extends State<BloqueFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _pisosCtrl;
  late final TextEditingController _capacidadCtrl;
  late final TextEditingController _descripcionCtrl;

  String?    _estado;
  XFile?     _imagen;
  Uint8List? _imagenBytes;

  bool get _isEdit => widget.bloque != null;

  static const _estados = [
    ('ACT',  'Activo'),
    ('MANT', 'Mantenimiento'),
    ('INAC', 'Inactivo'),
  ];

  @override
  void initState() {
    super.initState();
    final b          = widget.bloque;
    _nombreCtrl      = TextEditingController(text: b?.nombre ?? '');
    _pisosCtrl       = TextEditingController(text: b != null ? b.pisos.toString() : '');
    _capacidadCtrl   = TextEditingController(text: b != null ? b.capacidadMaxima.toString() : '');
    _descripcionCtrl = TextEditingController(text: b?.descripcion ?? '');
    _estado          = b?.estado ?? 'ACT';

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<BloqueProvider>().resetForm());
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _pisosCtrl.dispose();
    _capacidadCtrl.dispose();
    _descripcionCtrl.dispose();
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
      'nombre':           _nombreCtrl.text.trim(),
      'pisos':            _pisosCtrl.text.trim(),
      'capacidad_maxima': _capacidadCtrl.text.trim(),
      'estado':           _estado!,
      'descripcion':      _descripcionCtrl.text.trim(),
    };

    final provider = context.read<BloqueProvider>();
    final ok = _isEdit
        ? await provider.updateBloque(widget.bloque!.id, fields, imagen: _imagen)
        : await provider.createBloque(fields, imagen: _imagen);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      CyberSnackbar.success(context, _isEdit ? 'Bloque actualizado.' : 'Bloque creado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<BloqueProvider>();
    final isLoading = provider.formStatus == BloqueStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar bloque' : 'Nuevo bloque'),
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
              if (provider.formStatus == BloqueStatus.error)
                CyberErrorBanner(message: provider.formError),
              const CyberFieldLabel('Nombre del bloque', required: true),
              TextFormField(
                controller: _nombreCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Ej. Bloque A'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Número de pisos', required: true),
              TextFormField(
                controller: _pisosCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: 'Ej. 3'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Capacidad máxima (personas)', required: true),
              TextFormField(
                controller: _capacidadCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: 'Ej. 200'),
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
              const CyberFieldLabel('Descripción (opcional)'),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Descripción del bloque…'),
              ),
              const SizedBox(height: 16),
              const CyberFieldLabel('Imagen (opcional)'),
              CyberImagePickerField(
                onTap: _pickImage,
                height: 160,
                localBytes: _imagenBytes,
                networkUrl: widget.bloque?.imagenUrl != null
                    ? ApiService.buildMediaUrl(widget.bloque!.imagenUrl)
                    : null,
              ),
              const SizedBox(height: 28),
              CyberButton(
                label: _isEdit ? 'Guardar cambios' : 'Crear bloque',
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
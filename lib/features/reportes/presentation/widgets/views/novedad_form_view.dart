import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/theme.dart';
import '../../../domain/entities/novedad_entity.dart';
import '../../providers/novedad_provider.dart';

class NovedadFormView extends StatefulWidget {
  const NovedadFormView({
    super.key,
    required this.provider,
    required this.onGuardado,
  });

  final NovedadProvider provider;
  final VoidCallback onGuardado;

  @override
  State<NovedadFormView> createState() => _NovedadFormViewState();
}

class _NovedadFormViewState extends State<NovedadFormView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  NovedadTipo _tipo = NovedadTipo.otra;
  NovedadPrioridad _prioridad = NovedadPrioridad.media;
  DateTime? _fechaExpiracion;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaExpiracion() async {
    final ahora = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: ahora.add(const Duration(days: 7)),
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 365)),
    );
    if (seleccionada != null) {
      setState(() {
        _fechaExpiracion = DateTime(
          seleccionada.year,
          seleccionada.month,
          seleccionada.day,
          23,
          59,
          59,
        );
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final input = NovedadCreateInput(
      tipo: _tipo,
      prioridad: _prioridad,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fechaExpiracion: _fechaExpiracion,
    );

    final ok = await widget.provider.crear(input);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Novedad creada.')),
      );
      widget.onGuardado();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              widget.provider.error ?? 'No se pudo crear la novedad.'),
          backgroundColor: Colors.redAccent.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANTE — corrección de bug: igual que en NovedadesListView, este
    // widget ya se embebe dentro del Scaffold/AppBar("Nueva novedad") de
    // ReportesGestionScreen. Envolverlo en un Scaffold propio duplicaba la
    // barra de título. Ahora solo se devuelve el contenido del formulario.
    return AnimatedBuilder(
      animation: widget.provider,
      builder: (context, _) {
        final enviando = widget.provider.enviando;
        return SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                DropdownButtonFormField<NovedadTipo>(
                  initialValue: _tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: NovedadTipo.values
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged:
                      enviando ? null : (v) => setState(() => _tipo = v!),
                ),
                const SizedBox(height: 16),
                Text(
                  'Prioridad',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: NovedadPrioridad.values.map((p) {
                    final seleccionada = p == _prioridad;
                    return ChoiceChip(
                      label: Text(p.label),
                      selected: seleccionada,
                      onSelected: enviando
                          ? null
                          : (_) => setState(() => _prioridad = p),
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceLight,
                      labelStyle: TextStyle(
                        color:
                            seleccionada ? Colors.black : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _tituloController,
                  enabled: !enviando,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Resumen corto visible en el listado',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El título es obligatorio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descripcionController,
                  enabled: !enviando,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Detalle completo de la novedad',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'La descripción es obligatoria.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fechaExpiracion == null
                            ? 'Sin fecha de expiración'
                            : 'Expira: ${DateFormat('d MMM yyyy', 'es').format(_fechaExpiracion!)}',
                        style:
                            const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                    TextButton.icon(
                      onPressed:
                          enviando ? null : _seleccionarFechaExpiracion,
                      icon: const Icon(Icons.event_rounded, size: 18),
                      label: Text(
                          _fechaExpiracion == null ? 'Definir' : 'Cambiar'),
                    ),
                    if (_fechaExpiracion != null)
                      IconButton(
                        onPressed: enviando
                            ? null
                            : () => setState(() => _fechaExpiracion = null),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        tooltip: 'Quitar fecha',
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: enviando ? null : _guardar,
                  child: enviando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('Crear novedad'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

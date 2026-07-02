// lib/features/programa/presentation/widgets/views/programa_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/programa_entity.dart';
import '../../providers/programa_provider.dart';
import '../../../../../core/widgets/common/state_views.dart';

class ProgramaFormView extends StatefulWidget {
  final int? programaId; // null = crear

  const ProgramaFormView({super.key, this.programaId});

  bool get isEditing => programaId != null;

  @override
  State<ProgramaFormView> createState() => _ProgramaFormViewState();
}

class _ProgramaFormViewState extends State<ProgramaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _horasLectivasController = TextEditingController();
  final _horasPracticasController = TextEditingController();
  final _trimestresTotalesController = TextEditingController(text: '6');
  final _trimestresCadenaController = TextEditingController();

  ProgramaNivel _nivel = ProgramaNivel.tecnico;
  ProgramaEstado _estado = ProgramaEstado.activo;
  ProgramaTipoFormacion _tipoFormacion = ProgramaTipoFormacion.porOferta;
  bool _initialized = false;

  /// true mientras el usuario no haya tocado horas/trimestres a mano;
  /// controla si al cambiar de nivel se sobrescriben esos campos con el
  /// preset o se respeta lo que ya escribió.
  bool _horasEditadasManualmente = false;
  bool _trimestresEditadosManualmente = false;

  bool get _esCursoCorto => _nivel == ProgramaNivel.cursoCorto;
  bool get _permiteCadenaFormacion =>
      ProgramaPreset.byNivel[_nivel]?.permiteCadenaFormacion ?? false;

  /// Aplica los valores sugeridos del nivel elegido. Solo pisa los campos
  /// que el usuario no ha editado a mano, para no ser invasivo si ya venía
  /// ajustando algo.
  void _aplicarPreset(ProgramaNivel nivel) {
    final preset = ProgramaPreset.byNivel[nivel];
    if (preset == null) return;

    if (!_horasEditadasManualmente) {
      if (preset.horasLectivas != null) {
        _horasLectivasController.text = '${preset.horasLectivas}';
      } else if (preset.horasLectivasMin != null && preset.horasLectivasMax != null) {
        // Curso corto: sugerimos el punto medio del rango permitido.
        final medio = ((preset.horasLectivasMin! + preset.horasLectivasMax!) / 2).round();
        _horasLectivasController.text = '$medio';
      }
      if (preset.horasPracticas != null) {
        _horasPracticasController.text = '${preset.horasPracticas}';
      }
    }
    // Para Curso Corto el campo de trimestres queda oculto en el
    // formulario (no aplica), así que su valor siempre se fija al preset
    // para no arrastrar un número obsoleto cuando el nivel cambia.
    if (!_trimestresEditadosManualmente || nivel == ProgramaNivel.cursoCorto) {
      _trimestresTotalesController.text = '${preset.trimestresTotales}';
    }

    // La cadena de formación solo aplica para Tecnólogo.
    if (!preset.permiteCadenaFormacion &&
        _tipoFormacion == ProgramaTipoFormacion.cadenaFormacion) {
      _tipoFormacion = ProgramaTipoFormacion.porOferta;
      _trimestresCadenaController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProgramaProvider>().fetchDetail(widget.programaId!);
      });
    } else {
      _initialized = true;
      // Precarga las sugerencias del nivel por defecto (Técnico).
      _aplicarPreset(_nivel);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _horasLectivasController.dispose();
    _horasPracticasController.dispose();
    _trimestresTotalesController.dispose();
    _trimestresCadenaController.dispose();
    super.dispose();
  }

  void _populateFrom(ProgramaEntity p) {
    _nombreController.text = p.nombre;
    _descripcionController.text = p.descripcion;
    _horasLectivasController.text = '${p.horasLectivas}';
    _horasPracticasController.text = '${p.horasPracticas}';
    _trimestresTotalesController.text = '${p.trimestresTotales}';
    _trimestresCadenaController.text = p.trimestresCadena?.toString() ?? '';
    _nivel = p.nivel;
    _estado = p.estado;
    _tipoFormacion = p.tipoFormacion;
    _initialized = true;
    // Es un programa existente: no pisar sus horas/trimestres reales con
    // el preset si el usuario solo cambia otro campo.
    _horasEditadasManualmente = true;
    _trimestresEditadosManualmente = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProgramaProvider>();
    final trimestresCadena = _tipoFormacion == ProgramaTipoFormacion.cadenaFormacion
        ? int.tryParse(_trimestresCadenaController.text.trim())
        : null;

    final result = widget.isEditing
        ? await provider.update(
            id: widget.programaId!,
            nombre: _nombreController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            nivel: _nivel,
            horasLectivas: int.parse(_horasLectivasController.text.trim()),
            horasPracticas: int.parse(_horasPracticasController.text.trim()),
            estado: _estado,
            trimestresTotales: int.parse(_trimestresTotalesController.text.trim()),
            tipoFormacion: _tipoFormacion,
            trimestresCadena: trimestresCadena,
          )
        : await provider.create(
            nombre: _nombreController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            nivel: _nivel,
            horasLectivas: int.parse(_horasLectivasController.text.trim()),
            horasPracticas: int.parse(_horasPracticasController.text.trim()),
            estado: _estado,
            trimestresTotales: int.parse(_trimestresTotalesController.text.trim()),
            tipoFormacion: _tipoFormacion,
            trimestresCadena: trimestresCadena,
          );

    if (result != null && mounted) Navigator.pop(context, result);
  }

  String? _validateHorasLectivas(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null || n <= 0) return 'Debe ser mayor a 0.';
    if (_esCursoCorto) {
      final preset = ProgramaPreset.byNivel[ProgramaNivel.cursoCorto]!;
      final min = preset.horasLectivasMin!;
      final max = preset.horasLectivasMax!;
      if (n < min || n > max) return 'Un curso corto debe tener entre $min y $max horas.';
    }
    return null;
  }

  String? _validateHorasPracticas(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null || n < 0) return 'No puede ser negativo.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgramaProvider>();

    if (widget.isEditing && !_initialized) {
      if (provider.isLoadingDetail) {
        return Scaffold(
          appBar: AppBar(title: const Text('Editar programa')),
          body: const LoadingView(),
        );
      }
      if (provider.detailError != null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Editar programa')),
          body: ErrorRetryView(
            message: provider.detailError!,
            onRetry: () => provider.fetchDetail(widget.programaId!),
          ),
        );
      }
      if (provider.selected != null && provider.selected!.id == widget.programaId) {
        _populateFrom(provider.selected!);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar programa' : 'Nuevo programa'),
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
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProgramaNivel>(
                  value: _nivel,
                  decoration: const InputDecoration(labelText: 'Nivel'),
                  items: ProgramaNivel.values
                      .map((n) => DropdownMenuItem(value: n, child: Text(n.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _nivel = v;
                      _aplicarPreset(v);
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    ProgramaPreset.byNivel[_nivel]?.descripcion ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProgramaEstado>(
                  value: _estado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: ProgramaEstado.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _estado = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _horasLectivasController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Horas lectivas',
                          helperText: _esCursoCorto ? 'Entre 40 y 80 horas.' : null,
                        ),
                        onChanged: (_) => _horasEditadasManualmente = true,
                        validator: _validateHorasLectivas,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _horasPracticasController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Horas prácticas'),
                        onChanged: (_) => _horasEditadasManualmente = true,
                        validator: _validateHorasPracticas,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Formación', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProgramaTipoFormacion>(
                  value: _tipoFormacion,
                  decoration: const InputDecoration(labelText: 'Tipo de formación'),
                  // La Cadena de Formación solo aplica a programas de
                  // Tecnólogo: se excluye del listado para otros niveles
                  // en vez de dejar que el usuario elija algo que el
                  // backend rechazará.
                  items: ProgramaTipoFormacion.values
                      .where((t) =>
                          t != ProgramaTipoFormacion.cadenaFormacion ||
                          _permiteCadenaFormacion)
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _tipoFormacion = v!;
                      if (_tipoFormacion != ProgramaTipoFormacion.cadenaFormacion) {
                        // El backend limpia este campo en Programa.clean();
                        // se vacía aquí también para que la UI sea consistente.
                        _trimestresCadenaController.clear();
                      }
                    });
                  },
                ),
                // Los trimestres solo tienen sentido para Técnico y
                // Tecnólogo; un curso corto se mide en horas.
                if (!_esCursoCorto) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _trimestresTotalesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Trimestres totales',
                      helperText: 'Total de trimestres antes de etapa productiva.',
                    ),
                    onChanged: (_) => _trimestresEditadosManualmente = true,
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n <= 0) return 'Ingresa un número válido.';
                      return null;
                    },
                  ),
                  if (_tipoFormacion == ProgramaTipoFormacion.cadenaFormacion) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _trimestresCadenaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Trimestres en etapa lectiva',
                        helperText: 'Debe ser menor al total de trimestres.',
                      ),
                      validator: (v) {
                        final n = int.tryParse(v?.trim() ?? '');
                        final total = int.tryParse(_trimestresTotalesController.text.trim());
                        if (n == null) return 'Requerido para cadena de formación.';
                        if (total != null && n >= total) {
                          return 'Debe ser menor que el total de trimestres.';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: provider.isSaving ? null : _submit,
                  child: provider.isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(widget.isEditing ? 'Guardar cambios' : 'Crear programa'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// lib/features/ficha/presentation/widgets/views/ficha_estudiante_add_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/friendly_feedback.dart';
import '../../../../auth/models/user_model.dart';
import '../../providers/ficha_provider.dart';
import '../../../data/models/ficha_request_model.dart';
import '../ficha_pickers.dart';

class FichaEstudianteAddView extends StatefulWidget {
  final int fichaId;
  const FichaEstudianteAddView({super.key, required this.fichaId});

  @override
  State<FichaEstudianteAddView> createState() => _FichaEstudianteAddViewState();
}

class _FichaEstudianteAddViewState extends State<FichaEstudianteAddView> {
  final _formKey = GlobalKey<FormState>();
  UserModel? _estudiante;

  Future<void> _pickEstudiante() async {
    final picked = await pickEstudiante(context);
    if (picked == null) return;
    setState(() => _estudiante = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_estudiante == null) {
      showFriendlySnack(context, 'Selecciona un estudiante.',
          tono: FeedbackTono.advertencia);
      return;
    }

    final request = AddEstudianteRequest(estudianteId: _estudiante!.id);

    final provider = context.read<FichaProvider>();
    final rel = await provider.addEstudiante(widget.fichaId, request);

    if (!mounted) return;

    if (rel != null) {
      Navigator.pop(context, true);
    } else {
      // FIX: antes se mostraba el texto crudo de ApiException(...) en un
      // banner rojo sólido de borde a borde. Ahora se limpia el mensaje
      // y se muestra en un tono más calmado, sin perder la información
      // (p. ej. "El estudiante ya tiene una ficha activa. Usa
      // reasignación para cambiarlo.").
      showFriendlyApiError(
        context,
        provider.mutationError,
        fallback: 'No se pudo agregar al estudiante.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<FichaProvider>().loadingMutation;
    final ficha = context.watch<FichaProvider>().fichaDetalle;
    // Si la ficha cargada corresponde a esta ficha, mostramos su modalidad;
    // el estudiante hereda automáticamente esa condición (es_cadena la
    // calcula el backend a partir de ficha.cadena_formacion).
    final esCadena = (ficha != null && ficha.id == widget.fichaId)
        ? ficha.cadenaFormacion
        : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: const Text('AGREGAR ESTUDIANTE',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 2)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Busca al estudiante por nombre o correo.',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FichaPickerTile(
                label: _estudiante != null
                    ? (_estudiante!.nombreCompleto.isNotEmpty
                        ? _estudiante!.nombreCompleto
                        : '${_estudiante!.nombre} ${_estudiante!.apellido}')
                    : 'Seleccionar estudiante',
                icon: Icons.person_search_outlined,
                tieneValor: _estudiante != null,
                onTap: _pickEstudiante,
              ),
              const SizedBox(height: 20),
              // La condición de "cadena de formación" ya no se pide al
              // usuario: se hereda automáticamente de la ficha para
              // mantener la coherencia ficha/estudiante.
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppTheme.border.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      esCadena == true
                          ? Icons.link
                          : Icons.link_off,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        esCadena == true
                            ? 'El estudiante ingresará como cadena de '
                              'formación (heredado de la ficha).'
                            : 'El estudiante ingresará sin cadena de '
                              'formación (heredado de la ficha).',
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Agregar estudiante',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

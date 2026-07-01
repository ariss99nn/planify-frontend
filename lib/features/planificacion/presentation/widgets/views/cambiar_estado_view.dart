// lib/features/planificacion/presentation/widgets/views/cambiar_estado_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/plan_trimestral_entity.dart';
import '../../providers/planificacion_provider.dart';
import '../planificacion_widgets.dart';

class CambiarEstadoView extends StatefulWidget {
  final PlanTrimestralDetalle plan;
  const CambiarEstadoView({super.key, required this.plan});

  @override
  State<CambiarEstadoView> createState() => _CambiarEstadoViewState();
}

class _CambiarEstadoViewState extends State<CambiarEstadoView> {
  EstadoPlan? _estadoSeleccionado;
  final _motivoController = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  bool get _requiereMotivo => _estadoSeleccionado == EstadoPlan.rechazado;

  Future<void> _confirmar() async {
    if (_estadoSeleccionado == null) return;

    if (_requiereMotivo && _motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('Indica el motivo del rechazo.'),
          backgroundColor: Colors.redAccent,
          behavior:        SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<PlanificacionProvider>();
    provider.clearError();

    final ok = await provider.cambiarEstado(
      _estadoSeleccionado!,
      motivoRechazo: _requiereMotivo ? _motivoController.text.trim() : null,
    );

    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final transiciones = widget.plan.estado.transicionesValidas;

    return Consumer<PlanificacionProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: const BoxDecoration(
            color:        Color(0xFF0C1E29),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize:       MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width:  40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Título
              Row(
                children: [
                  const Text(
                    'Cambiar estado',
                    style: TextStyle(
                      color:      Color(0xFFEAFBF4),
                      fontWeight: FontWeight.w700,
                      fontSize:   17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  EstadoChip(estado: widget.plan.estado, small: true),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Ficha ${widget.plan.fichaCodigo} · Trimestre ${widget.plan.trimestre}',
                style: TextStyle(
                  color:    Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),

              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ErrorBanner(message: provider.error!),
                ),

              if (transiciones.isEmpty)
                const _EstadoFinalBanner()
              else ...[
                Text(
                  'Selecciona el nuevo estado:',
                  style: TextStyle(
                    color:    Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                ...transiciones.map(
                  (e) => _TransicionOption(
                    estado:     e,
                    isSelected: _estadoSeleccionado == e,
                    onTap: () => setState(() {
                      _estadoSeleccionado = e;
                      if (e != EstadoPlan.rechazado) {
                        _motivoController.clear();
                      }
                    }),
                  ),
                ),

                if (_requiereMotivo) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _motivoController,
                    maxLines:   3,
                    style: const TextStyle(color: Color(0xFFEAFBF4)),
                    decoration: InputDecoration(
                      labelText:         'Motivo del rechazo *',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child:   Icon(Icons.comment_outlined),
                      ),
                      filled:    true,
                      fillColor: const Color(0xFF010C12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.redAccent.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_estadoSeleccionado == null ||
                            provider.isSubmitting)
                        ? null
                        : _confirmar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _estadoSeleccionado == EstadoPlan.rechazado
                              ? Colors.redAccent
                              : const Color(0xFF35F58A),
                      foregroundColor: Colors.black,
                    ),
                    child: provider.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width:  20,
                            child:  CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black),
                          )
                        : Text(
                            _estadoSeleccionado != null
                                ? 'Confirmar → ${_estadoSeleccionado!.label}'
                                : 'Selecciona un estado',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _TransicionOption extends StatelessWidget {
  final EstadoPlan estado;
  final bool       isSelected;
  final VoidCallback onTap;

  const _TransicionOption({
    required this.estado,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usa la función pública en lugar del método privado EstadoChip._config
    final (color, icon) = estadoChipConfig(estado);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin:   const EdgeInsets.only(bottom: 8),
        padding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.12)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                estado.label,
                style: TextStyle(
                  color:      isSelected ? color : const Color(0xFFEAFBF4),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  fontSize:   14,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

class _EstadoFinalBanner extends StatelessWidget {
  const _EstadoFinalBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.blueGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: Colors.blueGrey.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.blueGrey, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Este plan está cerrado. No se permiten más transiciones.',
              style: TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

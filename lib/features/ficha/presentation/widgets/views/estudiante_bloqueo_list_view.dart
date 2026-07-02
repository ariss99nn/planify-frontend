// lib/features/ficha/presentation/widgets/views/estudiante_bloqueo_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/friendly_feedback.dart';
import '../../../../../core/widgets/glass_panel.dart';
import '../../../domain/entities/estudiante_bloqueo_entity.dart';
import '../../providers/ficha_provider.dart';

class EstudianteBloqueoListView extends StatefulWidget {
  const EstudianteBloqueoListView({super.key});

  @override
  State<EstudianteBloqueoListView> createState() => _EstudianteBloqueoListViewState();
}

class _EstudianteBloqueoListViewState extends State<EstudianteBloqueoListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FichaProvider>().fetchBloqueos();
    });
  }

  Future<void> _desbloquear(EstudianteBloqueoEntity b) async {
    final provider = context.read<FichaProvider>();
    final confirmado = await showConfirmDialog(
      context,
      titulo: 'Reactivar estudiante',
      mensaje:
          '${b.estudianteNombre} está bloqueado por ${b.motivoDisplay.toLowerCase()} '
          'hasta ${_fmt(b.fechaFin)}. Esta acción lo habilita de inmediato para '
          'volver a ser asignado a una ficha.',
      textoConfirmar: 'Reactivar',
      esDestructivo: true,
    );
    if (!confirmado) return;

    final ok = await provider.desbloquearEstudiante(b.id);
    if (!mounted) return;
    if (ok) {
      showFriendlySnack(context, 'Estudiante reactivado.', tono: FeedbackTono.exito);
    } else {
      showFriendlyApiError(context, provider.mutationError);
    }
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('ESTUDIANTES BLOQUEADOS'),
        backgroundColor: AppTheme.background,
      ),
      body: Consumer<FichaProvider>(
        builder: (context, provider, _) {
          if (provider.loadingBloqueos) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.bloqueosError != null) {
            return Center(
              child: Text(
                provider.bloqueosError!,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }
          if (provider.bloqueos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No hay estudiantes bloqueados actualmente.',
                  style: TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchBloqueos(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.bloqueos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final b = provider.bloqueos[i];
                return GlassPanel(
                  padding: const EdgeInsets.all(14),
                  accent: Colors.amber,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.estudianteNombre,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${b.motivoDisplay} · bloqueado hasta ${_fmt(b.fechaFin)}'
                              '${b.fichaOrigenCodigo != null ? ' · ficha ${b.fichaOrigenCodigo}' : ''}',
                              style: TextStyle(
                                color: AppTheme.textSecondary.withOpacity(0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _desbloquear(b),
                        child: const Text('Reactivar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

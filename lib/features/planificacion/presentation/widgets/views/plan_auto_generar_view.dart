// lib/features/planificacion/presentation/widgets/views/plan_auto_generar_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/datasources/selector_remote_datasource.dart';
import '../../../data/models/selector_models.dart';
import '../../../domain/entities/plan_trimestral_entity.dart';
import '../../providers/planificacion_provider.dart';
import '../../providers/selector_provider.dart';
import '../planificacion_widgets.dart';
import '../search_selector_sheet.dart';
import 'plan_detail_view.dart';

/// Punto de entrada de la auto-planificación: el usuario solo dice
/// QUÉ ficha y QUÉ trimestre. El motor arma competencias, horas y
/// docentes solo; el usuario nunca ve un formulario de captura.
class PlanAutoGenerarView extends StatefulWidget {
  const PlanAutoGenerarView({super.key});

  @override
  State<PlanAutoGenerarView> createState() => _PlanAutoGenerarViewState();
}

class _PlanAutoGenerarViewState extends State<PlanAutoGenerarView> {
  final _trimestreController = TextEditingController();
  final _selectorDs          = SelectorRemoteDatasource();

  FichaSelector? _fichaSeleccionada;
  bool           _generando = false;

  @override
  void dispose() {
    _trimestreController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFicha() async {
    final provider = SelectorProvider<FichaSelector>(
      (query) => _selectorDs.buscarFichas(query: query),
    );
    final seleccion = await SearchSelectorSheet.open<FichaSelector>(
      context,
      titulo:       'Seleccionar ficha',
      hintBusqueda: 'Buscar por código de ficha…',
      icon:         Icons.folder_outlined,
      provider:     provider,
    );
    if (seleccion != null) setState(() => _fichaSeleccionada = seleccion);
  }

  Future<void> _generar() async {
    if (_fichaSeleccionada == null) {
      _showError('Selecciona una ficha.');
      return;
    }
    final trimestre = int.tryParse(_trimestreController.text.trim());
    if (trimestre == null || trimestre <= 0) {
      _showError('Indica un trimestre válido.');
      return;
    }

    setState(() => _generando = true);
    final provider = context.read<PlanificacionProvider>();
    provider.clearError();

    final resultado = await provider.autoGenerarPlan(
      fichaId:   _fichaSeleccionada!.id,
      trimestre: trimestre,
    );

    if (!mounted) return;
    setState(() => _generando = false);

    if (resultado == null) {
      if (provider.error != null) _showError(provider.error!);
      return;
    }

    await _mostrarReporte(resultado.reporte);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PlanDetailView(planId: resultado.plan.id),
      ),
    );
  }

  Future<void> _mostrarReporte(ReporteAutoGeneracion reporte) {
    final sinConflictos = reporte.conflictos.isEmpty;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C1E29),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              sinConflictos ? Icons.check_circle : Icons.info_outline,
              color: sinConflictos ? const Color(0xFF35F58A) : Colors.amber,
            ),
            const SizedBox(width: 10),
            const Text('Plan generado',
                style: TextStyle(color: Color(0xFFEAFBF4), fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${reporte.itemsCreados} competencia(s) organizadas '
                'automáticamente, listas para revisar.',
                style: const TextStyle(color: Color(0xFF9DC5B5), fontSize: 13),
              ),
              if (!sinConflictos) ...[
                const SizedBox(height: 14),
                Text(
                  '${reporte.conflictos.length} necesitan tu atención antes '
                  'de aprobar:',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: reporte.conflictos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final c = reporte.conflictos[i];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.competencia,
                                style: const TextStyle(
                                    color: Color(0xFFEAFBF4),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(c.tipoLabel,
                                style: const TextStyle(
                                    color: Colors.amber, fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(c.motivo,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 11)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF35F58A),
              foregroundColor: Colors.black,
            ),
            child: const Text('Revisar plan'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(msg),
        backgroundColor: Colors.redAccent,
        behavior:        SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06141D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06141D),
        elevation: 0,
        title: const Text(
          'Generar plan automáticamente',
          style: TextStyle(
            color: Color(0xFFEAFBF4),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _generando,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IntroCard(),
              const SizedBox(height: 24),
              const Text('Ficha',
                  style: TextStyle(
                      color: Color(0xFF9DC5B5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _SelectorTile(
                icon: Icons.folder_outlined,
                label: _fichaSeleccionada == null
                    ? 'Seleccionar ficha…'
                    : '${_fichaSeleccionada!.codigoFicha} — '
                        '${_fichaSeleccionada!.programaNombre}',
                filled: _fichaSeleccionada != null,
                onTap: _seleccionarFicha,
              ),
              const SizedBox(height: 20),
              const Text('Trimestre',
                  style: TextStyle(
                      color: Color(0xFF9DC5B5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _trimestreController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFFEAFBF4)),
                decoration: InputDecoration(
                  hintText: 'Ej: 2',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: const Color(0xFF0C1E29),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _generando ? null : _generar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF35F58A),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _generando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.bolt_rounded),
                  label: Text(
                    _generando
                        ? 'Armando el plan…'
                        : 'Generar automáticamente',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1E29),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1D4E42).withOpacity(0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF28D7FF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'El sistema arma el plan completo: competencias, horas y '
              'docente para cada una, nivelando la carga docente. '
              'Al final solo apruebas, rechazas o ajustas algún punto '
              'puntual.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorTile extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final bool         filled;
  final VoidCallback onTap;

  const _SelectorTile({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1E29),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled
                ? const Color(0xFF35F58A).withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: filled
                    ? const Color(0xFF35F58A)
                    : Colors.white.withOpacity(0.4)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: filled
                      ? const Color(0xFFEAFBF4)
                      : Colors.white.withOpacity(0.4),
                  fontSize: 13,
                  fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

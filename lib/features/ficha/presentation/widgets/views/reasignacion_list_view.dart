// lib/features/ficha/presentation/widgets/views/reasignacion_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/cyber_loading_view.dart';
import '../../../../../core/widgets/cyber_empty_view.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../providers/ficha_provider.dart';
import '../../../domain/entities/ficha_entity.dart';
import 'reasignacion_create_view.dart';

class ReasignacionListView extends StatefulWidget {
  final bool canWrite;
  const ReasignacionListView({super.key, required this.canWrite});

  @override
  State<ReasignacionListView> createState() => _ReasignacionListViewState();
}

class _ReasignacionListViewState extends State<ReasignacionListView> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(
        () => context.read<FichaProvider>().fetchReasignaciones());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<FichaProvider>().fetchMasReasignaciones();
    }
  }

  void _openCrear() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReasignacionCreateView()),
    ).then((_) {
      if (!mounted) return;
      context.read<FichaProvider>().fetchReasignaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isManager = context.read<AuthProvider>().puedeGestionarUsuarios;

    if (!isManager) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 48, color: AppTheme.textSecondary),
            SizedBox(height: 12),
            Text(
              'Solo coordinadores pueden ver las reasignaciones.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final provider = context.watch<FichaProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz,
                  color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              const Text('REASIGNACIONES',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      fontSize: 13)),
              const Spacer(),
              if (!provider.loadingReasignaciones)
                Text('${provider.totalReasignaciones} registros',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withOpacity(0.6))),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primary),
                onPressed: () =>
                    context.read<FichaProvider>().fetchReasignaciones(),
              ),
            ],
          ),
        ),

        if (provider.loadingReasignaciones &&
            provider.reasignaciones.isEmpty)
          const Expanded(
              child: CyberLoadingView(mensaje: 'Cargando reasignaciones…'))
        else if (provider.reasignacionesError != null &&
            provider.reasignaciones.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(provider.reasignacionesError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<FichaProvider>()
                        .fetchReasignaciones(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        else if (provider.reasignaciones.isEmpty)
          const Expanded(
            child: CyberEmptyView(
              icon: Icons.compare_arrows_outlined,
              title: 'Sin reasignaciones',
              subtitle: 'Aún no se han registrado reasignaciones.',
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () =>
                  context.read<FichaProvider>().fetchReasignaciones(),
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                itemCount: provider.reasignaciones.length +
                    (provider.hayMasPaginasReasignaciones ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == provider.reasignaciones.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child:
                          Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _ReasignacionCard(
                      item: provider.reasignaciones[i]);
                },
              ),
            ),
          ),

        if (widget.canWrite)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FloatingActionButton.extended(
                heroTag: 'fab_reasignaciones',
                onPressed: _openCrear,
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Nueva reasignación',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
      ],
    );
  }
}

// ── _ReasignacionCard ──────────────────────────────────────────────────────────

class _ReasignacionCard extends StatelessWidget {
  final ReasignacionEntity item;
  const _ReasignacionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final fecha =
        '${item.fecha.day.toString().padLeft(2, '0')}/'
        '${item.fecha.month.toString().padLeft(2, '0')}/${item.fecha.year}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 15, color: AppTheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.estudianteNombre,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
              ),
              Text(fecha,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary.withOpacity(0.6))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _FichaBadge(
                  codigo: item.fichaOrigenCodigo,
                  color: AppTheme.textSecondary),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward,
                    size: 14, color: AppTheme.primary),
              ),
              _FichaBadge(
                  codigo: item.fichaDestinoCodigo,
                  color: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.motivo,
            style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.7),
                fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.realizadoPorNombre != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.manage_accounts_outlined,
                    size: 12,
                    color: AppTheme.textSecondary.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text('Por: ${item.realizadoPorNombre}',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary.withOpacity(0.4))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FichaBadge extends StatelessWidget {
  final String codigo;
  final Color color;
  const _FichaBadge({required this.codigo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(codigo,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

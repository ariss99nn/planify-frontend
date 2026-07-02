import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme.dart';
import '../../data/datasources/auditoria_remote_datasource.dart';
import '../../data/repositories_impl/auditoria_repository_impl.dart';
import '../../domain/entities/auditoria_entity.dart';
import '../../domain/usecases/auditoria_usecases.dart';
import '../providers/auditoria_provider.dart';

class AuditoriaScreen extends StatelessWidget {
  const AuditoriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final ds = AuditoriaRemoteDataSourceImpl();
        final repo = AuditoriaRepositoryImpl(ds);
        return AuditoriaProvider(getAuditLog: GetAuditLogUseCase(repo));
      },
      child: const _AuditoriaView(),
    );
  }
}

class _AuditoriaView extends StatefulWidget {
  const _AuditoriaView();

  @override
  State<_AuditoriaView> createState() => _AuditoriaViewState();
}

class _AuditoriaViewState extends State<_AuditoriaView> {
  final _scrollController = ScrollController();

  static const _metodos = ['POST', 'PATCH', 'PUT', 'DELETE'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AuditoriaProvider>().cargar());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<AuditoriaProvider>().cargarMas();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditoriaProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Auditoría (${provider.total})',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Column(
        children: [
          _buildFiltros(context, provider),
          Expanded(child: _buildLista(context, provider)),
        ],
      ),
    );
  }

  Widget _buildFiltros(BuildContext context, AuditoriaProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: provider.filtroMetodo == null,
            onSelected: (_) => provider.aplicarFiltros(metodo: null, path: provider.filtroPath),
          ),
          for (final m in _metodos)
            ChoiceChip(
              label: Text(m),
              selected: provider.filtroMetodo == m,
              onSelected: (_) => provider.aplicarFiltros(metodo: m, path: provider.filtroPath),
            ),
        ],
      ),
    );
  }

  Widget _buildLista(BuildContext context, AuditoriaProvider provider) {
    if (provider.loading && provider.registros.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (provider.error != null && provider.registros.isEmpty) {
      return Center(
        child: Text(
          'Error cargando auditoría: ${provider.error}',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }
    if (provider.registros.isEmpty) {
      return const Center(
        child: Text('Sin operaciones registradas.', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => provider.cargar(reset: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: provider.registros.length + (provider.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, i) {
          if (i >= provider.registros.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            );
          }
          return _AuditLogTile(registro: provider.registros[i]);
        },
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  final AuditLogEntity registro;
  const _AuditLogTile({required this.registro});

  Color get _colorMetodo {
    switch (registro.metodo) {
      case 'DELETE':
        return AppTheme.alertaConflictoTexto;
      case 'POST':
        return AppTheme.primary;
      default:
        return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _colorMetodo.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              registro.metodo,
              textAlign: TextAlign.center,
              style: TextStyle(color: _colorMetodo, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(registro.path, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  '${registro.usuarioEmail ?? "anónimo"} · '
                  '${registro.duracionMs.toStringAsFixed(0)}ms · '
                  '${registro.fecha.toLocal()}'.split('.').first,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(
            registro.fueExitoso ? Icons.check_circle_outline : Icons.error_outline,
            color: registro.fueExitoso ? AppTheme.primary : AppTheme.alertaConflictoTexto,
            size: 18,
          ),
        ],
      ),
    );
  }
}

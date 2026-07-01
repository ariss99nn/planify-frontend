// lib/features/aulas/presentation/widgets/views/bloque_detail_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/api/api_service.dart';
import '../../../../../core/constants/app_roles.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../domain/entities/bloque_entity.dart';
import '../../providers/bloque_provider.dart';
import 'bloque_form_view.dart';

class BloqueDetailView extends StatefulWidget {
  final int bloqueId;
  const BloqueDetailView({super.key, required this.bloqueId});

  @override
  State<BloqueDetailView> createState() => _BloqueDetailViewState();
}

class _BloqueDetailViewState extends State<BloqueDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BloqueProvider>().fetchBloque(widget.bloqueId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BloqueProvider>();
    final rol      = context.watch<AuthProvider>().user?.rol ?? '';
    final canWrite = AppRoles.managers.contains(rol);

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.selected?.nombre ?? 'Detalle'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          if (canWrite && provider.selected != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BloqueFormView(bloque: provider.selected)),
              ).then((_) => context.read<BloqueProvider>().fetchBloque(widget.bloqueId)),
            ),
        ],
      ),
      body: switch (provider.detailStatus) {
        BloqueStatus.loading || BloqueStatus.idle =>
          const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        BloqueStatus.error => CyberErrorView(
            message: provider.detailError ?? 'Error cargando bloque',
            onRetry: () => context.read<BloqueProvider>().fetchBloque(widget.bloqueId),
          ),
        BloqueStatus.success => _BloqueDetailBody(bloque: provider.selected!),
      },
    );
  }
}

class _BloqueDetailBody extends StatelessWidget {
  final BloqueDetalleEntity bloque;
  const _BloqueDetailBody({required this.bloque});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bloque.imagenUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                ApiService.buildMediaUrl(bloque.imagenUrl)!,
                height: 180, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Text(bloque.nombre,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
              ),
              CyberEstadoBadge.fromCodigo(bloque.estado, bloque.estadoDisplay),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppTheme.border),
          const SizedBox(height: 12),
          CyberDetailGrid(
            items: [
              CyberDetailGridItem(icon: Icons.layers_outlined, label: 'Pisos', value: '${bloque.pisos}'),
              CyberDetailGridItem(icon: Icons.people_outline, label: 'Cap. máxima', value: '${bloque.capacidadMaxima} personas'),
              CyberDetailGridItem(icon: Icons.flag_outlined, label: 'Estado', value: bloque.estadoDisplay),
              if (bloque.totalAulas != null)
                CyberDetailGridItem(icon: Icons.meeting_room_outlined, label: 'Total aulas', value: '${bloque.totalAulas}'),
            ],
          ),
          const SizedBox(height: 20),
          if (bloque.descripcion.isNotEmpty) ...[
            const CyberSectionLabel(label: 'Descripción'),
            const SizedBox(height: 8),
            Text(bloque.descripcion, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
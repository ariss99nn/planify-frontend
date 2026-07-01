// lib/features/aulas/presentation/widgets/views/equipamiento_detail_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/api/api_service.dart';
import '../../../../../core/constants/app_roles.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../domain/entities/equipamiento_entity.dart';
import '../../providers/equipamiento_provider.dart';
import 'equipamiento_form_view.dart';
import 'equipamiento_estado_badge.dart';

class EquipamientoDetailView extends StatefulWidget {
  final int equipamientoId;
  const EquipamientoDetailView({super.key, required this.equipamientoId});

  @override
  State<EquipamientoDetailView> createState() => _EquipamientoDetailViewState();
}

class _EquipamientoDetailViewState extends State<EquipamientoDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EquipamientoProvider>().fetchEquipamiento(widget.equipamientoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EquipamientoProvider>();
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
                MaterialPageRoute(builder: (_) => EquipamientoFormView(equipamiento: provider.selected)),
              ).then((_) => context.read<EquipamientoProvider>().fetchEquipamiento(widget.equipamientoId)),
            ),
        ],
      ),
      body: switch (provider.detailStatus) {
        EquipamientoStatus.loading || EquipamientoStatus.idle =>
          const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        EquipamientoStatus.error => CyberErrorView(
            message: provider.detailError ?? 'Error cargando equipamiento',
            onRetry: () => context.read<EquipamientoProvider>().fetchEquipamiento(widget.equipamientoId),
          ),
        EquipamientoStatus.success => _EquipamientoDetailBody(equip: provider.selected!),
      },
    );
  }
}

class _EquipamientoDetailBody extends StatelessWidget {
  final EquipamientoDetalleEntity equip;
  const _EquipamientoDetailBody({required this.equip});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (equip.imagenUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                ApiService.buildMediaUrl(equip.imagenUrl)!,
                height: 180, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Text(equip.nombre,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
              ),
              equipamientoEstadoBadge(equip.estado, equip.estadoDisplay),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppTheme.border),
          const SizedBox(height: 12),
          CyberDetailGrid(
            items: [
              CyberDetailGridItem(icon: Icons.inventory_2_outlined, label: 'Cantidad', value: '${equip.cantidad} unidades'),
              CyberDetailGridItem(icon: Icons.flag_outlined, label: 'Estado', value: equip.estadoDisplay),
              if (equip.numeroSerie != null)
                CyberDetailGridItem(icon: Icons.qr_code_outlined, label: 'N.º de serie', value: equip.numeroSerie!),
              if (equip.fechaAdquisicion != null)
                CyberDetailGridItem(icon: Icons.calendar_today_outlined, label: 'Adquisición', value: equip.fechaAdquisicion!),
            ],
          ),
          const SizedBox(height: 20),
          if (equip.descripcion.isNotEmpty) ...[
            const CyberSectionLabel(label: 'Descripción'),
            const SizedBox(height: 8),
            Text(equip.descripcion, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
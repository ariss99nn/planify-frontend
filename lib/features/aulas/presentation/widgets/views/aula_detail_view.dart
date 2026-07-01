// lib/features/aulas/presentation/widgets/views/aula_detail_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/api/api_service.dart';
import '../../../../../core/constants/app_roles.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../../domain/entities/aula_entity.dart';
import '../../providers/aula_provider.dart';
import 'aula_form_view.dart';

class AulaDetailView extends StatefulWidget {
  final int aulaId;
  const AulaDetailView({super.key, required this.aulaId});

  @override
  State<AulaDetailView> createState() => _AulaDetailViewState();
}

class _AulaDetailViewState extends State<AulaDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AulaProvider>().fetchAula(widget.aulaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<AulaProvider>();
    final rol       = context.watch<AuthProvider>().user?.rol ?? '';
    final canWrite  = AppRoles.managers.contains(rol);

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.selected?.codigoAula ?? 'Detalle'),
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
                MaterialPageRoute(
                  builder: (_) => AulaFormView(aula: provider.selected),
                ),
              ).then((_) => context.read<AulaProvider>().fetchAula(widget.aulaId)),
            ),
        ],
      ),
      body: switch (provider.detailStatus) {
        AulaStatus.loading || AulaStatus.idle => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        AulaStatus.error => CyberErrorView(
            message: provider.detailError ?? 'Error cargando aula',
            onRetry: () => context.read<AulaProvider>().fetchAula(widget.aulaId),
          ),
        AulaStatus.success => _AulaDetailBody(
            aula: provider.selected!,
            canChangeEstado: canWrite,
          ),
      },
    );
  }
}

class _AulaDetailBody extends StatelessWidget {
  final AulaEntity aula;
  final bool canChangeEstado;

  const _AulaDetailBody({required this.aula, required this.canChangeEstado});

  static const _estadosOpciones = [
    ('ACT',  'Activa'),
    ('MANT', 'Mantenimiento'),
    ('INAC', 'Inactiva'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (aula.imagenUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                ApiService.buildMediaUrl(aula.imagenUrl)!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  aula.codigoAula,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
                ),
              ),
              CyberEstadoBadge.fromCodigo(
                aula.estado,
                aula.estadoDisplay,
                tappable: canChangeEstado,
                onTap: canChangeEstado ? () => _showEstadoSheet(context) : null,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(aula.bloque.nombre, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Divider(color: AppTheme.border),
          const SizedBox(height: 12),
          CyberDetailGrid(
            items: [
              CyberDetailGridItem(icon: Icons.category_outlined, label: 'Tipo', value: aula.tipoAulaDisplay),
              CyberDetailGridItem(icon: Icons.people_outline, label: 'Capacidad', value: '${aula.capacidad} personas'),
              CyberDetailGridItem(icon: Icons.business_outlined, label: 'Bloque', value: aula.bloque.nombre),
              CyberDetailGridItem(icon: Icons.layers_outlined, label: 'Piso', value: 'Piso ${aula.piso}'),
            ],
          ),
          const SizedBox(height: 20),
          if (aula.descripcion.isNotEmpty) ...[
            const CyberSectionLabel(label: 'Descripción'),
            const SizedBox(height: 8),
            Text(aula.descripcion, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
          ],
          const CyberSectionLabel(label: 'Equipamiento'),
          const SizedBox(height: 10),
          if (aula.equipamiento.isEmpty)
            const CyberEmptyView(
              icon: Icons.devices_other_outlined,
              title: 'Sin equipamiento',
              subtitle: 'No hay equipamiento asignado a esta aula',
            )
          else
            ...aula.equipamiento.map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.devices_other, size: 18, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.nombre,
                          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                    ),
                    Text('x${e.cantidad}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(width: 10),
                    CyberStatusBadge(label: e.estadoDisplay, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showEstadoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
            ),
            const CyberSectionLabel(label: 'Cambiar estado'),
            const SizedBox(height: 12),
            ..._estadosOpciones.map(
              (op) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  aula.estado == op.$1 ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppTheme.primary, size: 20,
                ),
                title: Text(op.$2, style: const TextStyle(color: AppTheme.textPrimary)),
                selected: aula.estado == op.$1,
                selectedColor: AppTheme.primary,
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<AulaProvider>().updateEstado(aula.id, op.$1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
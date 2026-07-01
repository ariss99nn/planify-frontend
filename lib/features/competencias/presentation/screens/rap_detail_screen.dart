import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rap_provider.dart';
import '../../competencia_theme.dart';
import '../../../../core/widgets/widgets.dart';
import 'rap_form_screen.dart';

const _managers = {'COORDINADOR', 'ADMINISTRATIVO'};

class RapDetailScreen extends StatefulWidget {
  final int    id;
  final String userRole;

  const RapDetailScreen({super.key, required this.id, required this.userRole});

  @override
  State<RapDetailScreen> createState() => _RapDetailScreenState();
}

class _RapDetailScreenState extends State<RapDetailScreen> {
  bool get _isManager => _managers.contains(widget.userRole);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RapProvider>().loadDetail(widget.id);
    });
  }

  Future<void> _delete(BuildContext context) async {
    final prov = context.read<RapProvider>();
    final item = prov.detail!;
    final confirmed = await CyberDialog.confirm(
      context: context,
      title: 'Eliminar resultado',
      message: '¿Eliminar "${item.codigo}"? Esta acción es irreversible.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    final error = await prov.delete(item.id);
    if (!mounted) return;
    if (error != null) {
      await CyberDialog.error(
        context: context,
        title: 'No se pudo eliminar',
        message: error,
        icon: Icons.warning_amber_rounded,
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resultado eliminado.'),
          backgroundColor: CT.primary,
        ),
      );
    }
  }

  void _openEdit(BuildContext context) {
    final prov = context.read<RapProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: prov,
          child: RapFormScreen(existing: prov.detail),
        ),
      ),
    ).then((_) {
      if (mounted) prov.loadDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CT.background,
      body: Consumer<RapProvider>(
        builder: (context, prov, _) {
          if (prov.isLoadingDetail) {
            return const Center(
                child: CircularProgressIndicator(color: CT.primary));
          }
          if (prov.detailError != null) {
            return CyberErrorView(
              message: prov.detailError!,
              onRetry: () => prov.loadDetail(widget.id),
            );
          }
          final item = prov.detail;
          if (item == null) return const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: CT.background,
                expandedHeight: 110,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    item.codigo,
                    style: const TextStyle(
                      color: CT.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                ),
                actions: _isManager
                    ? [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: CT.primary),
                          onPressed: () => _openEdit(context),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: prov.isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: CT.error,
                                  ))
                              : const Icon(Icons.delete_outline,
                                  color: CT.error),
                          onPressed: prov.isDeleting
                              ? null
                              : () => _delete(context),
                          tooltip: 'Eliminar',
                        ),
                        const SizedBox(width: 8),
                      ]
                    : null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LabelValue(
                              label: 'Competencia',
                              value: item.competenciaNombre ?? '—',
                            ),
                            if (item.competenciaCodigo != null)
                              _LabelValue(
                                label: 'Código competencia',
                                value: item.competenciaCodigo!,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle('DESCRIPCIÓN'),
                            const SizedBox(height: 8),
                            Text(
                              item.descripcion,
                              style: const TextStyle(
                                color: CT.textPrimary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.criteriosEvaluacion.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _DetailCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionTitle('CRITERIOS DE EVALUACIÓN'),
                              const SizedBox(height: 8),
                              Text(
                                item.criteriosEvaluacion,
                                style: const TextStyle(
                                  color: CT.textPrimary,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Widgets locales ───────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final Widget child;
  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CT.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CT.border),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CT.textSec,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(color: CT.textSec, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: CT.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/competencia_provider.dart';
import '../widgets/competencia_card.dart';
import '../../competencia_theme.dart';
import '../../../../core/widgets/widgets.dart';
import 'competencia_detail_screen.dart';
import 'competencia_form_screen.dart';
import 'competencia_transversal_form_screen.dart';
import 'asignatura_list_screen.dart' show PaginationBar;

const _managers = {'COORDINADOR', 'ADMINISTRATIVO'};

class CompetenciaListScreen extends StatefulWidget {
  final String  userRole;
  final int?    asignaturaId;
  final String? asignaturaNombre;

  const CompetenciaListScreen({
    super.key,
    required this.userRole,
    this.asignaturaId,
    this.asignaturaNombre,
  });

  @override
  State<CompetenciaListScreen> createState() => _CompetenciaListScreenState();
}

class _CompetenciaListScreenState extends State<CompetenciaListScreen> {
  bool get _isManager => _managers.contains(widget.userRole);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<CompetenciaProvider>();
      if (widget.asignaturaId != null) {
        prov.setAsignaturaId(widget.asignaturaId);
      } else {
        prov.loadPage();
      }
    });
  }

  void _openDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<CompetenciaProvider>(),
          child: CompetenciaDetailScreen(id: id, userRole: widget.userRole),
        ),
      ),
    );
  }

  void _openCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CT.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: CT.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.star_outline, color: CT.principal),
              title: const Text('Competencia principal',
                  style: TextStyle(color: CT.textPrimary)),
              subtitle: const Text('Ligada a una asignatura',
                  style: TextStyle(color: CT.textSec, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<CompetenciaProvider>(),
                      child: CompetenciaFormScreen(
                          preAsignaturaId: widget.asignaturaId),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.public_outlined, color: CT.transversal),
              title: const Text('Competencia transversal',
                  style: TextStyle(color: CT.textPrimary)),
              subtitle: const Text('Pertenece al centro, no a un módulo',
                  style: TextStyle(color: CT.textSec, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<CompetenciaProvider>(),
                      child: const CompetenciaTransversalFormScreen(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CT.background,
      body: Consumer<CompetenciaProvider>(
        builder: (context, prov, _) {
          return RefreshIndicator(
            color: CT.primary,
            backgroundColor: CT.surface,
            onRefresh: () => prov.loadPage(page: prov.currentPage),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: CT.background,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.asignaturaNombre ?? 'Competencias',
                      style: const TextStyle(
                          color: CT.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    titlePadding:
                        const EdgeInsets.only(left: 20, bottom: 14, right: 60),
                  ),
                  actions: [
                    if (prov.totalCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: CT.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: CT.primary.withOpacity(0.3)),
                            ),
                            child: Text('${prov.totalCount}',
                                style: const TextStyle(
                                    color: CT.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      children: [
                        CyberSearchBar(
                          hint: 'Buscar por código o nombre…',
                          onChanged: (v) => prov.setSearch(v ?? ''),
                        ),
                        const SizedBox(height: 8),
                        CyberDropdownFilter(
                          value: prov.tipo.isEmpty ? null : prov.tipo,
                          hint: 'Tipo de competencia',
                          allLabel: 'Principales y transversales',
                          onChanged: (v) => prov.setTipo(v ?? ''),
                          items: const [
                            ('PRINCIPAL', 'Principal'),
                            ('TRANSVERSAL', 'Transversal'),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (prov.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(color: CT.primary)),
                  )
                else if (prov.error != null)
                  SliverFillRemaining(
                    child: CyberErrorView(
                        message: prov.error!, onRetry: prov.loadPage),
                  )
                else if (prov.items.isEmpty)
                  SliverFillRemaining(
                    child: CyberEmptyView(
                      title: 'Sin competencias',
                      message:
                          'No se encontraron competencias con los filtros actuales.',
                      icon: Icons.layers_outlined,
                      actionLabel: _isManager ? 'Nueva competencia' : null,
                      onAction:
                          _isManager ? () => _openCreateMenu(context) : null,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => CompetenciaCard(
                        item: prov.items[i],
                        onTap: () => _openDetail(ctx, prov.items[i].id),
                      ),
                      childCount: prov.items.length,
                    ),
                  ),
                if (!prov.isLoading && prov.items.isNotEmpty)
                  SliverToBoxAdapter(
                    child: PaginationBar(
                      currentPage: prov.currentPage,
                      totalCount: prov.totalCount,
                      pageSize: 20,
                      hasNext: prov.hasNext,
                      hasPrevious: prov.hasPrevious,
                      onNext: prov.nextPage,
                      onPrevious: prov.previousPage,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _isManager
          ? FloatingActionButton.extended(
              heroTag: 'fab_competencia',
              onPressed: () => _openCreateMenu(context),
              backgroundColor: CT.primary,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text('Nueva',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }
}
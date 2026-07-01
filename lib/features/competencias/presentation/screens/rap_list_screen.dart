import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rap_provider.dart';
import '../widgets/rap_card.dart';
import '../../competencia_theme.dart';
import '../../../../core/widgets/widgets.dart';
import 'rap_detail_screen.dart';
import 'rap_form_screen.dart';
import 'asignatura_list_screen.dart' show PaginationBar;

const _managers = {'COORDINADOR', 'ADMINISTRATIVO'};

class RapListScreen extends StatefulWidget {
  final String  userRole;
  final int?    competenciaId;
  final String? competenciaNombre;

  const RapListScreen({
    super.key,
    required this.userRole,
    this.competenciaId,
    this.competenciaNombre,
  });

  @override
  State<RapListScreen> createState() => _RapListScreenState();
}

class _RapListScreenState extends State<RapListScreen> {
  bool get _isManager => _managers.contains(widget.userRole);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<RapProvider>();
      if (widget.competenciaId != null) {
        prov.setCompetenciaId(widget.competenciaId);
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
          value: context.read<RapProvider>(),
          child: RapDetailScreen(id: id, userRole: widget.userRole),
        ),
      ),
    );
  }

  void _openCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<RapProvider>(),
          child: RapFormScreen(preCompetenciaId: widget.competenciaId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CT.background,
      body: Consumer<RapProvider>(
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
                      widget.competenciaNombre ?? 'Resultados de aprendizaje',
                      style: const TextStyle(
                          color: CT.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: CyberSearchBar(
                      hint: 'Buscar por código o descripción…',
                      onChanged: (v) => prov.setSearch(v ?? ''),
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
                      title: 'Sin resultados',
                      message:
                          'No se encontraron resultados de aprendizaje con los filtros actuales.',
                      icon: Icons.fact_check_outlined,
                      actionLabel: _isManager ? 'Nuevo resultado' : null,
                      onAction:
                          _isManager ? () => _openCreate(context) : null,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => RapCard(
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
              heroTag: 'fab_rap',
              onPressed: () => _openCreate(context),
              backgroundColor: CT.primary,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }
}
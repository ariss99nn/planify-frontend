import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/asignatura_provider.dart';
import '../widgets/asignatura_card.dart';
import '../../competencia_theme.dart';
import '../../../../core/widgets/widgets.dart';
import 'asignatura_detail_screen.dart';
import 'asignatura_form_screen.dart';

const _managers = {'COORDINADOR', 'ADMINISTRATIVO'};

class AsignaturaListScreen extends StatefulWidget {
  final String userRole;

  const AsignaturaListScreen({super.key, required this.userRole});

  @override
  State<AsignaturaListScreen> createState() => _AsignaturaListScreenState();
}

class _AsignaturaListScreenState extends State<AsignaturaListScreen> {
  bool get _isManager => _managers.contains(widget.userRole);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AsignaturaProvider>().loadPage();
    });
  }

  void _openDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AsignaturaProvider>(),
          child: AsignaturaDetailScreen(id: id, userRole: widget.userRole),
        ),
      ),
    );
  }

  void _openCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AsignaturaProvider>(),
          child: const AsignaturaFormScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CT.background,
      body: Consumer<AsignaturaProvider>(
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
                  flexibleSpace: const FlexibleSpaceBar(
                    title: Text('Asignaturas',
                        style: TextStyle(
                            color: CT.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                    titlePadding: EdgeInsets.only(left: 20, bottom: 14),
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
                          hint: 'Buscar por nombre o módulo…',
                          onChanged: (v) => prov.setSearch(v ?? ''),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CyberDropdownFilter(
                                value: prov.tipo.isEmpty ? null : prov.tipo,
                                hint: 'Tipo',
                                allLabel: 'Todos los tipos',
                                onChanged: (v) => prov.setTipo(v ?? ''),
                                items: const [
                                  ('TEORICA', 'Teórica'),
                                  ('PRACTICA', 'Práctica'),
                                  ('TEORICO_PRACTICA', 'Teórico-Práctica'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CyberDropdownFilter(
                                value: prov.estado.isEmpty ? null : prov.estado,
                                hint: 'Estado',
                                allLabel: 'Todos',
                                onChanged: (v) => prov.setEstado(v ?? ''),
                                items: const [
                                  ('ACTIVA', 'Activa'),
                                  ('INACTIVA', 'Inactiva'),
                                ],
                              ),
                            ),
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
                      title: 'Sin asignaturas',
                      message:
                          'No se encontraron asignaturas con los filtros actuales.',
                      icon: Icons.book_outlined,
                      actionLabel: _isManager ? 'Nueva asignatura' : null,
                      onAction: _isManager ? () => _openCreate(context) : null,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => AsignaturaCard(
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
              heroTag: 'fab_asignatura',
              onPressed: () => _openCreate(context),
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

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalCount;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const PaginationBar({
    required this.currentPage,
    required this.totalCount,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = pageSize > 0
        ? (totalCount / pageSize).ceil().clamp(1, 9999)
        : 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: hasPrevious ? CT.primary : CT.textSec,
            onPressed: hasPrevious ? onPrevious : null,
          ),
          Text('$currentPage / $totalPages',
              style: const TextStyle(color: CT.textPrimary)),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: hasNext ? CT.primary : CT.textSec,
            onPressed: hasNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}
// lib/features/planificacion/presentation/widgets/search_selector_sheet.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/selector_models.dart';
import '../providers/selector_provider.dart';
export '../providers/selector_provider.dart';

class SearchSelectorSheet<T extends Seleccionable> extends StatefulWidget {
  final String   titulo;
  final String   hintBusqueda;
  final SelectorProvider<T> provider;
  final IconData icon;

  const SearchSelectorSheet({
    super.key,
    required this.titulo,
    required this.provider,
    this.hintBusqueda = 'Buscar...',
    this.icon         = Icons.search,
  });

  /// Helper estático para abrir el sheet y obtener la selección.
  static Future<T?> open<T extends Seleccionable>(
    BuildContext context, {
    required String            titulo,
    required SelectorProvider<T> provider,
    String   hintBusqueda = 'Buscar...',
    IconData icon         = Icons.search,
  }) {
    return showModalBottomSheet<T>(
      context:             context,
      isScrollControlled:  true,
      backgroundColor:     Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: SearchSelectorSheet<T>(
          titulo:       titulo,
          provider:     provider,
          hintBusqueda: hintBusqueda,
          icon:         icon,
        ),
      ),
    );
  }

  @override
  State<SearchSelectorSheet<T>> createState() =>
      _SearchSelectorSheetState<T>();
}

class _SearchSelectorSheetState<T extends Seleccionable>
    extends State<SearchSelectorSheet<T>> {
  final _controller = TextEditingController();
  Timer? _debounce;

  static const _debounceDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.provider.buscar(null);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      widget.provider.buscar(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize:     0.4,
      maxChildSize:     0.95,
      expand:           false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color:        Color(0xFF0C1E29),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width:  40,
                height: 4,
                decoration: BoxDecoration(
                  color:        Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(widget.icon, color: const Color(0xFF35F58A), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.titulo,
                      style: const TextStyle(
                        color:      Color(0xFFEAFBF4),
                        fontWeight: FontWeight.w700,
                        fontSize:   16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Buscador
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _controller,
                  autofocus:  false,
                  style:      const TextStyle(color: Color(0xFFEAFBF4)),
                  onChanged:  _onChanged,
                  decoration: InputDecoration(
                    hintText: widget.hintBusqueda,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon:      const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _controller.clear();
                              _onChanged('');
                            },
                          )
                        : null,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF1D4E42), height: 1),

              // Resultados
              Expanded(
                child: Consumer<SelectorProvider<T>>(
                  builder: (context, provider, _) {
                    if (provider.error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent, size: 28),
                              const SizedBox(height: 10),
                              Text(
                                provider.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.redAccent),
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: () => provider.reintentar(),
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Reintentar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      const Color(0xFF35F58A),
                                  side: const BorderSide(
                                      color: Color(0xFF35F58A)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (provider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child:   CircularProgressIndicator(
                            color: Color(0xFF35F58A),
                          ),
                        ),
                      );
                    }

                    if (provider.resultados.isEmpty) {
                      return Center(
                        child: Text(
                          'Sin resultados.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller:    scrollController,
                      padding:       const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount:     provider.resultados.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 6),
                      itemBuilder: (context, i) {
                        final item = provider.resultados[i];
                        return _SelectorTile<T>(item: item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectorTile<T extends Seleccionable> extends StatelessWidget {
  final T item;
  const _SelectorTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap:        () => Navigator.pop(context, item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:        Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.tituloPrincipal,
              style: const TextStyle(
                color:      Color(0xFFEAFBF4),
                fontWeight: FontWeight.w600,
                fontSize:   14,
              ),
            ),
            if (item.subtitulo != null) ...[
              const SizedBox(height: 3),
              Text(
                item.subtitulo!,
                style: TextStyle(
                  color:    Colors.white.withOpacity(0.45),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

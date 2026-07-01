// lib/features/programa/presentation/widgets/views/programa_list_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/common/state_views.dart';
import '../../../../../core/widgets/common/status_chip.dart';
import '../../../domain/entities/programa_entity.dart';
import '../../providers/programa_provider.dart';
import 'programa_detail_view.dart';

class ProgramaListView extends StatefulWidget {
  const ProgramaListView({super.key});

  @override
  State<ProgramaListView> createState() => _ProgramaListViewState();
}

class _ProgramaListViewState extends State<ProgramaListView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  ProgramaNivel? _nivel;
  ProgramaEstado? _estado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramaProvider>().fetchList();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<ProgramaProvider>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _applyFiltros);
  }

  void _applyFiltros() {
    context.read<ProgramaProvider>().setFiltros(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          nivel: _nivel,
          estado: _estado,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgramaProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre o descripción...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _FiltroDropdown<ProgramaNivel>(
                label: 'Nivel',
                value: _nivel,
                items: ProgramaNivel.values,
                labelOf: (n) => n.label,
                onChanged: (v) {
                  setState(() => _nivel = v);
                  _applyFiltros();
                },
              ),
              const SizedBox(width: 8),
              _FiltroDropdown<ProgramaEstado>(
                label: 'Estado',
                value: _estado,
                items: ProgramaEstado.values,
                labelOf: (e) => e.label,
                onChanged: (v) {
                  setState(() => _estado = v);
                  _applyFiltros();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildBody(provider)),
      ],
    );
  }

  Widget _buildBody(ProgramaProvider provider) {
    if (provider.isLoadingList && provider.items.isEmpty) {
      return const LoadingView();
    }
    if (provider.listError != null && provider.items.isEmpty) {
      return ErrorRetryView(
        message: provider.listError!,
        onRetry: () => provider.fetchList(),
      );
    }
    if (provider.items.isEmpty) {
      return const EmptyStateView(
        message: 'No hay programas registrados todavía.',
        icon: Icons.school_outlined,
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => provider.fetchList(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: provider.items.length + (provider.hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }
          return _ProgramaCard(item: provider.items[index]);
        },
      ),
    );
  }
}

class _ProgramaCard extends StatelessWidget {
  final ProgramaResumenEntity item;

  const _ProgramaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProgramaDetailView(programaId: item.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.nombre,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  StatusChip.estado(item.estado.value, item.estadoDisplay),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _MetaTag(icon: Icons.signal_cellular_alt, label: item.nivelDisplay),
                  _MetaTag(icon: Icons.layers_outlined, label: item.tipoFormacionDisplay),
                  _MetaTag(icon: Icons.schedule_outlined, label: '${item.totalHoras} h'),
                  _MetaTag(
                    icon: Icons.dns_outlined,
                    label: '${item.totalVersiones} versión(es)',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _FiltroDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  const _FiltroDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          hint: Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          dropdownColor: AppTheme.surfaceLight,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text('Todos: $label', style: const TextStyle(fontSize: 13)),
            ),
            ...items.map(
              (e) => DropdownMenuItem<T?>(
                value: e,
                child: Text(labelOf(e), style: const TextStyle(fontSize: 13)),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

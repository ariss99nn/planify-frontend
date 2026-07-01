import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'cyber_empty_view.dart';
import 'cyber_error_view.dart';

/// Envuelve el patrón repetido de toda pantalla de lista CRUD:
/// AppBar + filtros + switch(loading/error/empty/success) + RefreshIndicator.
///
/// Lo específico de cada entidad (la card, los filtros) se pasa como
/// parámetros — el provider y sus tipos de estado NO se generalizan,
/// cada screen sigue leyendo su propio provider con context.watch().
class CyberCrudListScaffold extends StatelessWidget {
  final String title;
  final bool canWrite;
  final VoidCallback? onCreate;
  final String createTooltip;

  final Widget? filterBar;

  final bool loading;
  final String? errorMessage;
  final VoidCallback onRetry;

  final bool isEmpty;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptySubtitle;

  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext) listBuilder;

  const CyberCrudListScaffold({
    super.key,
    required this.title,
    required this.canWrite,
    required this.onCreate,
    required this.createTooltip,
    required this.loading,
    required this.errorMessage,
    required this.onRetry,
    required this.isEmpty,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.onRefresh,
    required this.listBuilder,
    this.filterBar,
    this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          if (canWrite && onCreate != null)
            IconButton(
              icon: const Icon(Icons.add, color: AppTheme.primary),
              tooltip: createTooltip,
              onPressed: onCreate,
            ),
        ],
      ),
      body: Column(
        children: [
          if (filterBar != null) filterBar!,
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (errorMessage != null) {
      return CyberErrorView(message: errorMessage!, onRetry: onRetry);
    }
    if (isEmpty) {
      return CyberEmptyView(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: onRefresh,
      child: listBuilder(context),
    );
  }
}
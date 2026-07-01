import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Widget de filtros de alertas.
///
/// Expone un único callback [onFiltrosChanged] que emite el par
/// (estado, tipo) — el Provider decide qué hacer con ambos valores
/// en una sola operación, evitando dobles recargas.
class AlertaFilterChips extends StatelessWidget {
  final String? filtroEstado;
  final String? filtroTipo;

  /// Callback unificado: emite (estado, tipo) como un par.
  /// null en cualquiera de los dos significa "sin filtro".
  final void Function(String? estado, String? tipo) onFiltrosChanged;

  const AlertaFilterChips({
    super.key,
    this.filtroEstado,
    this.filtroTipo,
    required this.onFiltrosChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _Chip(
              label: 'Todas',
              selected: filtroEstado == null && filtroTipo == null,
              onTap: () => onFiltrosChanged(null, null),
            ),
            _Chip(
              label: 'Pendientes',
              selected: filtroEstado == 'PENDIENTE',
              onTap: () => onFiltrosChanged(
                filtroEstado == 'PENDIENTE' ? null : 'PENDIENTE',
                null, // limpiar tipo al seleccionar estado
              ),
            ),
            _Chip(
              label: 'Conflictos',
              selected: filtroTipo == 'CONFLICTO',
              onTap: () => onFiltrosChanged(
                null, // limpiar estado al seleccionar tipo
                filtroTipo == 'CONFLICTO' ? null : 'CONFLICTO',
              ),
            ),
            _Chip(
              label: 'Leídas',
              selected: filtroEstado == 'LEIDA',
              onTap: () => onFiltrosChanged(
                filtroEstado == 'LEIDA' ? null : 'LEIDA',
                null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color:
                selected ? AppTheme.primary : Theme.of(context).dividerColor,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected
                ? AppTheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

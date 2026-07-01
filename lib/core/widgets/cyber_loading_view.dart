// lib/core/widgets/cyber_loading_view.dart
import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Pantalla de carga estándar del proyecto.
/// Úsala como primer estado de cualquier pantalla mientras llega el primer fetch.
///
/// Uso básico:
///   if (provider.isLoading && provider.items.isEmpty) {
///     return const CyberLoadingView();
///   }
///
/// Con mensaje:
///   return const CyberLoadingView(mensaje: 'Cargando planificaciones…');
class CyberLoadingView extends StatelessWidget {
  final String? mensaje;

  const CyberLoadingView({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primary,
            ),
          ),
          if (mensaje != null) ...[
            const SizedBox(height: 18),
            Text(
              mensaje!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
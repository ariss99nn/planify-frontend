// lib/core/widgets/glass_panel.dart
//
// Contenedor translúcido reutilizable ("glassmorphism" ligero) para
// pantallas de detalle/resumen: deja intuir el fondo detrás del panel
// en vez de bloques opacos de borde a borde, manteniendo la paleta
// Cyber Tech existente.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? accent;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.blur = 14,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final borde = (accent ?? AppTheme.border).withOpacity(0.5);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.surface.withOpacity(0.35),
                AppTheme.surface.withOpacity(0.18),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borde),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Insignia pequeña (badge) para etiquetas cortas como nivel del
/// programa, jornada o modalidad, con el mismo lenguaje visual.
class GlassBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const GlassBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

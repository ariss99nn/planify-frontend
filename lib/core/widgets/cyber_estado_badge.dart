import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Badge de estado semántico para entidades con estados definidos
/// (aulas, equipos, fichas, etc.). Colores adaptados al tema Cyber oscuro.
class CyberEstadoBadge extends StatelessWidget {
  final String label;
  final _EstadoColor _c;
  final bool tappable;
  final VoidCallback? onTap;

  const CyberEstadoBadge._({
    required this.label,
    required _EstadoColor c,
    this.tappable = false,
    this.onTap,
  }) : _c = c;

  /// Activa / disponible
  factory CyberEstadoBadge.activa({
    String label = 'Activa',
    bool tappable = false,
    VoidCallback? onTap,
  }) =>
      CyberEstadoBadge._(
        label: label,
        c: const _EstadoColor(
          bg: Color(0xFF0D2A1A),
          fg: Color(0xFF35F58A),
          border: Color(0xFF14C768),
        ),
        tappable: tappable,
        onTap: onTap,
      );

  /// Mantenimiento / advertencia
  factory CyberEstadoBadge.mantenimiento({
    String label = 'Mantenimiento',
    bool tappable = false,
    VoidCallback? onTap,
  }) =>
      CyberEstadoBadge._(
        label: label,
        c: const _EstadoColor(
          bg: Color(0xFF2A1A00),
          fg: Color(0xFFFFB84D),
          border: Color(0xFF996A00),
        ),
        tappable: tappable,
        onTap: onTap,
      );

  /// Inactiva / error
  factory CyberEstadoBadge.inactiva({
    String label = 'Inactiva',
    bool tappable = false,
    VoidCallback? onTap,
  }) =>
      CyberEstadoBadge._(
        label: label,
        c: const _EstadoColor(
          bg: Color(0xFF2A0A0A),
          fg: Color(0xFFFF6B6B),
          border: Color(0xFF8B2020),
        ),
        tappable: tappable,
        onTap: onTap,
      );

  /// Factory desde código de string ('ACT', 'MANT', 'INAC')
  factory CyberEstadoBadge.fromCodigo(
    String codigo,
    String display, {
    bool tappable = false,
    VoidCallback? onTap,
  }) {
    return switch (codigo) {
      'ACT'  => CyberEstadoBadge.activa(
          label: display, tappable: tappable, onTap: onTap),
      'MANT' => CyberEstadoBadge.mantenimiento(
          label: display, tappable: tappable, onTap: onTap),
      'INAC' => CyberEstadoBadge.inactiva(
          label: display, tappable: tappable, onTap: onTap),
      _ => CyberEstadoBadge._(
          label: display,
          c: const _EstadoColor(
            bg: Color(0xFF1A1A1A),
            fg: AppTheme.textSecondary,
            border: AppTheme.border,
          ),
          tappable: tappable,
          onTap: onTap,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _c.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _c.fg,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (tappable) ...[
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 14, color: _c.fg),
          ],
        ],
      ),
    );

    if (tappable && onTap != null) {
      return GestureDetector(onTap: onTap, child: badge);
    }
    return badge;
  }
}

class _EstadoColor {
  final Color bg;
  final Color fg;
  final Color border;
  const _EstadoColor(
      {required this.bg, required this.fg, required this.border});
}
import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/alerta_entity.dart';

class AlertaCard extends StatelessWidget {
  final AlertaEntity alerta;
  final VoidCallback? onTap;

  const AlertaCard({super.key, required this.alerta, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !alerta.isLeida;
    final cardColor = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: isUnread
                ? const BorderSide(color: AppTheme.primary, width: 3)
                : BorderSide.none,
            top: BorderSide(color: borderColor, width: 0.5),
            right: BorderSide(color: borderColor, width: 0.5),
            bottom: BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(isUnread ? 10 : 12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBubble(tipo: alerta.tipo),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          alerta.tipoDisplay,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _tipoColor(alerta.tipo),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(alerta.fechaCreacion),
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      alerta.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _EstadoBadge(
                          estado: alerta.estado,
                          display: alerta.estadoDisplay,
                        ),
                        const Spacer(),
                        if (alerta.destinatarioNombre != null)
                          _DestinatarioLabel(
                            nombre: alerta.destinatarioNombre!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isUnread) ...[
                const SizedBox(width: 6),
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers estáticos (no acceden a instancia, no recalculan por rebuild) ─

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (DateUtils.dateOnly(dt) == DateUtils.dateOnly(now)) {
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }

  static Color _tipoColor(TipoAlerta tipo) => switch (tipo) {
        TipoAlerta.conflicto => AppTheme.alertaConflictoTexto,
        TipoAlerta.disponibilidad => AppTheme.alertaDisponibilidadTexto,
        TipoAlerta.sistema => AppTheme.alertaSistemaTexto,
        TipoAlerta.desconocido => Colors.grey,
      };
}

// ── Subwidgets privados ───────────────────────────────────────────────────────

class _IconBubble extends StatelessWidget {
  final TipoAlerta tipo;

  const _IconBubble({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg) = switch (tipo) {
      TipoAlerta.conflicto => (
          Icons.warning_amber_rounded,
          AppTheme.alertaConflictoFondo,
          AppTheme.alertaConflictoTexto,
        ),
      TipoAlerta.disponibilidad => (
          Icons.calendar_today_outlined,
          AppTheme.alertaDisponibilidadFondo,
          AppTheme.alertaDisponibilidadTexto,
        ),
      TipoAlerta.sistema => (
          Icons.settings_outlined,
          AppTheme.alertaSistemaFondo,
          AppTheme.alertaSistemaTexto,
        ),
      TipoAlerta.desconocido => (
          Icons.help_outline,
          Colors.grey.shade100,
          Colors.grey,
        ),
    };

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: fg),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final EstadoAlerta estado;
  final String display;

  const _EstadoBadge({required this.estado, required this.display});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (estado) {
      EstadoAlerta.pendiente => (
          AppTheme.alertaSistemaFondo,
          AppTheme.alertaSistemaTexto,
        ),
      EstadoAlerta.enviada => (
          AppTheme.alertaDisponibilidadFondo,
          AppTheme.alertaDisponibilidadTexto,
        ),
      EstadoAlerta.leida => (
          const Color(0xFFF1EFE8),
          const Color(0xFF5F5E5A),
        ),
      EstadoAlerta.desconocido => (
          Colors.grey.shade100,
          Colors.grey,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        display,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _DestinatarioLabel extends StatelessWidget {
  final String nombre;

  const _DestinatarioLabel({required this.nombre});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.person_outline, size: 11, color: color),
        const SizedBox(width: 2),
        Text(
          nombre,
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }
}

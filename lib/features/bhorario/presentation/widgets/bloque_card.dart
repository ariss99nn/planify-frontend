// lib/features/bhorario/presentation/widgets/bloque_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/bloque_horario_model.dart';

class BloqueCard extends StatelessWidget {
  final BloqueHorarioModel bloque;
  final VoidCallback?      onTap;

  const BloqueCard({super.key, required this.bloque, this.onTap});

  static Color _jornadaColor(String jornada) => switch (jornada) {
    'MANANA' => AppTheme.primary,
    'TARDE'  => AppTheme.accent,
    'NOCHE'  => const Color(0xFF8B5CF6),
    _        => const Color(0xFFF59E0B),
  };

  @override
  Widget build(BuildContext context) {
    final jColor = _jornadaColor(bloque.jornada);

    return Material(
      color:         AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior:  Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: jColor.withOpacity(0.08),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: AppTheme.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Barra lateral de jornada
                Container(width: 4, color: jColor),

                // Contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila superior: hora + badges
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 15, color: jColor),
                            const SizedBox(width: 6),
                            Text(
                              bloque.rangoHoras,
                              style: TextStyle(
                                color:      jColor,
                                fontSize:   15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            _JornadaBadge(
                                label: bloque.jornadaDisplay, color: jColor),
                            if (bloque.alertasActivas > 0) ...[
                              const SizedBox(width: 8),
                              _AlertaBadge(count: bloque.alertasActivas),
                            ],
                          ],
                        ),

                        // Competencia
                        if (bloque.competenciaNombre != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            bloque.competenciaNombre!,
                            maxLines: 2,
                            overflow:  TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:      AppTheme.textPrimary,
                              fontSize:   15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // Chips de info
                        Wrap(
                          spacing:    12,
                          runSpacing: 6,
                          children: [
                            if (bloque.docenteNombre != null)
                              _InfoChip(
                                  icon:  Icons.person_outline_rounded,
                                  label: bloque.docenteNombre!),
                            if (bloque.aulaCodigo != null)
                              _InfoChip(
                                  icon:  Icons.meeting_room_outlined,
                                  label: 'Aula ${bloque.aulaCodigo}'),
                            if (bloque.fichaCodigo != null)
                              _InfoChip(
                                  icon:  Icons.group_outlined,
                                  label: 'Ficha ${bloque.fichaCodigo}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.chevron_right_rounded,
                      color: AppTheme.border, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JornadaBadge extends StatelessWidget {
  final String label;
  final Color  color;
  const _JornadaBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AlertaBadge extends StatelessWidget {
  final int count;
  const _AlertaBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: const BoxDecoration(
          color: Colors.redAccent, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}
// lib/features/bhorario/presentation/widgets/bloque_detail_sheet.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/bloque_horario_model.dart';

class BloqueDetailSheet extends StatelessWidget {
  final BloqueHorarioModel bloque;
  final bool isManager;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BloqueDetailSheet({
    super.key,
    required this.bloque,
    this.isManager = false,
    this.onEdit,
    this.onDelete,
  });

  static Color _jornadaColor(String j) => switch (j) {
    'MANANA' => AppTheme.primary,
    'TARDE' => AppTheme.accent,
    'NOCHE' => const Color(0xFF8B5CF6),
    _ => const Color(0xFFF59E0B),
  };

  @override
  Widget build(BuildContext context) {
    final jColor = _jornadaColor(bloque.jornada);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: jColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: jColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bloque.diaSemanaDisplay,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          bloque.rangoHoras,
                          style: TextStyle(color: jColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (isManager) ...[
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppTheme.accent,
                      ),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      onPressed: () => _confirmarEliminar(context),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ],
              ),
            ),

            const Divider(color: AppTheme.border, height: 1),

            // Cuerpo scrollable
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.all(20),
                children: [
                  _Seccion(
                    titulo: 'Bloque',
                    filas: [
                      _Fila(
                        Icons.calendar_today_outlined,
                        'Día',
                        bloque.diaSemanaDisplay,
                      ),
                      _Fila(
                        Icons.access_time_rounded,
                        'Horario',
                        bloque.rangoHoras,
                      ),
                      _Fila(
                        Icons.wb_sunny_outlined,
                        'Jornada',
                        bloque.jornadaDisplay,
                      ),
                      _Fila(
                        Icons.repeat_rounded,
                        'Recurrencia',
                        bloque.esRecurrente
                            ? 'Semanal'
                            : 'Fecha: ${bloque.fechaEspecifica ?? '-'}',
                      ),
                      if (bloque.alertasActivas > 0)
                        _Fila(
                          Icons.warning_amber_rounded,
                          'Alertas pendientes',
                          '${bloque.alertasActivas}',
                          valorColor: Colors.amber,
                        ),
                    ],
                  ),
                  if (bloque.docenteNombre != null) ...[
                    const SizedBox(height: 16),
                    _Seccion(
                      titulo: 'Docente',
                      filas: [
                        _Fila(
                          Icons.person_rounded,
                          'Nombre',
                          bloque.docenteNombre!,
                        ),
                        if (bloque.docenteEmail != null)
                          _Fila(
                            Icons.email_outlined,
                            'Correo',
                            bloque.docenteEmail!,
                          ),
                      ],
                    ),
                  ],
                  if (bloque.aulaCodigo != null) ...[
                    const SizedBox(height: 16),
                    _Seccion(
                      titulo: 'Aula',
                      filas: [
                        _Fila(
                          Icons.meeting_room_outlined,
                          'Código',
                          bloque.aulaCodigo!,
                        ),
                        if (bloque.aulaTipo != null)
                          _Fila(
                            Icons.category_outlined,
                            'Tipo',
                            bloque.aulaTipo!,
                          ),
                      ],
                    ),
                  ],
                  if (bloque.fichaCodigo != null) ...[
                    const SizedBox(height: 16),
                    _Seccion(
                      titulo: 'Ficha',
                      filas: [
                        _Fila(
                          Icons.group_outlined,
                          'Código',
                          bloque.fichaCodigo!,
                        ),
                        if (bloque.fichaPrograma != null)
                          _Fila(
                            Icons.school_outlined,
                            'Programa',
                            bloque.fichaPrograma!,
                          ),
                      ],
                    ),
                  ],
                  if (bloque.competenciaNombre != null) ...[
                    const SizedBox(height: 16),
                    _Seccion(
                      titulo: 'Competencia',
                      filas: [
                        _Fila(
                          Icons.book_outlined,
                          'Nombre',
                          bloque.competenciaNombre!,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Eliminar bloque',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Se eliminará el bloque del ${bloque.diaSemanaDisplay} '
          '(${bloque.rangoHoras}). Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ── Helpers de layout ─────────────────────────────────────────────────────

class _Seccion extends StatelessWidget {
  final String titulo;
  final List<_Fila> filas;
  const _Seccion({required this.titulo, required this.filas});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: filas
                .asMap()
                .entries
                .map(
                  (e) => Column(
                    children: [
                      e.value,
                      if (e.key < filas.length - 1)
                        const Divider(
                          color: AppTheme.border,
                          height: 1,
                          indent: 48,
                        ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icon;
  final String etiqueta;
  final String valor;
  final Color? valorColor;

  const _Fila(this.icon, this.etiqueta, this.valor, {this.valorColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            etiqueta,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valorColor ?? AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

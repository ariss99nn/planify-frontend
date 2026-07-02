import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Resultado seleccionado por el usuario para un reporte de Analítica.
class AnaliticaFiltrosResult {
  final List<String> graficas;
  final int diasHistorial;

  const AnaliticaFiltrosResult({
    required this.graficas,
    required this.diasHistorial,
  });

  Map<String, dynamic> toFiltros() => {
        'graficas': graficas,
        'dias_historial': diasHistorial,
      };
}

class _GraficaOpcion {
  final String clave;
  final String label;
  final String descripcion;
  final IconData icono;
  const _GraficaOpcion(this.clave, this.label, this.descripcion, this.icono);
}

const _opcionesGraficas = [
  _GraficaOpcion(
    'tendencia',
    'Tendencia histórica',
    'Fichas, estudiantes, deserciones y graduados en el tiempo',
    Icons.show_chart_rounded,
  ),
  _GraficaOpcion(
    'programas',
    'Comparativo por programa',
    'Avance de horas y estudiantes por cada programa',
    Icons.stacked_bar_chart_rounded,
  ),
  _GraficaOpcion(
    'docentes',
    'Docentes',
    'Docentes activos vs. sobrecargados',
    Icons.school_rounded,
  ),
  _GraficaOpcion(
    'aulas_planes',
    'Aulas, planes y alertas',
    'Estado de aulas, planes aprobados y alertas pendientes',
    Icons.meeting_room_rounded,
  ),
];

/// Muestra el bottom sheet y retorna la selección del usuario, o null si
/// canceló. Úsalo antes de llamar a ReporteProvider.solicitar(tipo: analitica).
Future<AnaliticaFiltrosResult?> mostrarAnaliticaFiltrosSheet(
  BuildContext context,
) {
  return showModalBottomSheet<AnaliticaFiltrosResult>(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _AnaliticaFiltrosSheet(),
  );
}

class _AnaliticaFiltrosSheet extends StatefulWidget {
  const _AnaliticaFiltrosSheet();

  @override
  State<_AnaliticaFiltrosSheet> createState() =>
      _AnaliticaFiltrosSheetState();
}

class _AnaliticaFiltrosSheetState extends State<_AnaliticaFiltrosSheet> {
  final Set<String> _seleccionadas =
      _opcionesGraficas.map((o) => o.clave).toSet(); // todas por defecto
  int _diasHistorial = 90;

  static const _opcionesDias = [30, 90, 180, 365];

  void _confirmar() {
    if (_seleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una gráfica.')),
      );
      return;
    }
    Navigator.of(context).pop(
      AnaliticaFiltrosResult(
        graficas: _opcionesGraficas
            .where((o) => _seleccionadas.contains(o.clave))
            .map((o) => o.clave)
            .toList(),
        diasHistorial: _diasHistorial,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: const [
                Icon(Icons.insights_rounded, color: AppTheme.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Reporte de Analítica con IA',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Elige qué gráficas quieres ver en el PDF y Excel. '
              'La IA redacta el análisis estadístico con los datos reales '
              'de la base de datos.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 18),
            const Text(
              'GRÁFICAS',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ..._opcionesGraficas.map((o) => _GraficaCheckTile(
                  opcion: o,
                  seleccionada: _seleccionadas.contains(o.clave),
                  onChanged: (v) => setState(() {
                    if (v) {
                      _seleccionadas.add(o.clave);
                    } else {
                      _seleccionadas.remove(o.clave);
                    }
                  }),
                )),
            const SizedBox(height: 18),
            const Text(
              'RANGO DE HISTORIAL',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _opcionesDias.map((d) {
                final seleccionado = d == _diasHistorial;
                return ChoiceChip(
                  label: Text(d >= 365 ? '1 año' : '$d días'),
                  selected: seleccionado,
                  onSelected: (_) => setState(() => _diasHistorial = d),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surfaceLight,
                  labelStyle: TextStyle(
                    color: seleccionado ? Colors.black : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmar,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Generar reporte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraficaCheckTile extends StatelessWidget {
  const _GraficaCheckTile({
    required this.opcion,
    required this.seleccionada,
    required this.onChanged,
  });

  final _GraficaOpcion opcion;
  final bool seleccionada;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: seleccionada ? AppTheme.primary.withOpacity(0.08) : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onChanged(!seleccionada),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  opcion.icono,
                  size: 20,
                  color: seleccionada ? AppTheme.primary : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opcion.label,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      Text(
                        opcion.descripcion,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: seleccionada,
                  onChanged: (v) => onChanged(v ?? false),
                  activeColor: AppTheme.primary,
                  checkColor: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
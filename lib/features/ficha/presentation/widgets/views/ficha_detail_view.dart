// lib/features/ficha/presentation/widgets/views/ficha_detail_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/cyber_error_view.dart';
import '../../../../../core/widgets/cyber_loading_view.dart';
import '../../../../../core/widgets/cyber_empty_view.dart';
import '../../../../../core/widgets/glass_panel.dart';
import '../../../../auth/providers/auth_provider.dart';
import '../../providers/ficha_provider.dart';
import '../../../domain/entities/ficha_entity.dart';
import '../../../data/models/ficha_request_model.dart';
import 'ficha_edit_view.dart';
import 'ficha_estudiante_add_view.dart';

class FichaDetailView extends StatefulWidget {
  final int fichaId;
  const FichaDetailView({super.key, required this.fichaId});

  @override
  State<FichaDetailView> createState() => _FichaDetailViewState();
}

class _FichaDetailViewState extends State<FichaDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    Future.microtask(() {
      context.read<FichaProvider>().fetchDetalle(widget.fichaId);
      context.read<FichaProvider>().fetchEstudiantes(widget.fichaId);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  bool get _isManager =>
      context.read<AuthProvider>().puedeGestionarUsuarios;

  Future<void> _showCambiarEtapa(FichaEntity ficha) async {
    if (ficha.esProductiva) return;

    // El paso a Productiva solo se permite si ya se cumplió el tiempo de
    // la etapa lectiva (no quedan trimestres pendientes). El backend valida
    // lo mismo; aquí evitamos el viaje de red si claramente no aplica.
    final restantes = ficha.trimestresRestantes;
    final lectivaCumplida = restantes != null && restantes <= 0;

    if (!lectivaCumplida) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Aún no se puede pasar a Productiva: '
          '${restantes != null ? "quedan $restantes trimestre(s) de la etapa lectiva." : "no se ha cumplido el tiempo de la etapa lectiva."}',
        ),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Cambiar a Productiva',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Ficha ${ficha.codigoFicha} pasará de Lectiva → Productiva.\n'
          'Trimestre actual: ${ficha.trimestre}.\n\n'
          'Esta acción quedará registrada en el historial.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<FichaProvider>();
    final result = await provider.updateEtapa(
      ficha.id,
      const EtapaUpdateRequest(etapa: 'PRODUCTIVA'),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result != null
            ? 'Etapa actualizada a Productiva'
            : (provider.mutationError ?? 'No se pudo actualizar la etapa.')),
        backgroundColor:
            result != null ? AppTheme.primary : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _retirarEstudiante(FichaEstudianteEntity rel) async {
    String? motivoSeleccionado;
    DateTime fechaRetiro = DateTime.now();

    const motivos = {
      'DESERCION': 'Deserción',
      'RETIRO_VOLUNTARIO': 'Retiro voluntario',
      'CANCELADO': 'Cancelado por rendimiento',
      'GRADUADO': 'Graduado',
    };

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text('Retirar a ${rel.estudianteNombre}',
              style: const TextStyle(color: AppTheme.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Motivo de retiro',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                ...motivos.entries.map((e) => RadioListTile<String>(
                      value: e.key,
                      groupValue: motivoSeleccionado,
                      title: Text(e.value,
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 14)),
                      activeColor: AppTheme.primary,
                      onChanged: (v) => setDlg(() => motivoSeleccionado = v),
                    )),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: fechaRetiro,
                      firstDate: rel.fechaIngreso,
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setDlg(() => fechaRetiro = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de retiro',
                      prefixIcon:
                          Icon(Icons.calendar_today, color: AppTheme.primary),
                    ),
                    child: Text(
                      '${fechaRetiro.day.toString().padLeft(2, '0')}/'
                      '${fechaRetiro.month.toString().padLeft(2, '0')}/'
                      '${fechaRetiro.year}',
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: motivoSeleccionado == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('Retirar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<FichaProvider>();
    final result = await provider.updateEstudiante(
      widget.fichaId,
      rel.id,
      UpdateEstudianteRequest(
        activo:       false,
        fechaRetiro:  fechaRetiro,
        motivoRetiro: motivoSeleccionado,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result != null
            ? 'Estudiante retirado correctamente'
            : (provider.mutationError ?? 'No se pudo retirar al estudiante.')),
        backgroundColor:
            result != null ? AppTheme.primary : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<FichaProvider>();
    final ficha     = provider.fichaDetalle;
    final isManager = _isManager;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: Text(
          ficha != null ? 'Ficha ${ficha.codigoFicha}' : 'Detalle',
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          if (ficha != null && isManager) ...[
            if (ficha.esLectiva)
              IconButton(
                icon: const Icon(Icons.swap_horiz, color: AppTheme.accent),
                tooltip: 'Pasar a Productiva',
                onPressed: () => _showCambiarEtapa(ficha),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
              tooltip: 'Editar ficha',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => FichaEditView(fichaId: ficha.id)),
                ).then((_) {
                  if (!mounted) return;
                  context.read<FichaProvider>().fetchDetalle(widget.fichaId);
                });
              },
            ),
          ],
        ],
      ),
      body: provider.loadingDetalle
          ? const CyberLoadingView(mensaje: 'Cargando ficha…')
          : ficha == null
              ? CyberErrorView(
                  message: provider.detalleError ?? 'No se pudo cargar la ficha',
                  onRetry: () =>
                      context.read<FichaProvider>().fetchDetalle(widget.fichaId),
                )
              : Column(
                  children: [
                    _FichaHeader(ficha: ficha),
                    Container(
                      color: AppTheme.surface,
                      child: TabBar(
                        controller: _tabCtrl,
                        indicatorColor: AppTheme.primary,
                        labelColor: AppTheme.primary,
                        unselectedLabelColor: AppTheme.textSecondary,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                        tabs: const [
                          Tab(text: 'INFO'),
                          Tab(text: 'ESTUDIANTES'),
                          Tab(text: 'HISTORIAL'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _InfoTab(ficha: ficha),
                          _EstudiantesTab(
                            fichaActiva: ficha.estaActiva,
                            isManager:   isManager,
                            onRetirar:   _retirarEstudiante,
                          ),
                          _HistorialTab(
                              historial: ficha.historialEtapasReciente),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: ficha != null && ficha.estaActiva && isManager
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          FichaEstudianteAddView(fichaId: widget.fichaId)),
                ).then((_) {
                  if (!mounted) return;
                  context
                      .read<FichaProvider>()
                      .fetchEstudiantes(widget.fichaId);
                });
              },
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.background,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Agregar estudiante',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }
}

// ── _FichaHeader ───────────────────────────────────────────────────────────────

class _FichaHeader extends StatelessWidget {
  final FichaEntity ficha;
  const _FichaHeader({required this.ficha});

  Color get _estadoColor {
    switch (ficha.estado) {
      case 'ACTIVA':   return AppTheme.primary;
      case 'INACTIVA': return Colors.orange;
      case 'CERRADA':  return Colors.red.shade400;
      default:         return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ficha.programaNombre,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17)),
                    const SizedBox(height: 2),
                    Text('${ficha.programaNivel} · v${ficha.versionNumero}',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary.withOpacity(0.7))),
                  ],
                ),
              ),
              _HeaderBadge(label: ficha.estado, color: _estadoColor),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metrica(
                icon: Icons.school_outlined,
                label: 'Etapa',
                value: ficha.etapaDisplay,
                color: ficha.esProductiva ? AppTheme.accent : AppTheme.primary,
              ),
              _HDivider(),
              _Metrica(
                icon: Icons.calendar_today_outlined,
                label: 'Trimestre',
                value: '${ficha.trimestre}',
                color: AppTheme.textPrimary,
              ),
              _HDivider(),
              _Metrica(
                icon: Icons.people_outline,
                label: 'Estudiantes',
                value:
                    '${ficha.numeroEstudiantesReal}/${ficha.numeroEstudiantesEstimado}',
                color: AppTheme.textPrimary,
              ),
              if (ficha.trimestresRestantes != null) ...[
                _HDivider(),
                _Metrica(
                  icon: Icons.timer_outlined,
                  label: 'Restantes',
                  value: '${ficha.trimestresRestantes}T',
                  color: AppTheme.accent,
                ),
              ],
            ],
          ),
          if (ficha.cadenaFormacion) ...[
            const SizedBox(height: 12),
            _HeaderBadge(
                label: 'Cadena de formación',
                color: AppTheme.accent,
                icon: Icons.link),
          ],
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _Metrica(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          Text(label,
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 10)),
        ],
      ),
    );
  }
}

class _HDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: AppTheme.border.withOpacity(0.5));
}

class _HeaderBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _HeaderBadge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ── _InfoTab ───────────────────────────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  final FichaEntity ficha;
  const _InfoTab({required this.ficha});

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SeccionTitulo('Información general'),
        _InfoRow('Código ficha', ficha.codigoFicha),
        _InfoRow('Programa', ficha.programaNombre),
        _InfoRow('Nivel', ficha.programaNivel),
        _InfoRow('Versión', 'v${ficha.versionNumero}'),
        _InfoRow('Jornada', ficha.jornadaDisplay),
        _InfoRow('Horas semanales', '${ficha.horasSemanalesObjetivo} h'),
        _InfoRow('Fecha inicio', _fmt(ficha.fechaInicio)),
        _InfoRow('Fecha fin estimada', _fmt(ficha.fechaFinalizacion)),
        const SizedBox(height: 20),
        _SeccionTitulo('Capacidad'),
        GlassPanel(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: _CapacidadMetrica(
                  label: 'Estimado',
                  valor: '${ficha.numeroEstudiantesEstimado}',
                  ayuda: 'Fijo desde la creación',
                ),
              ),
              Expanded(
                child: _CapacidadMetrica(
                  label: 'Reales',
                  valor: '${ficha.numeroEstudiantesReal}',
                  ayuda: 'Estudiantes activos hoy',
                  color: AppTheme.accent,
                ),
              ),
              Expanded(
                child: _CapacidadMetrica(
                  label: 'Disponible',
                  valor: '${ficha.cupoDisponible}',
                  ayuda: 'Cupos libres',
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
        if (ficha.cadenaFormacion && ficha.trimestresAhorradosCadena > 0) ...[
          const SizedBox(height: 10),
          GlassPanel(
            padding: const EdgeInsets.all(12),
            accent: AppTheme.accent,
            child: Row(
              children: [
                const Icon(Icons.link, color: AppTheme.accent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cadena de formación: se ahorra ${ficha.trimestresAhorradosCadena} '
                    'trimestre(s) frente a la oferta estándar del programa '
                    '(${ficha.trimestresTotalesModalidad ?? '—'} en total).',
                    style: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.85),
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (ficha.distribucionSemanalSugerida.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SeccionTitulo('Distribución semanal sugerida'),
          GlassPanel(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ficha.distribucionSemanalSugerida.map((d) {
                final esSabado = d['dia'] == 'SABADO';
                return GlassBadge(
                  label: '${_capitalizar(d['dia'] as String)} · ${d['horas']}h',
                  icon: esSabado ? Icons.event_busy : Icons.event_available,
                  color: esSabado ? Colors.amber : AppTheme.primary,
                );
              }).toList(),
            ),
          ),
          if (ficha.distribucionSemanalSugerida.any((d) => d['dia'] == 'SABADO'))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Incluye sábado: las horas de esta jornada no alcanzan a '
                'cubrirse de lunes a viernes.',
                style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 11),
              ),
            ),
        ],
        if (ficha.calendarioTrimestres.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SeccionTitulo('Calendario de trimestres'),
          GlassPanel(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: ficha.calendarioTrimestres.map((t) {
                final numero = t['trimestre'];
                final esActual = numero == ficha.trimestre;
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: esActual
                        ? AppTheme.primary
                        : AppTheme.surface.withOpacity(0.4),
                    child: Text('$numero',
                        style: TextStyle(
                            fontSize: 11,
                            color: esActual ? Colors.black : AppTheme.textSecondary)),
                  ),
                  title: Text(
                    '${t['fecha_inicio']} → ${t['fecha_fin']}',
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
                  ),
                  trailing: esActual
                      ? const Text('Actual',
                          style: TextStyle(color: AppTheme.primary, fontSize: 11))
                      : null,
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 20),
        _SeccionTitulo('Jefe de grupo'),
        _InfoRow('Nombre', ficha.jefeGrupoNombre ?? 'Sin asignar'),
        _InfoRow('Email', ficha.jefeGrupoEmail ?? '—'),
        _InfoRow('Especialidad', ficha.jefeGrupoEspecialidad ?? '—'),
        const SizedBox(height: 20),
        _SeccionTitulo('Registro'),
        _InfoRow('Creado', _fmt(ficha.createdAt)),
        _InfoRow('Actualizado', _fmt(ficha.updatedAt)),
      ],
    );
  }

  String _capitalizar(String dia) {
    const nombres = {
      'LUNES': 'Lun', 'MARTES': 'Mar', 'MIERCOLES': 'Mié',
      'JUEVES': 'Jue', 'VIERNES': 'Vie', 'SABADO': 'Sáb',
    };
    return nombres[dia] ?? dia;
  }
}

class _CapacidadMetrica extends StatelessWidget {
  final String label;
  final String valor;
  final String ayuda;
  final Color color;
  const _CapacidadMetrica({
    required this.label,
    required this.valor,
    required this.ayuda,
    this.color = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(ayuda,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.55), fontSize: 9)),
      ],
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(titulo,
          style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 2)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.7),
                    fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ── _EstudiantesTab ────────────────────────────────────────────────────────────

class _EstudiantesTab extends StatelessWidget {
  final bool fichaActiva;
  final bool isManager;
  final Future<void> Function(FichaEstudianteEntity) onRetirar;

  const _EstudiantesTab({
    required this.fichaActiva,
    required this.isManager,
    required this.onRetirar,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FichaProvider>();

    if (provider.loadingEstudiantes) {
      return const CyberLoadingView(mensaje: 'Cargando estudiantes…');
    }
    if (provider.estudiantes.isEmpty) {
      return const CyberEmptyView(
        icon: Icons.people_outline,
        title: 'Sin estudiantes',
        subtitle: 'Agrega estudiantes con el botón inferior',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: provider.estudiantes.length,
      itemBuilder: (_, i) {
        final rel = provider.estudiantes[i];
        return _EstudianteCard(
          rel:          rel,
          puedeRetirar: rel.activo && fichaActiva && isManager,
          onRetirar:    () => onRetirar(rel),
        );
      },
    );
  }
}

class _EstudianteCard extends StatelessWidget {
  final FichaEstudianteEntity rel;
  final bool puedeRetirar;
  final VoidCallback onRetirar;

  const _EstudianteCard({
    required this.rel,
    required this.puedeRetirar,
    required this.onRetirar,
  });

  @override
  Widget build(BuildContext context) {
    final iniciales = rel.estudianteNombre.isNotEmpty
        ? rel.estudianteNombre
            .split(' ')
            .take(2)
            .map((p) => p.isNotEmpty ? p[0] : '')
            .join()
            .toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: rel.activo
                      ? AppTheme.primary.withOpacity(0.4)
                      : Colors.red.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(iniciales,
                  style: TextStyle(
                      color: rel.activo
                          ? AppTheme.primary
                          : Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rel.estudianteNombre,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(rel.estudianteEmail,
                    style: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.6),
                        fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    _MiniTag(
                      label: rel.activo ? 'Activo' : 'Retirado',
                      color: rel.activo
                          ? AppTheme.primary
                          : Colors.red.shade400,
                    ),
                    if (rel.esCadena)
                      _MiniTag(label: 'Cadena', color: AppTheme.accent),
                    if (rel.motivoRetiroDisplay != null)
                      _MiniTag(
                          label: rel.motivoRetiroDisplay!,
                          color: AppTheme.textSecondary),
                  ],
                ),
                if (rel.horasRestantesParaProductiva != null && rel.activo) ...[
                  const SizedBox(height: 4),
                  Text(
                    '~${rel.horasRestantesParaProductiva} h para productiva',
                    style: TextStyle(
                        color: AppTheme.accent.withOpacity(0.8),
                        fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          if (puedeRetirar)
            IconButton(
              icon: Icon(Icons.person_remove_outlined,
                  color: Colors.red.shade400, size: 20),
              tooltip: 'Retirar estudiante',
              onPressed: onRetirar,
            ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ── _HistorialTab ──────────────────────────────────────────────────────────────

class _HistorialTab extends StatelessWidget {
  final List<HistorialEtapaEntity> historial;
  const _HistorialTab({required this.historial});

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty) {
      return const CyberEmptyView(
        icon: Icons.history,
        title: 'Sin historial de etapas',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historial.length,
      itemBuilder: (_, i) {
        final h = historial[i];
        final fecha =
            '${h.fecha.day.toString().padLeft(2, '0')}/'
            '${h.fecha.month.toString().padLeft(2, '0')}/${h.fecha.year}';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz, color: AppTheme.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(h.etapaAnteriorDisplay,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward,
                              size: 14, color: AppTheme.primary),
                        ),
                        Text(h.etapaNuevaDisplay,
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trimestre ${h.trimestre} · $fecha',
                      style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.6),
                          fontSize: 11),
                    ),
                    if (h.cambiadoPorNombre != null)
                      Text('Por: ${h.cambiadoPorNombre}',
                          style: TextStyle(
                              color: AppTheme.textSecondary.withOpacity(0.5),
                              fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

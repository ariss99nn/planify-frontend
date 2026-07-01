import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme.dart';
import '../../data/repositories_impl/novedad_repository_impl.dart';
import '../../data/repositories_impl/reporte_repository_impl.dart';
import '../providers/novedad_provider.dart';
import '../providers/reporte_provider.dart';
import '../widgets/views/novedad_form_view.dart';
import '../widgets/views/novedades_list_view.dart';
import '../widgets/views/reporte_estado_view.dart';
import '../widgets/views/reportes_view.dart';

enum _ReportesTab { reportes, novedades }

class ReportesGestionScreen extends StatefulWidget {
  const ReportesGestionScreen({
    super.key,
    required this.userRole,
  });

  final String userRole;

  @override
  State<ReportesGestionScreen> createState() => _ReportesGestionScreenState();
}

class _ReportesGestionScreenState extends State<ReportesGestionScreen> {
  _ReportesTab _tab = _ReportesTab.reportes;

  // Navegación interna del módulo
  int? _reporteEstadoId;
  bool _mostrandoFormNovedad = false;

  late final NovedadProvider _novedadProvider;
  late final ReporteProvider _reporteProvider;

  @override
  void initState() {
    super.initState();
    _novedadProvider = NovedadProvider(repository: NovedadRepositoryImpl());
    _reporteProvider = ReporteProvider(repository: ReporteRepositoryImpl());
    _novedadProvider.cargarInicial();
  }

  @override
  void dispose() {
    _novedadProvider.dispose();
    _reporteProvider.dispose();
    super.dispose();
  }

  void _irAEstadoReporte(int id) {
    setState(() {
      _reporteEstadoId = id;
      _tab = _ReportesTab.reportes;
    });
  }

  void _volverAReportes() {
    setState(() => _reporteEstadoId = null);
  }

  void _abrirFormNovedad() {
    setState(() => _mostrandoFormNovedad = true);
  }

  void _volverANovedades() {
    setState(() => _mostrandoFormNovedad = false);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _novedadProvider),
        ChangeNotifierProvider.value(value: _reporteProvider),
      ],
      child: Scaffold(
        appBar: _buildAppBar(),
        bottomNavigationBar: _buildBottomNav(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final String titulo;
    final bool mostrarBack;

    if (_reporteEstadoId != null) {
      titulo = 'Estado del reporte';
      mostrarBack = true;
    } else if (_mostrandoFormNovedad) {
      titulo = 'Nueva novedad';
      mostrarBack = true;
    } else {
      titulo = _tab == _ReportesTab.reportes ? 'Reportes' : 'Novedades';
      mostrarBack = false;
    }

    return AppBar(
      title: Text(titulo),
      leading: mostrarBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _reporteEstadoId != null
                  ? _volverAReportes
                  : _volverANovedades,
            )
          : null,
      backgroundColor: AppTheme.background,
      elevation: 0,
    );
  }

  Widget _buildBottomNav() {
    if (_reporteEstadoId != null || _mostrandoFormNovedad) {
      return const SizedBox.shrink();
    }
    return NavigationBar(
      selectedIndex: _tab.index,
      onDestinationSelected: (i) {
        setState(() => _tab = _ReportesTab.values[i]);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.summarize_outlined),
          selectedIcon: Icon(Icons.summarize_rounded),
          label: 'Reportes',
        ),
        NavigationDestination(
          icon: Icon(Icons.report_outlined),
          selectedIcon: Icon(Icons.report_rounded),
          label: 'Novedades',
        ),
      ],
    );
  }

  Widget _buildBody() {
    // Subvista: estado de reporte activo
    if (_reporteEstadoId != null) {
      return ReporteEstadoView(reporteId: _reporteEstadoId!);
    }

    // Subvista: formulario nueva novedad
    if (_mostrandoFormNovedad) {
      return NovedadFormView(
        provider: _novedadProvider,
        onGuardado: _volverANovedades,
      );
    }

    switch (_tab) {
      case _ReportesTab.reportes:
        return ReportesView(
          userRole: widget.userRole,
          onVerEstado: _irAEstadoReporte,
        );
      case _ReportesTab.novedades:
        return NovedadesListView(
          onCrear: _abrirFormNovedad,
        );
    }
  }
}

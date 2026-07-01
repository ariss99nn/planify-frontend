import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/exportacion_provider.dart';
import '../widgets/views/exportar_view.dart';
import '../widgets/views/historial_view.dart';

/// Pantalla de entrada del módulo de exportación.
/// Crea [ExportacionProvider] con alcance de pantalla — no es global.
class ExportacionGestionScreen extends StatelessWidget {
  const ExportacionGestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExportacionProvider(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Exportación de datos'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.download_rounded),  text: 'Exportar'),
                Tab(icon: Icon(Icons.history_rounded),   text: 'Historial'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [ExportarView(), HistorialView()],
          ),
        ),
      ),
    );
  }
}

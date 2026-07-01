// lib/features/programa/presentation/screens/programa_gestion_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/role_helper.dart';
import '../../../../core/theme/theme.dart';
import '../providers/programa_provider.dart';
import '../providers/version_provider.dart';
import '../providers/modulo_provider.dart';
import '../widgets/views/programa_list_view.dart';
import '../widgets/views/programa_form_view.dart';

/// Punto de entrada único al módulo de programas.
///
/// Inyecta los tres providers del módulo —[ProgramaProvider],
/// [VersionProvider] y [ModuloProvider]— de modo que todas las
/// views descendientes los encuentren en el árbol sin necesidad
/// de providers globales o inyección adicional en main.dart.
///
/// La navegación interna entre listado → detalle → formularios se
/// gestiona mediante [Navigator.push] dentro de cada view, por lo
/// que esta pantalla solo necesita mostrar la [ProgramaListView]
/// como raíz.
class ProgramaGestionScreen extends StatelessWidget {
  const ProgramaGestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canManage = isManagerRole(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgramaProvider()),
        ChangeNotifierProvider(create: (_) => VersionProvider()),
        ChangeNotifierProvider(create: (_) => ModuloProvider()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Programas'),
        ),
        floatingActionButton: canManage
            ? Consumer<ProgramaProvider>(
                builder: (context, provider, _) => FloatingActionButton.extended(
                  heroTag: 'fab_nuevo_programa',
                  onPressed: () async {
                    final created = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: provider,
                          child: const ProgramaFormView(),
                        ),
                      ),
                    );
                    if (created != null) provider.fetchList();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo programa'),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.background,
                ),
              )
            : null,
        body: const ProgramaListView(),
      ),
    );
  }
}

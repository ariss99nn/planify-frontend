import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/asignatura_provider.dart';
import '../providers/competencia_provider.dart';
import '../providers/rap_provider.dart';
import '../../../../core/theme/theme.dart';
import 'asignatura_list_screen.dart';
import 'competencia_list_screen.dart';
import 'rap_list_screen.dart';

class CompetenciasGestionScreen extends StatefulWidget {
  final String userRole;

  const CompetenciasGestionScreen({super.key, required this.userRole});

  @override
  State<CompetenciasGestionScreen> createState() =>
      _CompetenciasGestionScreenState();
}

class _CompetenciasGestionScreenState extends State<CompetenciasGestionScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AsignaturaProvider()),
        ChangeNotifierProvider(create: (_) => CompetenciaProvider()),
        ChangeNotifierProvider(create: (_) => RapProvider()),
      ],
      child: Builder(
        builder: (ctx) {
          final tabs = <Widget>[
            AsignaturaListScreen(userRole: widget.userRole),
            CompetenciaListScreen(userRole: widget.userRole),
            RapListScreen(userRole: widget.userRole),
          ];

          return Scaffold(
            body: IndexedStack(index: _index, children: tabs),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              backgroundColor: AppTheme.surface,
              indicatorColor: AppTheme.primary.withOpacity(0.15),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.class_rounded),
                  label: 'Asignaturas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.psychology_rounded),
                  label: 'Competencias',
                ),
                NavigationDestination(
                  icon: Icon(Icons.task_alt_rounded),
                  label: 'RAPs',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

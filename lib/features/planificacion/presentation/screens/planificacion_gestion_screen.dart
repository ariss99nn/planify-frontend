// lib/features/planificacion/presentation/screens/planificacion_gestion_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/planificacion_provider.dart';
import '../widgets/views/plan_list_view.dart';

/// Punto de entrada único del módulo de planificación.
/// Inicializa el [PlanificacionProvider] y delega la coordinación a [PlanListView].
class PlanificacionGestionScreen extends StatelessWidget {
  const PlanificacionGestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlanificacionProvider(),
      child: const PlanListView(),
    );
  }
}

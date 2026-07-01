// lib/features/aulas/presentation/screens/aulas_gestion_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_roles.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/aula_provider.dart';
import '../providers/bloque_provider.dart';
import '../providers/equipamiento_provider.dart';
import '../widgets/views/aula_form_view.dart';
import '../widgets/views/aula_list_view.dart';
import '../widgets/views/bloque_form_view.dart';
import '../widgets/views/bloque_list_view.dart';
import '../widgets/views/equipamiento_form_view.dart';
import '../widgets/views/equipamiento_list_view.dart';

class AulasGestionScreen extends StatefulWidget {
  const AulasGestionScreen({super.key});

  @override
  State<AulasGestionScreen> createState() => _AulasGestionScreenState();
}

class _AulasGestionScreenState extends State<AulasGestionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rol      = context.watch<AuthProvider>().user?.rol ?? '';
    final canWrite = AppRoles.managers.contains(rol);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GESTIÓN',
          style: TextStyle(letterSpacing: 2.5, fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 2.5,
          labelPadding: const EdgeInsets.only(bottom: 6),
          tabs: const [
            Tab(text: 'Bloques',    icon: Icon(Icons.business,           size: 20)),
            Tab(text: 'Aulas',      icon: Icon(Icons.meeting_room_rounded, size: 20)),
            Tab(text: 'Equipo',     icon: Icon(Icons.devices_other,      size: 20)),
          ],
        ),
      ),
      floatingActionButton: canWrite
          ? AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) => FloatingActionButton(
                heroTag: 'fab_aulas',
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                tooltip: switch (_tabController.index) {
                  0 => 'Nuevo bloque',
                  1 => 'Nueva aula',
                  _ => 'Nuevo equipamiento',
                },
                onPressed: _onFabPressed,
                child: const Icon(Icons.add),
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          BloqueListView(canWrite: canWrite),
          AulaListView(canWrite: canWrite),
          EquipamientoListView(canWrite: canWrite),
        ],
      ),
    );
  }

  void _onFabPressed() {
    final tab = _tabController.index;
    final route = switch (tab) {
      0 => MaterialPageRoute(builder: (_) => const BloqueFormView()),
      1 => MaterialPageRoute(builder: (_) => const AulaFormView()),
      _ => MaterialPageRoute(builder: (_) => const EquipamientoFormView()),
    };
    Navigator.push(context, route).then((_) {
      if (!mounted) return;
      switch (tab) {
        case 0: context.read<BloqueProvider>().fetchBloques();
        case 1: context.read<AulaProvider>().fetchAulas();
        case 2: context.read<EquipamientoProvider>().fetchEquipamientos();
      }
    });
  }
}
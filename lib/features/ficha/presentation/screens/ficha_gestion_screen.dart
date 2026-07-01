// lib/features/ficha/presentation/screens/ficha_gestion_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/ficha_provider.dart';
import '../widgets/views/ficha_list_view.dart';
import '../widgets/views/historial_view.dart';
import '../widgets/views/reasignacion_list_view.dart';

class FichaGestionScreen extends StatefulWidget {
  const FichaGestionScreen({super.key});

  @override
  State<FichaGestionScreen> createState() => _FichaGestionScreenState();
}

class _FichaGestionScreenState extends State<FichaGestionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _tabs = [
    Tab(icon: Icon(Icons.folder_copy_outlined, size: 18), text: 'FICHAS'),
    Tab(icon: Icon(Icons.history, size: 18),             text: 'HISTORIAL'),
    Tab(icon: Icon(Icons.swap_horiz, size: 18),          text: 'REASIGNACIONES'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  bool get _isManager =>
      context.read<AuthProvider>().puedeGestionarUsuarios;

  @override
  Widget build(BuildContext context) {
    final canWrite  = _isManager;

    return ChangeNotifierProvider(
      create: (_) => FichaProvider(),
      child: Builder(
        builder: (ctx) => Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            foregroundColor: AppTheme.textPrimary,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'FICHAS',
              style: TextStyle(
                color:       AppTheme.primary,
                fontWeight:  FontWeight.w800,
                fontSize:    18,
                letterSpacing: 3,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: AppTheme.border.withOpacity(0.3))),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 2,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor:
                      AppTheme.textSecondary.withOpacity(0.5),
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1),
                  tabs: _tabs,
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              FichaListView(canWrite: canWrite),
              const HistorialView(),
              ReasignacionListView(canWrite: canWrite),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/features/docentes/presentation/screens/docente_gestion_screen.dart

import 'package:flutter/material.dart';
import '../widgets/views/docente_list_view.dart';
import '../widgets/views/docente_detail_view.dart';
import '../widgets/views/disponibilidad_view.dart';
import '../widgets/views/habilitacion_view.dart';

enum _DocenteView {
  list,
  create,
  detail,
  edit,
  disponibilidad,
  habilitaciones,
}

class DocenteGestionScreen extends StatefulWidget {
  final bool canManage;

  const DocenteGestionScreen({super.key, this.canManage = true});

  @override
  State<DocenteGestionScreen> createState() => _DocenteGestionScreenState();
}

class _DocenteGestionScreenState extends State<DocenteGestionScreen> {
  _DocenteView _current = _DocenteView.list;
  int?         _selectedId;

  void _goList() => setState(() {
        _current    = _DocenteView.list;
        _selectedId = null;
      });

  void _goCreate() => setState(() => _current = _DocenteView.create);

  void _goDetail(int id) => setState(() {
        _current    = _DocenteView.detail;
        _selectedId = id;
      });

  void _goEdit(int id) => setState(() {
        _current    = _DocenteView.edit;
        _selectedId = id;
      });

  void _goDisponibilidad(int id) => setState(() {
        _current    = _DocenteView.disponibilidad;
        _selectedId = id;
      });

  void _goHabilitaciones(int id) => setState(() {
        _current    = _DocenteView.habilitaciones;
        _selectedId = id;
      });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _current == _DocenteView.list,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          switch (_current) {
            case _DocenteView.detail:
              _goList();
            case _DocenteView.create:
              _goList();
            case _DocenteView.edit:
              _goDetail(_selectedId!);
            case _DocenteView.disponibilidad:
              _goDetail(_selectedId!);
            case _DocenteView.habilitaciones:
              _goDetail(_selectedId!);
            case _DocenteView.list:
              break;
          }
        }
      },
      child: _buildView(),
    );
  }

  Widget _buildView() {
    switch (_current) {
      case _DocenteView.list:
        return DocenteListView(
          onDetail:    _goDetail,
          onCreateTap: _goCreate,
        );

      case _DocenteView.create:
        return DocenteCreateView(
          onCreated: _goList,
        );

      case _DocenteView.detail:
        return DocenteDetailView(
          docenteId:          _selectedId!,
          onEditTap:          _goEdit,
          onDisponibilidadTap: _goDisponibilidad,
          onHabilitacionesTap: _goHabilitaciones,
        );

      case _DocenteView.edit:
        return DocenteEditView(
          docenteId: _selectedId!,
          onUpdated: () => _goDetail(_selectedId!),
        );

      case _DocenteView.disponibilidad:
        return DisponibilidadView(docenteId: _selectedId!);

      case _DocenteView.habilitaciones:
        return HabilitacionView(
          docenteId: _selectedId,
          canManage: widget.canManage,
        );
    }
  }
}

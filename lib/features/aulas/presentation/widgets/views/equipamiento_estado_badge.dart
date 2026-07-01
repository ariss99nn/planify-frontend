// lib/features/aulas/presentation/widgets/views/equipamiento_estado_badge.dart

import '../../../../../core/widgets/widgets.dart';

CyberEstadoBadge equipamientoEstadoBadge(String estado, String display) =>
    switch (estado) {
      'FUNC' => CyberEstadoBadge.activa(label: display),
      'DAN'  => CyberEstadoBadge.inactiva(label: display),
      'MANT' => CyberEstadoBadge.mantenimiento(label: display),
      _      => CyberEstadoBadge.fromCodigo(estado, display),
    };
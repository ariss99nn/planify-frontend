import 'package:flutter/material.dart';

import '../../domain/entities/registro_exportacion_entity.dart';

class RegistroTile extends StatelessWidget {
  const RegistroTile({super.key, required this.registro});

  final RegistroExportacionEntity registro;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.description_outlined, size: 20),
      title: Text(registro.usuarioNombre),
      subtitle: Text(
        '${registro.tipoDisplay} · ${registro.formatoDisplay} · '
        '${registro.registrosExportados} registros',
      ),
      trailing: Text(
        '${registro.fecha.day.toString().padLeft(2, '0')}/'
        '${registro.fecha.month.toString().padLeft(2, '0')}/'
        '${registro.fecha.year}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

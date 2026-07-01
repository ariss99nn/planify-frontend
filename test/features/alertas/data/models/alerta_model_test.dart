import 'package:flutter_test/flutter_test.dart';

import 'package:your_app/features/alertas/data/models/alerta_model.dart';
import 'package:your_app/features/alertas/domain/entities/alerta_entity.dart';

void main() {
  group('AlertaModel.fromJson', () {
    final validJson = {
      'id': 1,
      'tipo': 'CONFLICTO',
      'tipo_display': 'Conflicto',
      'estado': 'PENDIENTE',
      'estado_display': 'Pendiente',
      'formato_alerta': 'APP',
      'formato_display': 'App',
      'descripcion': 'Test de alerta',
      'destinatario': 42,
      'destinatario_nombre': 'Juan Pérez',
      'bloque_origen': null,
      'fecha_creacion': '2026-06-01T10:00:00Z',
      'fecha_lectura': null,
    };

    test('parsea correctamente todos los campos', () {
      final model = AlertaModel.fromJson(validJson);

      expect(model.id, 1);
      expect(model.tipo, TipoAlerta.conflicto);
      expect(model.estado, EstadoAlerta.pendiente);
      expect(model.formatoAlerta, FormatoAlerta.app);
      expect(model.descripcion, 'Test de alerta');
      expect(model.destinatarioId, 42);
      expect(model.fechaLectura, isNull);
    });

    test('usa TipoAlerta.desconocido para valores inesperados del backend', () {
      final json = {...validJson, 'tipo': 'NUEVO_TIPO_FUTURO'};
      final model = AlertaModel.fromJson(json);
      // No debe lanzar excepción; devuelve desconocido como fallback.
      expect(model.tipo, TipoAlerta.desconocido);
    });

    test('usa EstadoAlerta.desconocido para estados inesperados', () {
      final json = {...validJson, 'estado': 'ARCHIVADA'};
      final model = AlertaModel.fromJson(json);
      expect(model.estado, EstadoAlerta.desconocido);
    });

    test('parsea fecha_lectura cuando está presente', () {
      final json = {...validJson, 'fecha_lectura': '2026-06-01T12:00:00Z'};
      final model = AlertaModel.fromJson(json);
      expect(model.fechaLectura, isNotNull);
      expect(model.fechaLectura!.hour, 12);
    });
  });

  group('AlertaModel.toEntity', () {
    test('mapea correctamente a AlertaEntity', () {
      final model = AlertaModel.fromJson({
        'id': 5,
        'tipo': 'SISTEMA',
        'tipo_display': 'Sistema',
        'estado': 'LEIDA',
        'estado_display': 'Leída',
        'formato_alerta': 'EMAIL',
        'formato_display': 'Email',
        'descripcion': 'Alerta de sistema',
        'destinatario': null,
        'destinatario_nombre': null,
        'bloque_origen': null,
        'fecha_creacion': '2026-06-01T08:00:00Z',
        'fecha_lectura': '2026-06-01T09:00:00Z',
      });

      final entity = model.toEntity();

      expect(entity.id, 5);
      expect(entity.tipo, TipoAlerta.sistema);
      expect(entity.estado, EstadoAlerta.leida);
      expect(entity.isLeida, isTrue);
      expect(entity.destinatarioId, isNull);
    });
  });
}

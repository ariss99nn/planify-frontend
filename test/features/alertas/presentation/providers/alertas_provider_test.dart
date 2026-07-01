import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:your_app/core/error/failures.dart';
import 'package:your_app/features/alertas/domain/entities/alerta_entity.dart';
import 'package:your_app/features/alertas/domain/repositories/alerta_repository.dart';
import 'package:your_app/features/alertas/domain/usecases/listar_alertas_usecase.dart';
import 'package:your_app/features/alertas/domain/usecases/marcar_alerta_leida_usecase.dart';
import 'package:your_app/features/alertas/presentation/providers/alertas_provider.dart';

class MockListarAlertasUseCase extends Mock implements ListarAlertasUseCase {}
class MockMarcarAlertaLeidaUseCase extends Mock implements MarcarAlertaLeidaUseCase {}

// Necesario para mocktail al registrar fallbacks.
class FakeAlertaFiltros extends Fake implements AlertaFiltros {}
class FakeAlertaEntity extends Fake implements AlertaEntity {}

AlertaEntity _makeAlerta({
  int id = 1,
  EstadoAlerta estado = EstadoAlerta.pendiente,
  int? destinatarioId = 10,
}) =>
    AlertaEntity(
      id: id,
      tipo: TipoAlerta.conflicto,
      tipoDisplay: 'Conflicto',
      estado: estado,
      estadoDisplay: 'Pendiente',
      formatoAlerta: FormatoAlerta.app,
      formatoDisplay: 'App',
      descripcion: 'Test alerta $id',
      destinatarioId: destinatarioId,
      fechaCreacion: DateTime.now(),
    );

void main() {
  late MockListarAlertasUseCase mockListar;
  late MockMarcarAlertaLeidaUseCase mockMarcar;
  late AlertasProvider provider;

  setUpAll(() {
    registerFallbackValue(FakeAlertaFiltros());
    registerFallbackValue(FakeAlertaEntity());
  });

  setUp(() {
    mockListar = MockListarAlertasUseCase();
    mockMarcar = MockMarcarAlertaLeidaUseCase();
    provider = AlertasProvider(listar: mockListar, marcarLeida: mockMarcar);
  });

  group('AlertasProvider.cargar()', () {
    test('pasa a loaded con alertas al tener éxito', () async {
      final alertas = [_makeAlerta(id: 1), _makeAlerta(id: 2)];
      when(() => mockListar(any())).thenAnswer(
        (_) async => Right(AlertaPage(items: alertas, count: 2, hasMore: false)),
      );

      await provider.cargar();

      expect(provider.status, AlertasStatus.loaded);
      expect(provider.alertas.length, 2);
      expect(provider.errorMessage, isNull);
    });

    test('pasa a error con mensaje al fallar', () async {
      when(() => mockListar(any())).thenAnswer(
        (_) async => const Left(NetworkFailure('Sin conexión.')),
      );

      await provider.cargar();

      expect(provider.status, AlertasStatus.error);
      expect(provider.errorMessage, isNotNull);
    });

    test('resetea paginación en cada carga', () async {
      when(() => mockListar(any())).thenAnswer(
        (_) async => Right(AlertaPage(items: [], count: 0, hasMore: false)),
      );

      await provider.cargar();
      await provider.cargar();

      expect(provider.alertas, isEmpty);
    });
  });

  group('AlertasProvider.aplicarFiltros()', () {
    test('no recarga si los filtros no cambian', () async {
      when(() => mockListar(any())).thenAnswer(
        (_) async => Right(AlertaPage(items: [], count: 0, hasMore: false)),
      );

      provider.aplicarFiltros(estado: 'PENDIENTE', tipo: null);
      provider.aplicarFiltros(estado: 'PENDIENTE', tipo: null); // mismo

      await Future.microtask(() {}); // deja que el async se ejecute
      // Solo debe haberse llamado una vez.
      verify(() => mockListar(any())).called(1);
    });
  });

  group('AlertasProvider.marcarLeida()', () {
    test('actualiza la alerta en la lista al marcar como leída', () async {
      final alerta = _makeAlerta(id: 1, estado: EstadoAlerta.pendiente);
      final updated = alerta.copyWith(estado: EstadoAlerta.leida);

      // Precarga la lista con la alerta.
      when(() => mockListar(any())).thenAnswer(
        (_) async =>
            Right(AlertaPage(items: [alerta], count: 1, hasMore: false)),
      );
      await provider.cargar();

      when(() => mockMarcar(alerta: any(named: 'alerta'), currentUserId: any(named: 'currentUserId')))
          .thenAnswer((_) async => Right(updated));

      final error = await provider.marcarLeida(alerta, 10);

      expect(error, isNull);
      expect(provider.alertas.first.isLeida, isTrue);
    });

    test('retorna mensaje de error si falla la autorización', () async {
      final alerta = _makeAlerta(id: 1);
      when(() => mockListar(any())).thenAnswer(
        (_) async =>
            Right(AlertaPage(items: [alerta], count: 1, hasMore: false)),
      );
      await provider.cargar();

      when(() => mockMarcar(alerta: any(named: 'alerta'), currentUserId: any(named: 'currentUserId')))
          .thenAnswer((_) async =>
              const Left(AuthorizationFailure('No puedes marcar alertas ajenas.')));

      final error = await provider.marcarLeida(alerta, 99);

      expect(error, isNotNull);
    });
  });
}

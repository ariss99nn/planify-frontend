import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:your_app/core/error/failures.dart';
import 'package:your_app/features/alertas/domain/entities/alerta_entity.dart';
import 'package:your_app/features/alertas/domain/repositories/alerta_repository.dart';
import 'package:your_app/features/alertas/domain/usecases/marcar_alerta_leida_usecase.dart';

class MockAlertaRepository extends Mock implements AlertaRepository {}

void main() {
  late MockAlertaRepository mockRepo;
  late MarcarAlertaLeidaUseCase useCase;

  final alertaNoLeida = AlertaEntity(
    id: 1,
    tipo: TipoAlerta.conflicto,
    tipoDisplay: 'Conflicto',
    estado: EstadoAlerta.pendiente,
    estadoDisplay: 'Pendiente',
    formatoAlerta: FormatoAlerta.app,
    formatoDisplay: 'App',
    descripcion: 'Test',
    destinatarioId: 10,
    fechaCreacion: DateTime(2026, 6, 1),
  );

  final alertaYaLeida = alertaNoLeida.copyWith(estado: EstadoAlerta.leida);

  setUp(() {
    mockRepo = MockAlertaRepository();
    useCase = MarcarAlertaLeidaUseCase(mockRepo);
  });

  group('MarcarAlertaLeidaUseCase', () {
    test('retorna la alerta actualizada cuando el usuario es el destinatario',
        () async {
      final updated = alertaNoLeida.copyWith(estado: EstadoAlerta.leida);
      when(() => mockRepo.marcarLeida(1)).thenAnswer((_) async => Right(updated));

      final result = await useCase(alerta: alertaNoLeida, currentUserId: 10);

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (e) => expect(e.isLeida, isTrue));
      verify(() => mockRepo.marcarLeida(1)).called(1);
    });

    test('retorna AuthorizationFailure si el usuario no es el destinatario',
        () async {
      final result = await useCase(alerta: alertaNoLeida, currentUserId: 99);

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<AuthorizationFailure>()),
        (_) => fail('Debería haber fallado'),
      );
      verifyNever(() => mockRepo.marcarLeida(any()));
    });

    test('retorna la misma alerta sin llamar a la red si ya está leída',
        () async {
      final result = await useCase(alerta: alertaYaLeida, currentUserId: 10);

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (e) => expect(e, equals(alertaYaLeida)));
      verifyNever(() => mockRepo.marcarLeida(any()));
    });
  });
}

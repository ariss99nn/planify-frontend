// lib/core/widgets/friendly_feedback.dart
//
// Mensajes de error/éxito consistentes y de tono calmado para toda la
// app. Antes cada pantalla mostraba `ApiException(...).toString()` tal
// cual (p. ej. "ApiException(400): El cupo... [code: null]") en un
// SnackBar rojo sólido — correcto pero agresivo. Este helper:
//   1. Limpia el envoltorio técnico del mensaje, dejando solo el texto
//      que el backend ya redactó para humanos.
//   2. Usa un estilo visual más suave (fondo translúcido, borde, ícono),
//      en vez de un bloque rojo saturado de borde a borde.

import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Extrae el mensaje humano de una excepción, quitando el envoltorio
/// técnico "ApiException(400): ... [code: null]" cuando aplica.
String friendlyErrorMessage(Object error) {
  var texto = error.toString();

  final match = RegExp(r'^ApiException\(\d+\):\s*(.*?)(\s*\[code:.*\])?$')
      .firstMatch(texto);
  if (match != null && match.group(1) != null && match.group(1)!.trim().isNotEmpty) {
    texto = match.group(1)!.trim();
  } else {
    texto = texto.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  // Errores de red genéricos quedan con una redacción más humana.
  if (texto.toLowerCase().contains('socketexception') ||
      texto.toLowerCase().contains('failed host lookup')) {
    return 'No se pudo conectar con el servidor. Verifica tu conexión e intenta de nuevo.';
  }
  return texto.isEmpty ? 'Ocurrió un problema. Intenta de nuevo.' : texto;
}

enum FeedbackTono { error, advertencia, exito, info }

/// Muestra un SnackBar de tono calmado (nunca un bloque rojo sólido de
/// borde a borde) con el mensaje ya limpio de envoltorio técnico.
void showFriendlySnack(
  BuildContext context,
  String message, {
  FeedbackTono tono = FeedbackTono.error,
}) {
  final scheme = _esquemaPara(tono);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.fondo,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.borde),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(scheme.icono, color: scheme.acento, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: scheme.texto, fontSize: 13, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}

/// Azúcar sintáctica para el caso más común: mostrar el error de una
/// mutación fallida del provider con un mensaje de respaldo.
void showFriendlyApiError(
  BuildContext context,
  Object? error, {
  String fallback = 'No se pudo completar la acción.',
}) {
  final msg = error == null ? fallback : friendlyErrorMessage(error);
  showFriendlySnack(context, msg, tono: FeedbackTono.error);
}

class _EsquemaFeedback {
  final Color fondo;
  final Color borde;
  final Color acento;
  final Color texto;
  final IconData icono;
  const _EsquemaFeedback(this.fondo, this.borde, this.acento, this.texto, this.icono);
}

_EsquemaFeedback _esquemaPara(FeedbackTono tono) {
  switch (tono) {
    case FeedbackTono.error:
      return _EsquemaFeedback(
        AppTheme.surface.withOpacity(0.97),
        Colors.redAccent.withOpacity(0.35),
        Colors.redAccent.shade100,
        AppTheme.textPrimary,
        Icons.error_outline,
      );
    case FeedbackTono.advertencia:
      return _EsquemaFeedback(
        AppTheme.surface.withOpacity(0.97),
        Colors.amber.withOpacity(0.35),
        Colors.amber.shade200,
        AppTheme.textPrimary,
        Icons.warning_amber_rounded,
      );
    case FeedbackTono.exito:
      return _EsquemaFeedback(
        AppTheme.surface.withOpacity(0.97),
        AppTheme.primary.withOpacity(0.35),
        AppTheme.primary,
        AppTheme.textPrimary,
        Icons.check_circle_outline,
      );
    case FeedbackTono.info:
      return _EsquemaFeedback(
        AppTheme.surface.withOpacity(0.97),
        AppTheme.accent.withOpacity(0.35),
        AppTheme.accent,
        AppTheme.textPrimary,
        Icons.info_outline,
      );
  }
}

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'export_save_result.dart';

/// En Web no hay directorio temporal accesible desde Dart: el navegador
/// es quien controla las descargas. Se crea un Blob en memoria y se
/// dispara la descarga con un <a download> invisible, que es el
/// mecanismo estándar para esto en Flutter Web (no requiere plugins
/// nativos como path_provider, que no tienen implementación web y
/// producen MissingPluginException al intentar usarlos).
Future<ExportSaveResult> saveExportBytes({
  required List<int> bytes,
  required String    fileName,
}) async {
  final blob = html.Blob([Uint8List.fromList(bytes)]);
  final url  = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none'
    ..click();

  // Libera el object URL después de que el navegador tomó la referencia.
  Future.delayed(const Duration(seconds: 5), () {
    html.Url.revokeObjectUrl(url);
  });

  return ExportSaveResult(
    fileName:  fileName,
    sizeBytes: bytes.length,
    filePath:  null, // No aplica en Web: la descarga ya la maneja el navegador.
  );
}

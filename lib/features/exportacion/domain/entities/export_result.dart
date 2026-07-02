/// Resultado de una exportación ya completada.
///
/// - En Android/iOS/Desktop, [filePath] apunta al archivo temporal
///   escrito en disco (se puede abrir con `open_filex`).
/// - En Web no existe una ruta de archivo real: la descarga ya fue
///   disparada por el navegador, por lo que [filePath] es null.
class ExportResult {
  final String  fileName;
  final int     sizeBytes;
  final String? filePath;

  const ExportResult({
    required this.fileName,
    required this.sizeBytes,
    this.filePath,
  });

  bool get isWeb => filePath == null;
}

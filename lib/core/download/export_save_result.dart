/// Resultado de guardar/descargar un archivo exportado.
///
/// En Android/iOS/Desktop se escribe a un archivo temporal real y
/// [filePath] queda apuntando a él (se puede abrir con `open_filex`).
///
/// En Web no existe un sistema de archivos al que la app pueda acceder:
/// la descarga la dispara el propio navegador (Blob + <a download>), por
/// lo que [filePath] queda en null. [isWeb] permite a la UI distinguir
/// ambos casos sin importar código específico de plataforma.
class ExportSaveResult {
  final String? filePath;
  final String fileName;
  final int sizeBytes;

  const ExportSaveResult({
    required this.fileName,
    required this.sizeBytes,
    this.filePath,
  });

  bool get isWeb => filePath == null;
}

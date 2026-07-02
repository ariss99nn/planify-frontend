import 'export_save_result.dart';

Future<ExportSaveResult> saveExportBytes({
  required List<int> bytes,
  required String    fileName,
}) async {
  throw UnsupportedError(
    'La descarga de archivos no está soportada en esta plataforma.',
  );
}

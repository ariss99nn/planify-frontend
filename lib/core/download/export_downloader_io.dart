import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'export_save_result.dart';

Future<ExportSaveResult> saveExportBytes({
  required List<int> bytes,
  required String    fileName,
}) async {
  final dir  = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
  return ExportSaveResult(
    fileName:  fileName,
    sizeBytes: bytes.length,
    filePath:  file.path,
  );
}

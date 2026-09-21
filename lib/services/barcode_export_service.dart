import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Penyimpan gambar barcode (PNG) ke direktori Download perangkat.
///
/// Fallback ke direktori dokumen aplikasi bila izin penyimpanan tidak
/// diberikan atau jalur Download tidak tersedia.
class BarcodeExportService {
  BarcodeExportService._();
  static final BarcodeExportService instance = BarcodeExportService._();

  Future<File> savePngToDownloads(Uint8List bytes, String name) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        final dir = Directory('${ext.path}/Download');
        if (!await dir.exists()) await dir.create(recursive: true);
        final file = File('${dir.path}/$name');
        await file.writeAsBytes(bytes, flush: true);
        return file;
      }
    }
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
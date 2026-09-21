import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'saved_target.dart';

Future<SavedTarget> saveToGallery(Uint8List bytes, String fileName) =>
    _download(bytes, fileName);

Future<SavedTarget> saveFileToDevice(
        Uint8List bytes, String fileName, String mimeType) =>
    _download(bytes, fileName);

/// Unduhan berkas langsung di browser melalui Blob + tautan anchor.
Future<SavedTarget> _download(Uint8List bytes, String fileName) async {
  final blob = web.Blob([bytes.toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return SavedTarget(true, fileName, 'Browser (unduhan)');
}
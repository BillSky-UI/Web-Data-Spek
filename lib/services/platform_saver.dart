import 'dart:typed_data';

import 'platform_saver_io.dart'
    if (dart.library.html) 'platform_saver_web.dart' as impl;

import 'saved_target.dart';
export 'saved_target.dart';

/// Simpan gambar (PNG/JPEG) ke tujuan akhir per platform:
/// - io (Android/iOS): Galeri HP via MediaStore (package `gal`).
/// - web: unduhan berkas di browser.
Future<SavedTarget> saveToGallery(Uint8List bytes, String fileName) =>
    impl.saveToGallery(bytes, fileName);

/// Simpan file apa pun (PDF/XLSX/CSV/jpg) ke tujuan akhir per platform:
/// - io (Android/iOS): folder Download publik via MediaStore
///   (MethodChannel native `spek_komputer/saver`).
/// - web: unduhan berkas di browser.
Future<SavedTarget> saveFileToDevice(
        Uint8List bytes, String fileName, String mimeType) =>
    impl.saveFileToDevice(bytes, fileName, mimeType);
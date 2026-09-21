import 'dart:typed_data';

import 'platform_saver.dart' as platform;
import 'saved_target.dart';

export 'saved_target.dart';

/// Titik masuk penyimpanan file ke lokasi akhir per platform
/// (lihat [platform.saveToGallery] & [platform.saveFileToDevice]).
class PublicSaverService {
  PublicSaverService._();
  static final PublicSaverService instance = PublicSaverService._();

  /// Simpan gambar ke Galeri HP (io) / unduhan browser (web).
  Future<SavedTarget> saveImageToGallery(
          Uint8List bytes, String fileName) =>
      platform.saveToGallery(bytes, fileName);

  /// Simpan PDF ke folder Download publik.
  Future<SavedTarget> savePdfToDownloads(
          Uint8List bytes, String fileName) =>
      platform.saveFileToDevice(bytes, fileName, 'application/pdf');

  /// Simpan file apa pun (PDF/XLSX/jpg) ke folder Download publik.
  Future<SavedTarget> saveFileToDownloads(
          Uint8List bytes, String fileName, String mimeType) =>
      platform.saveFileToDevice(bytes, fileName, mimeType);
}
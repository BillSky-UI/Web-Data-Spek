import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'saved_target.dart';

const _channel = MethodChannel('spek_komputer/saver');

/// Simpan gambar ke storage lokal publik:
/// - Galeri HP via MediaStore (paket `gal`).
/// Bila galeri tidak tersedia, dilimpahkan ke dialog berbagi sistem agar
/// pengguna menyimpan ke lokasi publik pilihannya (Files/Downloads).
/// Tidak pernah menulis ke penyimpanan internal aplikasi.
Future<SavedTarget> saveToGallery(Uint8List bytes, String fileName) async {
  try {
    final tmp = await getTemporaryDirectory();
    final tmpFile = File('${tmp.path}/$fileName');
    await tmpFile.writeAsBytes(bytes, flush: true);
    if (!(await Gal.hasAccess(toAlbum: true))) {
      await Gal.requestAccess(toAlbum: true);
    }
    await Gal.putImage(tmpFile.path, album: 'Stiker Barcode');
    return SavedTarget(true, fileName, 'Galeri HP');
  } catch (_) {
    return _shareViaSystem(bytes, fileName, _mimeFor(fileName));
  }
}

/// Simpan file apa pun (PDF/XLSX/CSV) ke folder Download publik HP
/// (MediaStore via MethodChannel). Bila gagal (mis. API < 29 tanpa izin,
/// atau iOS), dilimpahkan ke dialog berbagi sistem — bukan direktori
/// internal aplikasi.
Future<SavedTarget> saveFileToDevice(
    Uint8List bytes, String fileName, String mimeType) async {
  try {
    final path = await _channel.invokeMethod<String>('saveFileToDownloads', {
      'name': fileName,
      'bytes': bytes,
      'mimeType': mimeType,
    });
    if (path != null && path.isNotEmpty) {
      return SavedTarget(true, path, 'Download HP');
    }
  } catch (_) {
    // lanjut ke fallback
  }
  return _shareViaSystem(bytes, fileName, mimeType);
}

/// Dialog berbagi sistem (SharePlus). Dipakai sebagai fallback agar file
/// selalu bisa disimpan pengguna ke lokasi publik, bukan ke app storage.
Future<SavedTarget> _shareViaSystem(
    Uint8List bytes, String fileName, String mimeType) async {
  await SharePlus.instance.share(ShareParams(
    files: [XFile.fromData(bytes, mimeType: mimeType, name: fileName)],
    subject: fileName,
    text: fileName,
  ));
  return SavedTarget(true, fileName, 'Berbagi (Files/Downloads)');
}

String _mimeFor(String name) {
  final n = name.toLowerCase();
  if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
  if (n.endsWith('.gif')) return 'image/gif';
  return 'image/png';
}
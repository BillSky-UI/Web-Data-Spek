import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan PIN yang aman secara lokal.
/// PIN disimpan sebagai hash SHA-256, bukan teks polos.
class PinController {
  PinController._();
  static final PinController instance = PinController._();

  static const String _keyPin = 'app_pin_hash';
  static const String defaultPin = '0000';
  static const int minLength = 4;
  static const int maxLength = 6;

  /// Hash SHA-256 untuk PIN (dipakai cloud sync & penyimpanan lokal).
  static String hashPin(String pin) =>
      sha256.convert(utf8.encode(pin.trim())).toString();

  String _hash(String pin) => hashPin(pin);

  /// Ambil hash PIN tersimpan; jika belum pernah disimpan gunakan PIN default.
  Future<String> _storedHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPin) ?? _hash(defaultPin);
  }

  /// Cek apakah angka PIN yang dimasukkan benar.
  Future<bool> verify(String pin) async {
    if (pin.trim().length < minLength) return false;
    return _hash(pin.trim()) == await _storedHash();
  }

  /// Ganti PIN lama ke PIN baru. Memvalidasi PIN lama terlebih dahulu.
  Future<bool> changePin(String oldPin, String newPin) async {
    if (!await verify(oldPin)) return false;
    final np = newPin.trim();
    if (np.length < minLength || np.length > maxLength) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyPin, _hash(np));
  }

  /// Simpan PIN baru ke cache lokal tanpa verifikasi — dipakai saat PIN
  /// berhasil diubah di cloud agar tetap berfungsi saat offline.
  Future<bool> savePin(String newPin) async {
    final np = newPin.trim();
    if (np.length < minLength || np.length > maxLength) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyPin, _hash(np));
  }

  bool isValidFormat(String pin) {
    final p = pin.trim();
    if (p.length < minLength || p.length > maxLength) return false;
    return RegExp(r'^\d+$').hasMatch(p);
  }
}
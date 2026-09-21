import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../env/app_config.dart';
import '../models/device.dart';
import '../services/public_saver_service.dart';
import '../theme/app_theme.dart';

/// Dialog "Download Barcode": memuat barcode unik (Code128 + QR Code)
/// milik perangkat dan memungkinkan pengguna menyimpan sebagai PNG
/// (stiker) atau membagikannya.
///
/// QR berisi tautan menuju dokumen PDF spesifikasi perangkat yang
/// disebar di web (`PUBLIC_BASE_URL?kode=...`) sehingga saat stiker
/// dipindai kamera HP biasa, halaman detail/PDF spesifikasi terbuka.
class BarcodeDownloadDialog extends StatefulWidget {
  final Device device;
  const BarcodeDownloadDialog({super.key, required this.device});

  @override
  State<BarcodeDownloadDialog> createState() => _BarcodeDownloadDialogState();
}

class _BarcodeDownloadDialogState extends State<BarcodeDownloadDialog> {
  final GlobalKey _captureKey = GlobalKey();

  bool _busy = false;

  Device get _d => widget.device;
  String get safeKode => _d.kodeInventaris.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'), '_');

  /// Target yang di-encode ke barcode/QR:
  /// 1) Link Google Drive spesifikasi (jika diisi pada form),
  /// 2) tautan publik (PUBLIC_BASE_URL?kode=...),
  /// 3) Kode Inventaris (kompatibel dengan scanner internal).
  String get _scanTarget {
    final link = _d.driveLink.trim();
    if (link.isNotEmpty &&
        (link.startsWith('http://') || link.startsWith('https://'))) {
      return link;
    }
    return AppConfig.qrPayload(_d.kodeInventaris);
  }

  bool get _isPureKode => _scanTarget == _d.kodeInventaris;

  Future<Uint8List> _capturePng() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final boundary =
        _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 4);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<void> _download() async {
    setState(() => _busy = true);
    try {
      final bytes = await _capturePng();
      final target = await PublicSaverService.instance
          .saveImageToGallery(bytes, 'Barcode_$safeKode.png');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Barcode berhasil diunduh ke ${target.location}: ${target.path}'),
        backgroundColor: const Color(0xFF166534),
      ));
    } catch (e) {
      _toast('Gagal mengunduh barcode: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final bytes = await _capturePng();
      final name = 'Barcode_$safeKode.png';
      if (kIsWeb) {
        await PublicSaverService.instance.saveImageToGallery(bytes, name);
      } else {
        await SharePlus.instance.share(ShareParams(
          files: [XFile.fromData(bytes, mimeType: 'image/png', name: name)],
          subject: 'Barcode $safeKode',
          text: 'Barcode/QR $safeKode — ${_d.deviceName}',
        ));
      }
    } catch (e) {
      _toast('Gagal membagikan barcode: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.qr_code_2, color: c.blue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Download Barcode',
                        style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: c.textMuted, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: RepaintBoundary(
                  key: _captureKey,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      children: [
                        Text('INVENTARIS PERANGKAT',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 8,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_d.kodeInventaris,
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: _scanTarget,
                          width: 260,
                          height: 52,
                          drawText: false,
                          color: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Text(_d.kodeInventaris,
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        BarcodeWidget(
                          barcode: Barcode.qrCode(),
                          data: _scanTarget,
                          width: 100,
                          height: 100,
                          color: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Text('Scan QR → buka PDF spesifikasi',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isPureKode
                    ? 'Barcode unik berdasarkan Kode Inventaris ($safeKode). '
                        'Isi "Link Google Drive Spesifikasi" pada form edit agar '
                        'kamera HP langsung membuka file spesifikasi saat discan.'
                    : 'Barcode berisi link spesifikasi perangkat. Saat stiker '
                        'ditempel & discan kamera HP biasa, link langsung '
                        'terbuka di browser.',
                style: TextStyle(color: c.textMuted, fontSize: 11, height: 1.3),
              ),
              if (!_isPureKode)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Target: $_scanTarget',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c.textMuted, fontSize: 10),
                  ),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _share,
                      icon: const Icon(Icons.share, size: 18),
                      label: Text('Bagikan',
                          style: TextStyle(color: c.blueFg)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.blueFg,
                        side: BorderSide(color: c.blue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _download,
                      icon: _busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))
                          : const Icon(Icons.download, size: 18),
                      label: Text('Download PNG',
                          style: TextStyle(color: c.blueFg)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.blue,
                        foregroundColor: c.blueFg,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
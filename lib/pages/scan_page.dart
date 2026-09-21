import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../database/db_helper.dart';
import '../models/device.dart';
import '../theme/app_theme.dart';
import 'detail_page.dart';

/// Pemindai QR / Barcode untuk melacak Kode Inventaris komputer di lapangan.
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: [
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.ean13,
      BarcodeFormat.aztec,
    ],
  );

  bool _handling = false;
  int _lastLookupAt = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final code = capture.barcodes
        .map((b) => b.rawValue ?? '')
        .firstWhere((v) => v.trim().isNotEmpty, orElse: () => '');
    if (code.isEmpty || _handling) return;

    // Debounce sederhana agar kode yang sama tidak diproses berulang.
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastLookupAt < 1500) return;
    _lastLookupAt = now;

    _handling = true;
    // QR stiker publik berisi URL (?kode=K-001); barcode Code128 berisi
    // kode langsung. Dukungan dua-duanya agar tetap bisa dipindai lewat aplikasi.
    var device = await DbHelper.instance.getByKode(code);
    if (device == null) {
      final kodeParam = _kodeFromUrl(code);
      if (kodeParam != null) {
        device = await DbHelper.instance.getByKode(kodeParam);
      }
    }
    if (!mounted) return;
    _handling = false;

    if (device != null) {
      _openDetail(device);
    } else {
      _showNotFound(code);
    }
  }

  /// Ekstrak parameter `kode` dari URL (misal halaman web stiker).
  String? _kodeFromUrl(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasQuery) return null;
    final kode = uri.queryParameters['kode'];
    if (kode == null || kode.trim().isEmpty) return null;
    return kode.trim();
  }

  Future<void> _openDetail(Device device) async {
    await _controller.stop();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(device: device)),
    ).then((_) => _controller.start());
  }

  void _showNotFound(String code) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text('Kode "$code" tidak ditemukan di inventaris'),
      backgroundColor: const Color(0xFFDC2626),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Kode Inventaris'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.no_photography_outlined,
                        color: Colors.white70, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak bisa mengakses kamera',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text('${error.errorCode.name} — ${error.errorDetails}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _controller.start(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Panduan scan di tengah layar.
          IgnorePointer(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: c.accent, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Column(
              children: [
                Icon(Icons.qr_code_scanner, color: c.textMuted, size: 28),
                const SizedBox(height: 6),
                Text(
                  'Arahkan kamera ke QR / barcode stiker komputer',
                  style: TextStyle(color: c.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../env/app_config.dart';
import '../models/device.dart';

/// Generator PDF Stiker template untuk satu perangkat (157mm x 63mm landscape).
class StickerPdfService {
  StickerPdfService._();
  static final StickerPdfService instance = StickerPdfService._();

  String _scanTarget(Device d) {
    final link = d.driveLink.trim();
    if (link.isNotEmpty &&
        (link.startsWith('http://') || link.startsWith('https://'))) {
      return link;
    }
    return AppConfig.qrPayload(d.kodeInventaris);
  }

  Future<Uint8List> buildSticker(Device d) async {
    final m = PdfPageFormat.mm;
    final doc = pw.Document();

    final kode = d.kodeInventaris.trim().isEmpty ? 'TANPA-KODE' : d.kodeInventaris.trim();
    final name = d.deviceName.trim().isEmpty ? 'Tanpa Nama' : d.deviceName.trim();
    final inventaris = d.category.trim().isEmpty ? 'Desktop' : d.category.trim();
    final divisi = d.bagian.trim().isEmpty ? '-' : d.bagian.trim();
    final tglBerlaku = d.tanggalEvaluasi.trim().isEmpty ? '-' : d.tanggalEvaluasi.trim();

    String atas(String s) => s.trim().isEmpty ? '-' : s.trim();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(157 * m, 63 * m),
        margin: pw.EdgeInsets.all(2 * m),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // 1. HEADER UTAMA (Judul & No Dokumen)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 4 * m, vertical: 1.5 * m),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue900,
                    borderRadius: pw.BorderRadius.circular(1.5 * m),
                  ),
                  child: pw.Text(
                    'INVENTARIS & SPESIFIKASI',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 4.5 * m,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Spacer(),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('No. Dok:', style: pw.TextStyle(fontSize: 2.2 * m, color: PdfColors.grey600)),
                    pw.Text('FRM-06/SOP-001-IT',
                      style: pw.TextStyle(fontSize: 3.0 * m, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 1.5 * m),

            // 2. GRID INFORMASI (Inventaris, Divisi, Kode, PJ, Tgl Berlaku)
            pw.Row(
              children: [
                _identBox('Inventaris:', inventaris, m, flex: 2),
                pw.SizedBox(width: 1.5 * m),
                _identBox('Divisi:', divisi, m, flex: 2),
                pw.SizedBox(width: 1.5 * m),
                _identBox('Kode:', kode, m, flex: 3),
                pw.SizedBox(width: 1.5 * m),
                _identBox('PJ:', name, m, flex: 3),
                pw.SizedBox(width: 1.5 * m),
                _identBox('Tgl Blaku:', tglBerlaku, m, flex: 2),
              ],
            ),
            pw.SizedBox(height: 1.5 * m),

            // 3. SUB-HEADER BAGIAN HARDWARE
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.symmetric(vertical: 1 * m, horizontal: 2 * m),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(1 * m),
              ),
              child: pw.Text(
                'Perangkat Keras / Hardware',
                style: pw.TextStyle(
                  fontSize: 3.2 * m,
                  color: PdfColors.blue900,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 1 * m),

            // 4. TABEL SPESIFIKASI KOMPONEN
            _hardwareTable(d, m, atas),

            pw.SizedBox(height: 1.5 * m),

            // 5. BARCODE & QR CODE DI BAGIAN BAWAH
            _barcode(d, kode, m),
          ],
        ),
      ),
    );

    return doc.save();
  }

  pw.Widget _hardwareTable(Device d, double m, String Function(String) atas) {
    return pw.TableHelper.fromTextArray(
      headers: ['No', 'Sub-unit', 'Merek dan spesifikasi komponen'],
      headerStyle: pw.TextStyle(
        fontSize: 2.8 * m,
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
      headerAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
      },
      cellStyle: pw.TextStyle(
        fontSize: 2.8 * m,
        color: PdfColors.grey900,
      ),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
      },
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.3),
      cellPadding: pw.EdgeInsets.symmetric(vertical: 0.8 * m, horizontal: 2 * m),
      data: [
        ['1', 'Mainboard', atas(d.motherboard)],
        ['2', 'Processor(CPU)', atas(d.prosesor)],
        ['3', 'RAM', atas(d.ram)],
        ['4', 'Memory', ''],
        ['5', 'SSD', atas(d.storage)],
      ],
    );
  }

  pw.Widget _identBox(String label, String value, double m, {int flex = 1}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: pw.EdgeInsets.symmetric(horizontal: 1.5 * m, vertical: 1.2 * m),
        decoration: pw.BoxDecoration(
          color: PdfColors.blueGrey50,
          borderRadius: pw.BorderRadius.circular(1.5 * m),
          border: pw.Border.all(color: PdfColors.blueGrey200, width: 0.3),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 2.2 * m,
                color: PdfColors.blueGrey700,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 0.2 * m),
            pw.Text(
              value,
              maxLines: 1,
              overflow: pw.TextOverflow.clip,
              style: pw.TextStyle(
                fontSize: 3.0 * m,
                color: PdfColors.grey900,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _barcode(Device d, String kode, double m) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Container(
            height: 11 * m,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: kode,
              drawText: true,
              textStyle: pw.TextStyle(fontSize: 2.5 * m),
              color: PdfColors.black,
            ),
          ),
        ),
        pw.SizedBox(width: 3 * m),
        pw.Container(
          width: 11 * m,
          height: 11 * m,
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: _scanTarget(d),
            drawText: false,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }
}
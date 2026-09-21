import 'package:excel/excel.dart' as excel_pkg;
import 'package:flutter_test/flutter_test.dart';

import 'package:spek_komputer/models/device.dart';
import 'package:spek_komputer/services/export_service.dart';

void main() {
  final devices = [
    Device(
      kodeInventaris: 'K-001',
      deviceName: 'TES PC',
      plan: 'PLAN 1',
      category: 'Computer',
      tanggalEvaluasi: '12/06/2025',
      statusUpgrade: 'Complated',
    ),
    Device(
      kodeInventaris: 'K-002',
      deviceName: 'TES LAPTOP',
      category: 'Laptop',
      tanggalEvaluasi: '01/01/2026',
      statusUpgrade: 'Pending',
    ),
    Device(
      kodeInventaris: 'K-003',
      deviceName: 'TES PRINTER',
      category: 'Printer',
      tanggalEvaluasi: '05/05/2025',
      statusUpgrade: 'Complated',
    ),
  ];

  test('buildExcelBytes menghasilkan file .xlsx valid', () {
    final bytes = ExportService.instance.buildExcelBytes(devices);
    // Signature file ZIP (xlsx) diawali "PK"
    expect(bytes.length, greaterThan(1000));
    expect(bytes[0], 0x50);
    expect(bytes[1], 0x4B);
  });

  test('file berisi 3 sheet: Computer, Laptop, Printer + kop perusahaan',
      () {
    final bytes = ExportService.instance.buildExcelBytes(devices);
    final excel = excel_pkg.Excel.decodeBytes(bytes);

    // Pastikan workbook memiliki ketiga sheet kategori.
    expect(excel.tables.keys, containsAll(['Computer', 'Laptop', 'Printer']));

    for (final name in ['Computer', 'Laptop', 'Printer']) {
      final sheet = excel.tables[name]!;
      // 7 baris kop/header + minimal 1 baris data = 8 baris.
      expect(sheet.rows.length, greaterThanOrEqualTo(8),
          reason: 'Sheet $name harus punya kop + data');

      // Kumpulkan semua nilai non-null di sheet.
      final flat = sheet.rows
          .expand((r) => r.where((c) => c?.value != null).map((c) => c!.value.toString()))
          .toList();
      final text = flat.join(' ');

      expect(text, contains('PT. DWI PRIMA REZEKY - IT'),
          reason: 'Kop perusahaan harus muncul di sheet $name');
      expect(text, contains('Quality of Devices ($name)'),
          reason: 'Judul laporan harus sesuai kategori $name');
      expect(text, contains('Kode Inventaris'), reason: 'Header kolom');
      expect(text, contains('Device Name'), reason: 'Header kolom');
      expect(text, contains('Processor'), reason: 'Sub-header Spesifikasi');
      expect(text, contains('Status Stiker'), reason: 'Kolom terakhir');
    }

    // Data masuk ke sheet kategori yang tepat.
    final comp = excel.tables['Computer']!;
    final compText = comp.rows
        .expand((r) => r.where((c) => c?.value != null))
        .map((c) => c!.value.toString())
        .join(' ');
    expect(compText, contains('K-001'));
    expect(compText, isNot(contains('K-003')),
        reason: 'Printer tidak boleh di sheet Computer');

    final lap = excel.tables['Laptop']!;
    final lapText = lap.rows
        .expand((r) => r.where((c) => c?.value != null))
        .map((c) => c!.value.toString())
        .join(' ');
    expect(lapText, contains('TES LAPTOP'));

    final priSheet = excel.tables['Printer']!;
    final priText = priSheet.rows
        .expand((r) => r.where((c) => c?.value != null))
        .map((c) => c!.value.toString())
        .join(' ');
    expect(priText, contains('TES PRINTER'));
  });

  test('buildCsvBytes memuat header dan baris data dengan BOM', () {
    final bytes = ExportService.instance.buildCsvBytes(devices);
    final text = String.fromCharCodes(bytes.sublist(3));
    expect(text.contains('Kode Inventaris'), isTrue);
    expect(text.contains('K-001'), isTrue);
    expect(text.contains('TES PC'), isTrue);
  });
}
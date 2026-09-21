import 'package:flutter_test/flutter_test.dart';

import 'package:spek_komputer/database/db_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Excel asset parses 45 rows with correct dates', () async {
    final list = await DbHelper.instance.loadExcelSeed();
    expect(list.length, 45, reason: 'Excel harus berisi 45 baris data');
    // first row K-010 PAK AMRI
    final first = list.firstWhere((d) => d.kodeInventaris == 'K-010');
    expect(first.deviceName, 'PAK AMRI');
    expect(first.tanggalEvaluasi, '12/06/2025');
// serial converted row
    final k012 = list.firstWhere((d) => d.kodeInventaris == 'K-012');
    expect(k012.statusStiker, 'Sudah');
    expect(k012.tanggalEvaluasi, '20/10/2025');
    // text date row (kept exactly as in Excel)
    final k003 = list.firstWhere((d) => d.kodeInventaris == 'K-003');
    expect(k003.tanggalEvaluasi, '18/8/2025');
    // K-015 serial
    final k015 = list.firstWhere((d) => d.kodeInventaris == 'K-015');
    expect(k015.tanggalEvaluasi, '27/08/2026');
  });
}

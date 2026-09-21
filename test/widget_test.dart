import 'package:flutter_test/flutter_test.dart';

import 'package:spek_komputer/models/device.dart';

void main() {
  test('Device toMap/fromMap round-trip', () {
    final device = Device(
      id: 1,
      kodeInventaris: 'K-001',
      deviceName: 'Test PC',
      plan: 'PLAN 1',
      bagian: 'IT',
      statusUpgrade: 'Complated',
    );
    final map = device.toMap();
    expect(map['kode_inventaris'], 'K-001');

    final restored = Device.fromMap(map);
    expect(restored.kodeInventaris, 'K-001');
    expect(restored.deviceName, 'Test PC');
    expect(restored.statusUpgrade, 'Complated');
  });

  test('Device fromMap reads numeric/boolean values as strings', () {
    final device = Device.fromMap({
      'id': 7,
      'kode_inventaris': 4,
      'status_upgrade': 8,
      'perlu_upgrade_ganti': false,
    });
    expect(device.id, 7);
    expect(device.kodeInventaris, '4');
    expect(device.statusUpgrade, '8');
    expect(device.perluUpgradeGanti, 'false');
  });
}

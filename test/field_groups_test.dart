import 'package:flutter_test/flutter_test.dart';

import 'package:spek_komputer/models/device.dart';
import 'package:spek_komputer/utils/field_groups.dart';

void main() {
  Device make({String status = '', String goal = '', String ganti = '', String repair = ''}) =>
      Device(
        kodeInventaris: 'K-001',
        deviceName: 'X',
        statusUpgrade: status,
        goal: goal,
        perluUpgradeGanti: ganti,
        perluUpgradeRepair: repair,
      );

  test('display menampilkan "Belum di input" untuk nilai kosong', () {
    expect(display(''), 'Belum di input');
    expect(display('   '), 'Belum di input');
    expect(display('ABS'), 'ABS');
  });

  test('processorGroup mengelompokkan seri Core/Ryzen', () {
    expect(processorGroup('Intel® Core™ i5-11400'), 'Core i5');
    expect(processorGroup('Intel® Core™ i7-6700'), 'Core i7');
    expect(processorGroup('AMD Ryzen 5'), 'AMD Ryzen');
    expect(processorGroup(''), 'Belum di input');
  });

  test('storageGroup mengelompokkan jenis media', () {
    expect(storageGroup('SSD SATA SMART'), 'SSD');
    expect(storageGroup('HDD SATA 7200 RPM'), 'HDD');
    expect(storageGroup('NVMe disk'), 'NVMe SSD');
    expect(storageGroup(''), 'Belum di input');
  });

  test('ramGroup menormalkan kapasitas', () {
    expect(ramGroup('16 GBytes'), '16 GB');
    expect(ramGroup('8 GB'), '8 GB');
    expect(ramGroup(''), 'Belum di input');
  });

  test('osGroup mengelompokkan versi Windows', () {
    expect(
        osGroup('Microsoft Windows 10 Professional (x64) Build 19045'),
        'Windows 10');
    expect(osGroup('Windows 11 Pro'), 'Windows 11');
    expect(osGroup(''), 'Belum di input');
  });

  test('isTercapai menghitung status selesai/compatible', () {
    expect(isTercapai(make(status: 'Complated')), isTrue);
    expect(isTercapai(make(goal: 'Tercapai')), isTrue);
    expect(isTercapai(make(goal: 'Compatible')), isTrue);
    expect(isTercapai(make(status: 'Pending')), isFalse);
  });

  test('needsUpgrade mendeteksi Yes', () {
    expect(needsUpgrade(make(ganti: 'Yes')), isTrue);
    expect(needsUpgrade(make(repair: 'Yes')), isTrue);
    expect(needsUpgrade(make(ganti: 'No')), isFalse);
  });

  test('aggregate menghitung jumlah dan mengurutkan', () {
    final list = [
      make(status: 'Complated'),
      make(status: 'Pending'),
      make(status: 'Pending'),
      make(status: ''),
    ];
    final agg = aggregate(list, (d) => d.statusUpgrade.isEmpty ? 'Kosong' : d.statusUpgrade);
    expect(agg['Pending'], 2);
    expect(agg['Complated'], 1);
    // urutan: jumlah terbanyak dulu
    expect(agg.keys.first, 'Pending');
  });
}
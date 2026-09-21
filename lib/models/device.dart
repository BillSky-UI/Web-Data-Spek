class Device {
  final int? id;
  String kodeInventaris;
  String tanggalEvaluasi;
  String plan;
  String bagian;
  String deviceName;
  String category;
  String prosesor;
  String motherboard;
  String ram;
  String storage;
  String osWindows;
  String goal;
  String perluUpgradeGanti;
  String perluUpgradeRepair;
  String statusUpgrade;
  String keterangan;
  String statusStiker;
  String driveLink;

  Device({
    this.id,
    this.kodeInventaris = '',
    this.tanggalEvaluasi = '',
    this.plan = '',
    this.bagian = '',
    this.deviceName = '',
    this.category = 'Komputer',
    this.prosesor = '',
    this.motherboard = '',
    this.ram = '',
    this.storage = '',
    this.osWindows = '',
    this.goal = '',
    this.perluUpgradeGanti = '',
    this.perluUpgradeRepair = '',
    this.statusUpgrade = '',
    this.keterangan = '',
    this.statusStiker = '',
    this.driveLink = '',
  });

  Device copyWith({int? id}) => Device(
        id: id ?? this.id,
        kodeInventaris: kodeInventaris,
        tanggalEvaluasi: tanggalEvaluasi,
        plan: plan,
        bagian: bagian,
        deviceName: deviceName,
        category: category,
        prosesor: prosesor,
        motherboard: motherboard,
        ram: ram,
        storage: storage,
        osWindows: osWindows,
        goal: goal,
        perluUpgradeGanti: perluUpgradeGanti,
        perluUpgradeRepair: perluUpgradeRepair,
        statusUpgrade: statusUpgrade,
        keterangan: keterangan,
        statusStiker: statusStiker,
        driveLink: driveLink,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'kode_inventaris': kodeInventaris,
        'tanggal_evaluasi': tanggalEvaluasi,
        'plan': plan,
        'bagian': bagian,
        'device_name': deviceName,
        'category': category,
        'prosesor': prosesor,
        'motherboard': motherboard,
        'ram': ram,
        'storage': storage,
        'os_windows': osWindows,
        'goal': goal,
        'perlu_upgrade_ganti': perluUpgradeGanti,
        'perlu_upgrade_repair': perluUpgradeRepair,
        'status_upgrade': statusUpgrade,
        'keterangan': keterangan,
        'status_stiker': statusStiker,
        'drive_link': driveLink,
      };

  factory Device.fromMap(Map<String, dynamic> m) => Device(
        id: m['id'],
        kodeInventaris: (m['kode_inventaris'] ?? '').toString(),
        tanggalEvaluasi: (m['tanggal_evaluasi'] ?? '').toString(),
        plan: (m['plan'] ?? '').toString(),
        bagian: (m['bagian'] ?? '').toString(),
        deviceName: (m['device_name'] ?? '').toString(),
        category: (m['category'] ?? '').toString(),
        prosesor: (m['prosesor'] ?? '').toString(),
        motherboard: (m['motherboard'] ?? '').toString(),
        ram: (m['ram'] ?? '').toString(),
        storage: (m['storage'] ?? '').toString(),
        osWindows: (m['os_windows'] ?? '').toString(),
        goal: (m['goal'] ?? '').toString(),
        perluUpgradeGanti: (m['perlu_upgrade_ganti'] ?? '').toString(),
        perluUpgradeRepair: (m['perlu_upgrade_repair'] ?? '').toString(),
        statusUpgrade: (m['status_upgrade'] ?? '').toString(),
        keterangan: (m['keterangan'] ?? '').toString(),
        statusStiker: (m['status_stiker'] ?? '').toString(),
        driveLink: (m['drive_link'] ?? '').toString(),
      );
}

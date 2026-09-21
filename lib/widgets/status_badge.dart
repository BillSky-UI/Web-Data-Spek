import 'package:flutter/material.dart';

import '../models/device.dart';
import '../theme/app_theme.dart';
import '../utils/field_groups.dart';

/// Hasil penilaian status cerdas perangkat.
class StatusResult {
  final String label;
  final Color fg;
  final Color bg;
  final IconData icon;
  const StatusResult({
    required this.label,
    required this.fg,
    required this.bg,
    required this.icon,
  });
}

/// Smart Status Badge: warna otomatis berdasarkan kondisi perangkat.
/// - Merah: butuh perbaikan / upgrade mendesak (Perlu Upgrade - Ganti/Repair = Yes)
/// - Hijau: kompatibel / sudah tercapai
/// - Kuning/: sedang dalam proses / belum ada info
StatusResult smartStatus(AppColors c, Device d) {
  if (needsUpgrade(d)) {
    return StatusResult(
      label: 'Perlu Upgrade',
      fg: c.dangerFg,
      bg: c.dangerBg,
      icon: Icons.warning_amber_rounded,
    );
  }
  if (isTercapai(d)) {
    return StatusResult(
      label: 'Tercapai / Kompatibel',
      fg: c.stickerChipFg,
      bg: c.stickerChipBg,
      icon: Icons.check_circle_outline,
    );
  }
  return StatusResult(
    label: 'Dalam Proses',
    fg: c.textMuted,
    bg: c.surfaceAlt,
    icon: Icons.schedule,
  );
}

/// Badge indikator warna otomatis (Merah/Hijau) untuk perangkat.
class StatusBadge extends StatelessWidget {
  final Device device;
  final bool compact;
  const StatusBadge({super.key, required this.device, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final s = smartStatus(c, device);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: s.bg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: compact ? 12 : 14, color: s.fg),
          const SizedBox(width: 5),
          Text(s.label,
              style: TextStyle(
                  color: s.fg,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
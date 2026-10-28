import 'package:flutter/material.dart';

/// Kategori seminar pada NusaEvent Hub.
enum EventCategory { ai, mobile, iot, cybersecurity }

extension EventCategoryX on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.ai:
        return 'AI';
      case EventCategory.mobile:
        return 'Mobile';
      case EventCategory.iot:
        return 'IoT';
      case EventCategory.cybersecurity:
        return 'Cybersecurity';
    }
  }

  IconData get icon {
    switch (this) {
      case EventCategory.ai:
        return Icons.smart_toy_rounded;
      case EventCategory.mobile:
        return Icons.phone_android_rounded;
      case EventCategory.iot:
        return Icons.sensors_rounded;
      case EventCategory.cybersecurity:
        return Icons.security_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.ai:
        return const Color(0xFF7C4DFF);
      case EventCategory.mobile:
        return const Color(0xFF1E88E5);
      case EventCategory.iot:
        return const Color(0xFF00897B);
      case EventCategory.cybersecurity:
        return const Color(0xFFE53935);
    }
  }
}

/// Data satu seminar / workshop.
class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.speaker,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.venue,
    required this.description,
    required this.quota,
    this.price = 0,
    this.isWorkshop = false,
  });

  final String id;
  final String title;
  final String speaker;
  final EventCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final String time;
  final String venue;
  final String description;
  final int quota;
  final int price;
  final bool isWorkshop;

  bool get isFree => price == 0;
  bool get isMultiDay => endDate.isAfter(startDate);
  String get priceLabel => isFree ? 'Gratis' : formatRupiah(price);

  /// Contoh: "Sabtu, 14 Nov 2026" atau "12–13 Des 2026".
  String get dateLabel => isMultiDay ? shortDateLabel : formatTanggal(startDate);

  String get shortDateLabel {
    if (!isMultiDay) return formatTanggalSingkat(startDate);
    if (startDate.month == endDate.month && startDate.year == endDate.year) {
      return '${startDate.day}–${endDate.day} ${_namaBulan[startDate.month - 1]} ${startDate.year}';
    }
    return '${formatTanggalSingkat(startDate)} – ${formatTanggalSingkat(endDate)}';
  }
}

// ---------------------------------------------------------------------------
// Helper format (tanpa package intl agar proyek tetap ringan)
// ---------------------------------------------------------------------------
const List<String> _namaHari = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
];
const List<String> _namaBulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

String formatTanggal(DateTime d) =>
    '${_namaHari[d.weekday - 1]}, ${d.day} ${_namaBulan[d.month - 1]} ${d.year}';

String formatTanggalSingkat(DateTime d) =>
    '${d.day} ${_namaBulan[d.month - 1]} ${d.year}';

String formatRupiah(int value) {
  final digits = value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
  return 'Rp $digits';
}

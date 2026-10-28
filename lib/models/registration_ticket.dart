import 'event_item.dart';

/// Pilihan paket seminar kit.
class KitPackage {
  const KitPackage({
    required this.name,
    required this.description,
    required this.price,
  });

  final String name;
  final String description;
  final int price;
}

const List<KitPackage> kitPackages = [
  KitPackage(
    name: 'Tanpa Kit',
    description: 'Hanya sertifikat digital',
    price: 0,
  ),
  KitPackage(
    name: 'Kit Reguler',
    description: 'Tote bag, notebook, dan pulpen',
    price: 35000,
  ),
  KitPackage(
    name: 'Kit Premium',
    description: 'Kaos, tote bag, notebook, stiker, dan merchandise',
    price: 85000,
  ),
];

const List<String> participantTypes = ['Mahasiswa', 'Dosen', 'Umum'];

/// Tiket hasil pendaftaran peserta.
class RegistrationTicket {
  const RegistrationTicket({
    required this.code,
    required this.event,
    required this.name,
    required this.nim,
    required this.email,
    required this.whatsapp,
    required this.participantType,
    required this.attendanceDate,
    required this.kit,
    required this.donation,
    required this.registeredAt,
  });

  final String code;
  final EventItem event;
  final String name;
  final String nim;
  final String email;
  final String whatsapp;
  final String participantType;
  final DateTime attendanceDate;
  final KitPackage kit;
  final int donation;
  final DateTime registeredAt;

  int get totalPayment => event.price + kit.price + donation;
}

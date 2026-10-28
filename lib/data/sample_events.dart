import '../models/event_item.dart';

/// Data contoh seminar & workshop (lokal, tanpa API).
final List<EventItem> sampleEvents = [
  EventItem(
    id: 'EV01',
    title: 'Generative AI untuk Produktivitas Mahasiswa',
    speaker: 'Dr. Rina Kartika, M.Kom.',
    category: EventCategory.ai,
    startDate: DateTime(2026, 11, 14),
    endDate: DateTime(2026, 11, 14),
    time: '09.00 – 12.00 WIB',
    venue: 'Aula Utama',
    description:
        'Pelajari cara memanfaatkan generative AI untuk riset, penulisan, dan '
        'belajar mandiri secara etis, lengkap dengan studi kasus dan sesi tanya jawab.',
    quota: 300,
  ),
  EventItem(
    id: 'EV02',
    title: 'Hands-on Machine Learning dengan Python',
    speaker: 'Bima Pratama, M.T.',
    category: EventCategory.ai,
    startDate: DateTime(2026, 11, 21),
    endDate: DateTime(2026, 11, 22),
    time: '08.30 – 16.00 WIB',
    venue: 'Ruang Workshop A',
    description:
        'Workshop dua hari: membangun model klasifikasi dari nol menggunakan '
        'Python, pandas, dan scikit-learn. Peserta wajib membawa laptop.',
    quota: 40,
    price: 75000,
    isWorkshop: true,
  ),
  EventItem(
    id: 'EV03',
    title: 'Flutter dari Nol: Membangun Aplikasi Pertama',
    speaker: 'Sinta Maharani, S.T.',
    category: EventCategory.mobile,
    startDate: DateTime(2026, 11, 28),
    endDate: DateTime(2026, 11, 28),
    time: '09.00 – 15.00 WIB',
    venue: 'Ruang Workshop B',
    description:
        'Kenali widget, layout, dan state management dasar Flutter sambil '
        'membuat aplikasi sederhana yang siap dijalankan di emulator.',
    quota: 50,
    price: 50000,
    isWorkshop: true,
  ),
  EventItem(
    id: 'EV04',
    title: 'Desain UI/UX Mobile dengan Material 3',
    speaker: 'Raka Aditya, S.Des.',
    category: EventCategory.mobile,
    startDate: DateTime(2026, 12, 5),
    endDate: DateTime(2026, 12, 5),
    time: '13.00 – 16.00 WIB',
    venue: 'Aula Utama',
    description:
        'Prinsip Material 3, color scheme dinamis, dan alur kerja dari Figma '
        'menuju implementasi aplikasi mobile.',
    quota: 200,
  ),
  EventItem(
    id: 'EV05',
    title: 'Smart Farming dengan ESP32 & MQTT',
    speaker: 'Ir. Hendra Wijaya, M.T.',
    category: EventCategory.iot,
    startDate: DateTime(2026, 12, 12),
    endDate: DateTime(2026, 12, 13),
    time: '08.30 – 16.00 WIB',
    venue: 'Lab IoT',
    description:
        'Rangkai sensor kelembapan tanah dan suhu pada ESP32, kirim data via '
        'MQTT, lalu tampilkan pada dashboard sederhana.',
    quota: 30,
    price: 100000,
    isWorkshop: true,
  ),
  EventItem(
    id: 'EV06',
    title: 'Pemantauan Lingkungan Desa Berbasis Sensor',
    speaker: 'Dewi Lestari, M.Eng.',
    category: EventCategory.iot,
    startDate: DateTime(2026, 12, 19),
    endDate: DateTime(2026, 12, 19),
    time: '09.00 – 11.30 WIB',
    venue: 'Aula Utama',
    description:
        'Studi kasus penerapan IoT untuk kualitas air dan cuaca di tingkat '
        'desa serta peluang pengabdian masyarakat.',
    quota: 250,
  ),
  EventItem(
    id: 'EV07',
    title: 'Ethical Hacking & Bug Bounty untuk Pemula',
    speaker: 'Fajar Nugraha, CEH',
    category: EventCategory.cybersecurity,
    startDate: DateTime(2027, 1, 9),
    endDate: DateTime(2027, 1, 9),
    time: '09.00 – 15.00 WIB',
    venue: 'Lab Cybersecurity',
    description:
        'Pengenalan OWASP Top 10, metodologi pentest dasar, dan cara '
        'melaporkan celah keamanan secara bertanggung jawab.',
    quota: 40,
    price: 60000,
    isWorkshop: true,
  ),
  EventItem(
    id: 'EV08',
    title: 'Lindungi Data Pribadi di Era Digital',
    speaker: 'Prof. Maya Anggraini, Ph.D.',
    category: EventCategory.cybersecurity,
    startDate: DateTime(2027, 1, 16),
    endDate: DateTime(2027, 1, 16),
    time: '10.00 – 12.00 WIB',
    venue: 'Aula Utama',
    description:
        'Memahami UU Pelindungan Data Pribadi, phishing, dan kebiasaan '
        'sederhana untuk menjaga akun tetap aman.',
    quota: 300,
  ),
];

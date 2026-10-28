import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nusa_event_hub/main.dart';

void main() {
  void usePhone(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('home, galeri, tiket, filter, dan form tampil tanpa error', (
    tester,
  ) async {
    usePhone(tester, const Size(1080, 2340));

    await tester.pumpWidget(const NusaEventHubApp());
    await tester.pumpAndSettle();

    expect(find.text('Halo, Sobat Nusa!'), findsOneWidget);
    expect(find.text('Generative AI untuk Produktivitas'), findsWidgets);

    await tester.tap(find.byIcon(Icons.photo_library_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Galeri & Venue'), findsOneWidget);
    expect(find.text('Denah Venue'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.confirmation_num_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Tiket Saya'), findsOneWidget);
    expect(find.text('Belum ada tiket'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.event_note_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Filter kategori'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Mobile'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Flutter Mobile App Workshop'), findsWidgets);

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Pendaftaran Tiket'), findsOneWidget);
    expect(find.text('Total bayar'), findsOneWidget);
  });

  testWidgets('alur daftar sampai tiket dan detail tampil rapi', (
    tester,
  ) async {
    usePhone(tester, const Size(1080, 2340));

    await tester.pumpWidget(const NusaEventHubApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Pendaftaran Tiket'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Dani Pratama');
    await tester.enterText(fields.at(1), '21012345');
    await tester.enterText(fields.at(2), 'dani@mail.com');
    await tester.enterText(fields.at(3), '081234567890');

    await tester.ensureVisible(find.text('Pilih tanggal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih tanggal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Saya menyetujui tata tertib acara'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saya menyetujui tata tertib acara'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daftar sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Tiket Saya'), findsNothing);

    await tester.tap(find.byIcon(Icons.confirmation_num_outlined));
    await tester.pumpAndSettle();

    expect(find.text('1 tiket aktif'), findsOneWidget);
    expect(find.textContaining('TKT-'), findsOneWidget);

    await tester.tap(find.textContaining('TKT-'));
    await tester.pumpAndSettle();

    expect(find.text('Detail tiket'), findsOneWidget);
    expect(find.text('Dani Pratama'), findsWidgets);
  });

  testWidgets('layout tetap aman di layar kecil', (tester) async {
    usePhone(tester, const Size(960, 1704));

    await tester.pumpWidget(const NusaEventHubApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.photo_library_outlined));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -800));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.confirmation_num_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.event_note_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
  });
}

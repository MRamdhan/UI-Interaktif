import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nusa_event_hub/data/events.dart';
import 'package:nusa_event_hub/models/registration_ticket.dart';
import 'package:nusa_event_hub/screens/event_registration_screen.dart';
import 'package:nusa_event_hub/screens/home_events_screen.dart';
import 'package:nusa_event_hub/screens/registered_tickets_screen.dart';
import 'package:nusa_event_hub/theme/app_theme.dart';

Future<void> _loadRoboto() async {
  final loader = FontLoader('Roboto');
  const files = [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
  ];

  for (final file in files) {
    final bytes = await File(
      'C:/flutter/bin/cache/artifacts/material_fonts/$file',
    ).readAsBytes();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }

  await loader.load();

  final iconLoader = FontLoader('MaterialIcons');
  final iconBytes = await File(
    'C:/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  ).readAsBytes();
  iconLoader.addFont(Future.value(ByteData.view(iconBytes.buffer)));
  await iconLoader.load();
}

Widget _wrap(Widget child) {
  final theme = buildAppTheme();

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme.copyWith(
      textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
    ),
    home: child,
  );
}

void main() {
  setUpAll(_loadRoboto);

  Future<void> setPhone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  RegistrationTicket sampleTicket(int index) {
    return RegistrationTicket(
      id: 'TKT-2026111200$index',
      event: events[index],
      name: 'Dani Pratama',
      nim: '21012345',
      email: 'dani@mail.com',
      whatsapp: '081234567890',
      participantType: 'Mahasiswa',
      attendanceDate: events[index].date,
      kit: true,
      donation: index == 0 ? 20000 : 0,
      rulesAccepted: true,
    );
  }

  testWidgets('home preview', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(_wrap(const HomeEventsScreen()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/home.png'),
    );
  });

  testWidgets('gallery preview', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(_wrap(const HomeEventsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.photo_library_outlined));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/gallery.png'),
    );
  });

  testWidgets('registration preview', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(
      _wrap(EventRegistrationScreen(event: events[0])),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/registration.png'),
    );
  });

  testWidgets('tickets preview', (tester) async {
    await setPhone(tester);
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          appBar: AppBar(title: const Text('Tiket Saya')),
          body: RegisteredTicketsScreen(
            tickets: [sampleTicket(0), sampleTicket(1)],
            onCancel: (_) {},
            onExplore: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/tickets.png'),
    );
  });
}

import 'package:flutter/material.dart';

import '../data/sample_events.dart';
import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../widgets/event_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/venue_map_viewer.dart';
import 'event_registration_screen.dart';
import 'registered_tickets_screen.dart';

/// Layar utama: 3 tab (Seminar & Workshop, Galeri & Denah, Tiket Terdaftar).
class HomeEventsScreen extends StatefulWidget {
  const HomeEventsScreen({super.key});

  @override
  State<HomeEventsScreen> createState() => _HomeEventsScreenState();
}

class _HomeEventsScreenState extends State<HomeEventsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<RegistrationTicket> _tickets = [];
  EventFilter _filter = const EventFilter();
  int _galleryMode = 0; // 0 = poster, 1 = denah (layar sempit)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------- Logika -------------------------------------
  List<EventItem> get _filteredEvents {
    return sampleEvents.where((event) {
      final categoryOk =
          _filter.categories.isEmpty || _filter.categories.contains(event.category);
      final priceOk = !_filter.freeOnly || event.isFree;
      return categoryOk && priceOk;
    }).toList();
  }

  bool _isRegistered(EventItem event) =>
      _tickets.any((ticket) => ticket.event.id == event.id);

  void _toggleCategory(EventCategory category) {
    final next = {..._filter.categories};
    if (!next.add(category)) next.remove(category);
    setState(() => _filter = _filter.copyWith(categories: next));
  }

  Future<void> _openFilterSheet() async {
    final result = await showFilterBottomSheet(context, _filter);
    if (result != null && mounted) setState(() => _filter = result);
  }

  void _openDetail(EventItem event) {
    showEventDetailSheet(
      context,
      event,
      isRegistered: _isRegistered(event),
      onRegister: () => _openRegistration(event),
    );
  }

  Future<void> _openRegistration(EventItem event) async {
    final ticket = await Navigator.of(context).push<RegistrationTicket>(
      MaterialPageRoute(builder: (_) => EventRegistrationScreen(event: event)),
    );
    if (ticket == null || !mounted) return;

    setState(() => _tickets.insert(0, ticket));
    _tabController.animateTo(2);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Pendaftaran berhasil! Tiket ${ticket.code} sudah aktif.'),
        ),
      );
  }

  void _cancelTicket(RegistrationTicket ticket) {
    setState(() => _tickets.removeWhere((t) => t.code == ticket.code));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Tiket "${ticket.event.title}" dibatalkan.'),
        ),
      );
  }

  // ---------------------------- UI -----------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NusaEvent Hub'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            const Tab(
              icon: Icon(Icons.event_note_outlined),
              text: 'Seminar & Workshop',
            ),
            const Tab(
              icon: Icon(Icons.photo_library_outlined),
              text: 'Galeri & Denah',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: _tickets.isNotEmpty,
                label: Text('${_tickets.length}'),
                child: const Icon(Icons.confirmation_number_outlined),
              ),
              text: 'Tiket Terdaftar',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(),
          _buildGalleryTab(),
          RegisteredTicketsScreen(
            tickets: _tickets,
            onCancel: _cancelTicket,
            onBrowse: () => _tabController.animateTo(0),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    final theme = Theme.of(context);
    final events = _filteredEvents;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Semua'),
                            selected: _filter.categories.isEmpty,
                            onSelected: (_) => setState(
                              () => _filter = _filter.copyWith(
                                categories: <EventCategory>{},
                              ),
                            ),
                          ),
                          for (final category in EventCategory.values)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                avatar: Icon(category.icon, size: 18),
                                label: Text(category.label),
                                selected: _filter.categories.contains(category),
                                onSelected: (_) => _toggleCategory(category),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Filter lanjutan',
                    onPressed: _openFilterSheet,
                    icon: Badge(
                      isLabelVisible: _filter.activeCount > 0,
                      label: Text('${_filter.activeCount}'),
                      child: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menampilkan ${events.length} dari ${sampleEvents.length} acara',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? _buildNoResult(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return EventCard(
                          event: event,
                          isRegistered: _isRegistered(event),
                          onTap: () => _openDetail(event),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResult(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('Tidak ada acara yang cocok',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => setState(() => _filter = const EventFilter()),
              child: const Text('Reset filter'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final posterGrid = _PosterGrid(events: sampleEvents, onTap: _openDetail);
        const map = VenueMapViewer();

        // Layar lebar: poster dan denah tampil berdampingan.
        if (constraints.maxWidth >= 900) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _GallerySection(title: 'Galeri Poster', child: posterGrid)),
                const SizedBox(width: 16),
                const Expanded(child: _GallerySection(title: 'Denah Venue', child: map)),
              ],
            ),
          );
        }

        // Layar sempit: pindah lewat SegmentedButton.
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.grid_view_rounded),
                    label: Text('Poster'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.map_outlined),
                    label: Text('Denah Venue'),
                  ),
                ],
                selected: {_galleryMode},
                onSelectionChanged: (selection) =>
                    setState(() => _galleryMode = selection.first),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: IndexedStack(
                  index: _galleryMode,
                  sizing: StackFit.expand,
                  children: [posterGrid, map],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Expanded(child: child),
      ],
    );
  }
}

/// Galeri poster memakai GridView.builder.
class _PosterGrid extends StatelessWidget {
  const _PosterGrid({required this.events, required this.onTap});

  final List<EventItem> events;
  final ValueChanged<EventItem> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _PosterTile(event: event, onTap: () => onTap(event));
      },
    );
  }
}

class _PosterTile extends StatelessWidget {
  const _PosterTile({required this.event, required this.onTap});

  final EventItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = event.category.color;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, Color.lerp(color, Colors.black, 0.5)!],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.category.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: FittedBox(
                      child: Icon(
                        event.category.icon,
                        size: 64,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.shortDateLabel,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/event_item.dart';

/// Kartu interaktif seminar (InkWell di dalam Card).
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isRegistered = false,
  });

  final EventItem event;
  final VoidCallback onTap;
  final bool isRegistered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = event.category.color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, Color.lerp(color, Colors.black, 0.4)!],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(event.category.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Tag(label: event.category.label, color: color),
                        if (event.isWorkshop)
                          const _Tag(label: 'Workshop', color: Colors.orange),
                        if (isRegistered)
                          const _Tag(label: 'Terdaftar', color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.speaker,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _Meta(icon: Icons.event_outlined, text: event.dateLabel),
                        _Meta(icon: Icons.place_outlined, text: event.venue),
                        _Meta(icon: Icons.sell_outlined, text: event.priceLabel),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet detail seminar dengan tombol "Daftar Sekarang".
Future<void> showEventDetailSheet(
  BuildContext context,
  EventItem event, {
  required bool isRegistered,
  required VoidCallback onRegister,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _Tag(label: event.category.label, color: event.category.color),
                if (event.isWorkshop)
                  const _Tag(label: 'Workshop', color: Colors.orange),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              event.title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _DetailRow(icon: Icons.person_outline, text: event.speaker),
            _DetailRow(icon: Icons.event_outlined, text: event.dateLabel),
            _DetailRow(icon: Icons.schedule, text: event.time),
            _DetailRow(icon: Icons.place_outlined, text: event.venue),
            _DetailRow(
              icon: Icons.groups_outlined,
              text: 'Kuota ${event.quota} peserta',
            ),
            _DetailRow(icon: Icons.sell_outlined, text: event.priceLabel),
            const SizedBox(height: 12),
            Text(event.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isRegistered
                    ? null
                    : () {
                        Navigator.of(sheetContext).pop();
                        onRegister();
                      },
                icon: const Icon(Icons.confirmation_number_outlined),
                label: Text(isRegistered ? 'Sudah Terdaftar' : 'Daftar Sekarang'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

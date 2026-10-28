import 'package:flutter/material.dart';

import '../models/event_item.dart';

/// State filter yang dipakai di halaman seminar.
class EventFilter {
  const EventFilter({
    this.categories = const <EventCategory>{},
    this.freeOnly = false,
  });

  final Set<EventCategory> categories;
  final bool freeOnly;

  int get activeCount => categories.length + (freeOnly ? 1 : 0);

  EventFilter copyWith({Set<EventCategory>? categories, bool? freeOnly}) {
    return EventFilter(
      categories: categories ?? this.categories,
      freeOnly: freeOnly ?? this.freeOnly,
    );
  }
}

Future<EventFilter?> showFilterBottomSheet(
  BuildContext context,
  EventFilter current,
) {
  return showModalBottomSheet<EventFilter>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => FilterBottomSheet(initial: current),
  );
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key, required this.initial});

  final EventFilter initial;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Set<EventCategory> _categories;
  late bool _freeOnly;

  @override
  void initState() {
    super.initState();
    _categories = {...widget.initial.categories};
    _freeOnly = widget.initial.freeOnly;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Seminar', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Pilih satu atau lebih kategori. Kosongkan untuk menampilkan semua.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in EventCategory.values)
                  FilterChip(
                    avatar: Icon(category.icon, size: 18),
                    label: Text(category.label),
                    selected: _categories.contains(category),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _categories.add(category);
                        } else {
                          _categories.remove(category);
                        }
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hanya acara gratis'),
              value: _freeOnly,
              onChanged: (value) => setState(() => _freeOnly = value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _categories.clear();
                      _freeOnly = false;
                    }),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      EventFilter(
                        categories: _categories,
                        freeOnly: _freeOnly,
                      ),
                    ),
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

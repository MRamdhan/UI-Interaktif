import 'package:flutter/material.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';

/// Tab "Tiket Terdaftar": daftar tiket aktif + pembatalan (Dismissible).
class RegisteredTicketsScreen extends StatelessWidget {
  const RegisteredTicketsScreen({
    super.key,
    required this.tickets,
    required this.onCancel,
    this.onBrowse,
  });

  final List<RegistrationTicket> tickets;
  final ValueChanged<RegistrationTicket> onCancel;
  final VoidCallback? onBrowse;

  /// Dialog konfirmasi pembatalan. true = tiket jadi dibatalkan.
  Future<bool> _confirmCancel(
    BuildContext context,
    RegistrationTicket ticket,
  ) async {
    final scheme = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Batalkan tiket?'),
        content: Text(
          'Tiket "${ticket.event.title}" atas nama ${ticket.name} '
          'akan dibatalkan dan tidak dapat dipulihkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya, batalkan'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) return _buildEmpty(context);

    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: tickets.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4, top: 4),
                child: Row(
                  children: [
                    Icon(Icons.swipe_left_alt_rounded,
                        size: 18, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${tickets.length} tiket aktif • geser ke kiri untuk membatalkan',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return _buildTicket(context, tickets[index - 1]);
          },
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Belum ada tiket aktif', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Daftar ke seminar atau workshop terlebih dahulu, tiketmu akan muncul di sini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (onBrowse != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: onBrowse,
                icon: const Icon(Icons.search),
                label: const Text('Lihat Seminar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTicket(BuildContext context, RegistrationTicket ticket) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = ticket.event.category.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Dismissible(
        key: ValueKey(ticket.code),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmCancel(context, ticket),
        onDismissed: (_) => onCancel(ticket),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: scheme.onErrorContainer),
              Text(
                'Batalkan',
                style: TextStyle(color: scheme.onErrorContainer, fontSize: 12),
              ),
            ],
          ),
        ),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withAlpha(36),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.qr_code_2_rounded, color: color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.code,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              letterSpacing: 1,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Batalkan tiket',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirmed = await _confirmCancel(context, ticket);
                        if (confirmed) onCancel(ticket);
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),
                _InfoRow(
                  label: 'Peserta',
                  value: '${ticket.name} (${ticket.participantType})',
                ),
                _InfoRow(label: 'NIM', value: ticket.nim),
                _InfoRow(
                  label: 'Hadir',
                  value: formatTanggal(ticket.attendanceDate),
                ),
                _InfoRow(
                  label: 'Lokasi',
                  value: '${ticket.event.venue} • ${ticket.event.time}',
                ),
                _InfoRow(label: 'Seminar kit', value: ticket.kit.name),
                if (ticket.donation > 0)
                  _InfoRow(
                    label: 'Donasi',
                    value: formatRupiah(ticket.donation),
                  ),
                _InfoRow(
                  label: 'Total',
                  value: ticket.totalPayment == 0
                      ? 'Gratis'
                      : formatRupiah(ticket.totalPayment),
                  bold: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

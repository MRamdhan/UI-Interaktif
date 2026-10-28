import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';

/// Formulir pendaftaran tiket seminar. Mengembalikan [RegistrationTicket]
/// lewat Navigator.pop saat pendaftaran berhasil.
class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key, required this.event});

  final EventItem event;

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _dateController = TextEditingController();

  String _participantType = participantTypes.first;
  DateTime? _attendanceDate;
  KitPackage _kit = kitPackages.first;
  bool _wantDonate = false;
  double _donation = 10000;
  bool _isSubmitting = false;

  int get _donationAmount => _wantDonate ? _donation.round() : 0;
  int get _total => widget.event.price + _kit.price + _donationAmount;

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // ---------------------------- Validator ----------------------------------
  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama lengkap wajib diisi';
    if (text.length < 3) return 'Nama minimal 3 karakter';
    if (!RegExp(r"^[A-Za-z .,'-]+$").hasMatch(text)) {
      return 'Nama hanya boleh berisi huruf';
    }
    return null;
  }

  String? _validateNim(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'NIM wajib diisi';
    if (!RegExp(r'^\d{8,12}$').hasMatch(text)) {
      return 'NIM harus berupa 8–12 digit angka';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[\w.+-]+@([\w-]+\.)+[A-Za-z]{2,}$').hasMatch(text)) {
      return 'Format email tidak valid (contoh: nama@kampus.ac.id)';
    }
    return null;
  }

  String? _validateWhatsapp(String? value) {
    final text = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (text.isEmpty) return 'Nomor WhatsApp wajib diisi';
    if (!RegExp(r'^(\+62|62|0)8\d{8,11}$').hasMatch(text)) {
      return 'Gunakan format 08xxxxxxxxxx atau +628xxxxxxxxxx';
    }
    return null;
  }

  // ---------------------------- Aksi ---------------------------------------
  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final event = widget.event;
    final picked = await showDatePicker(
      context: context,
      initialDate: _attendanceDate ?? event.startDate,
      firstDate: event.startDate,
      lastDate: event.endDate,
      helpText: 'Pilih tanggal kehadiran',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _attendanceDate = picked;
      _dateController.text = formatTanggal(picked);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Periksa kembali isian formulir yang masih salah.'),
          ),
        );
      return;
    }

    setState(() => _isSubmitting = true);
    // Simulasi proses pendaftaran ke server.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final stamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final ticket = RegistrationTicket(
      code: 'NEH-${widget.event.id}-${stamp.substring(stamp.length - 5)}',
      event: widget.event,
      name: _nameController.text.trim(),
      nim: _nimController.text.trim(),
      email: _emailController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      participantType: _participantType,
      attendanceDate: _attendanceDate!,
      kit: _kit,
      donation: _donationAmount,
      registeredAt: DateTime.now(),
    );
    Navigator.of(context).pop(ticket);
  }

  // ---------------------------- UI -----------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = widget.event;

    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Pendaftaran Tiket')),
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEventSummary(theme, event),
                          const _SectionTitle('Data Peserta'),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: _decoration(
                              label: 'Nama lengkap',
                              icon: Icons.person_outline,
                            ),
                            validator: _validateName,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _nimController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            decoration: _decoration(
                              label: 'NIM',
                              icon: Icons.badge_outlined,
                            ),
                            validator: _validateNim,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _decoration(
                              label: 'Email',
                              icon: Icons.email_outlined,
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _whatsappController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\s-]'),
                              ),
                            ],
                            decoration: _decoration(
                              label: 'Nomor WhatsApp',
                              icon: Icons.chat_outlined,
                              hint: '08123456789',
                            ),
                            validator: _validateWhatsapp,
                          ),
                          const _SectionTitle('Tipe Peserta'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final type in participantTypes)
                                ChoiceChip(
                                  label: Text(type),
                                  selected: _participantType == type,
                                  onSelected: (_) =>
                                      setState(() => _participantType = type),
                                ),
                            ],
                          ),
                          const _SectionTitle('Tanggal Kehadiran'),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: _pickDate,
                            decoration: _decoration(
                              label: 'Tanggal kehadiran',
                              icon: Icons.calendar_month_outlined,
                              hint: 'Ketuk untuk memilih tanggal',
                            ).copyWith(helperText: 'Tersedia: ${event.dateLabel}'),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Tanggal kehadiran wajib dipilih'
                                    : null,
                          ),
                          const _SectionTitle('Paket Seminar Kit'),
                          for (final kit in kitPackages) _buildKitTile(theme, kit),
                          const _SectionTitle('Donasi (opsional)'),
                          Card(
                            margin: EdgeInsets.zero,
                            child: Column(
                              children: [
                                SwitchListTile(
                                  title: const Text('Donasi beasiswa peserta'),
                                  subtitle: const Text(
                                    'Bantu peserta yang kurang mampu mengikuti seminar.',
                                  ),
                                  value: _wantDonate,
                                  onChanged: (v) => setState(() => _wantDonate = v),
                                ),
                                if (_wantDonate)
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nominal: ${formatRupiah(_donation.round())}',
                                          style: theme.textTheme.titleSmall,
                                        ),
                                        Slider(
                                          value: _donation,
                                          min: 10000,
                                          max: 100000,
                                          divisions: 9,
                                          label: formatRupiah(_donation.round()),
                                          onChanged: (v) =>
                                              setState(() => _donation = v),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FormField<bool>(
                            initialValue: false,
                            validator: (value) => value == true
                                ? null
                                : 'Anda harus menyetujui tata tertib acara',
                            builder: (state) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  value: state.value ?? false,
                                  onChanged: (v) => state.didChange(v),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Saya menyetujui tata tertib acara',
                                  ),
                                  subtitle: const Text(
                                    'Hadir tepat waktu, membawa kartu identitas, '
                                    'dan menjaga ketertiban selama acara.',
                                  ),
                                ),
                                if (state.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(
                                      state.errorText!,
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const _SectionTitle('Ringkasan Biaya'),
                          _buildCostSummary(theme, event),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _isSubmitting ? null : _submit,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.how_to_reg_outlined),
                              label: Text(
                                _isSubmitting ? 'Memproses...' : 'Daftar Sekarang',
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isSubmitting) const Positioned.fill(child: _LoadingOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSummary(ThemeData theme, EventItem event) {
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _SummaryChip(icon: Icons.event_outlined, text: event.dateLabel),
                _SummaryChip(icon: Icons.place_outlined, text: event.venue),
                _SummaryChip(icon: Icons.sell_outlined, text: event.priceLabel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKitTile(ThemeData theme, KitPackage kit) {
    final selected = _kit == kit;
    final scheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => setState(() => _kit = kit),
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: selected ? scheme.primary : scheme.outline,
        ),
        title: Text(kit.name),
        subtitle: Text(kit.description),
        trailing: Text(
          kit.price == 0 ? 'Gratis' : formatRupiah(kit.price),
          style: theme.textTheme.labelLarge,
        ),
      ),
    );
  }

  Widget _buildCostSummary(ThemeData theme, EventItem event) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _CostRow(label: 'Tiket seminar', value: event.priceLabel),
            _CostRow(
              label: _kit.name,
              value: _kit.price == 0 ? 'Gratis' : formatRupiah(_kit.price),
            ),
            if (_donationAmount > 0)
              _CostRow(label: 'Donasi', value: formatRupiah(_donationAmount)),
            const Divider(height: 20),
            _CostRow(
              label: 'Total',
              value: _total == 0 ? 'Gratis' : formatRupiah(_total),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _decoration({
  required String label,
  required IconData icon,
  String? hint,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon),
    border: const OutlineInputBorder(),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimaryContainer;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(dismissible: false, color: Colors.black38),
        Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Memproses pendaftaran...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

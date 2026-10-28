import 'package:flutter/material.dart';

/// Ukuran kanvas denah (satuan logis); di-scale otomatis mengikuti layar.
const double _canvasWidth = 800;
const double _canvasHeight = 560;

class _Room {
  const _Room(
    this.label,
    this.info,
    this.icon,
    this.color,
    this.left,
    this.top,
    this.width,
    this.height,
  );

  final String label;
  final String info;
  final IconData icon;
  final Color color;
  final double left;
  final double top;
  final double width;
  final double height;
}

const List<_Room> _rooms = [
  _Room('Aula Utama', 'Seminar utama, kapasitas 300 kursi', Icons.groups_rounded,
      Color(0xFF5C6BC0), 20, 20, 420, 260),
  _Room('PANGGUNG', 'Panggung pembicara dan layar presentasi',
      Icons.slideshow_rounded, Color(0xFF283593), 130, 30, 200, 70),
  _Room('Ruang\nWorkshop A', 'Workshop AI & Mobile (40 kursi)',
      Icons.laptop_mac_rounded, Color(0xFF1E88E5), 460, 20, 160, 120),
  _Room('Ruang\nWorkshop B', 'Workshop Flutter (50 kursi)',
      Icons.laptop_mac_rounded, Color(0xFF039BE5), 630, 20, 150, 120),
  _Room('Lab IoT', 'Praktik ESP32, sensor, dan MQTT', Icons.sensors_rounded,
      Color(0xFF00897B), 460, 150, 160, 130),
  _Room('Lab\nCybersecurity', 'Praktik ethical hacking', Icons.shield_rounded,
      Color(0xFFE53935), 630, 150, 150, 130),
  _Room('Registrasi', 'Check-in peserta & pengambilan seminar kit',
      Icons.how_to_reg_rounded, Color(0xFFF57C00), 20, 300, 200, 100),
  _Room('Booth Sponsor\n& Pameran', 'Booth komunitas, sponsor, dan pameran poster',
      Icons.storefront_rounded, Color(0xFF8E24AA), 230, 300, 210, 100),
  _Room('Foodcourt', 'Area makan dan minum', Icons.restaurant_rounded,
      Color(0xFF6D4C41), 460, 300, 320, 100),
  _Room('Toilet', 'Toilet pria & wanita', Icons.wc_rounded, Color(0xFF546E7A),
      20, 420, 100, 120),
  _Room('Musholla', 'Tempat ibadah', Icons.nights_stay_rounded,
      Color(0xFF2E7D32), 130, 420, 150, 120),
  _Room('Lobi & Networking', 'Area bertemu pembicara dan sesama peserta',
      Icons.groups_rounded, Color(0xFF3949AB), 290, 420, 300, 120),
  _Room('Pintu Masuk', 'Pintu masuk utama gedung', Icons.login_rounded,
      Color(0xFF424242), 600, 420, 180, 120),
];

/// Denah venue yang bisa digeser dan diperbesar memakai InteractiveViewer.
class VenueMapViewer extends StatefulWidget {
  const VenueMapViewer({super.key});

  @override
  State<VenueMapViewer> createState() => _VenueMapViewerState();
}

class _VenueMapViewerState extends State<VenueMapViewer> {
  static const double _minScale = 0.8;
  static const double _maxScale = 5.0;

  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoom(double factor, Size viewport) {
    final current = _controller.value.getMaxScaleOnAxis();
    final target = (current * factor).clamp(_minScale, _maxScale).toDouble();
    final applied = target / current;
    final center = viewport.center(Offset.zero);

    final zoom = Matrix4.translationValues(center.dx, center.dy, 0)
        .multiplied(Matrix4.diagonal3Values(applied, applied, 1))
        .multiplied(Matrix4.translationValues(-center.dx, -center.dy, 0));
    _controller.value = zoom.multiplied(_controller.value);
  }

  void _reset() => _controller.value = Matrix4.identity();

  void _showRoomInfo(_Room room) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${room.label.replaceAll('\n', ' ')} — ${room.info}'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: theme.colorScheme.secondaryContainer.withAlpha(90),
                  child: InteractiveViewer(
                    transformationController: _controller,
                    minScale: _minScale,
                    maxScale: _maxScale,
                    boundaryMargin: const EdgeInsets.all(160),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _canvasWidth / _canvasHeight,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: _canvasWidth,
                            height: _canvasHeight,
                            child: _VenueCanvas(onRoomTap: _showRoomInfo),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: ValueListenableBuilder<Matrix4>(
                  valueListenable: _controller,
                  builder: (context, matrix, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withAlpha(230),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Zoom ${matrix.getMaxScaleOnAxis().toStringAsFixed(1)}×',
                        style: theme.textTheme.labelMedium,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Perbesar',
                      onPressed: () => _zoom(1.4, viewport),
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 6),
                    IconButton.filledTonal(
                      tooltip: 'Perkecil',
                      onPressed: () => _zoom(1 / 1.4, viewport),
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 6),
                    IconButton.filledTonal(
                      tooltip: 'Reset tampilan',
                      onPressed: _reset,
                      icon: const Icon(Icons.center_focus_strong_outlined),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 8,
                right: 64,
                bottom: 8,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withAlpha(230),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Geser & cubit untuk zoom • ketuk ruangan untuk info',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VenueCanvas extends StatelessWidget {
  const _VenueCanvas({required this.onRoomTap});

  final ValueChanged<_Room> onRoomTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF90A4AE), width: 4),
      ),
      child: Stack(
        children: [
          for (final room in _rooms)
            Positioned(
              left: room.left,
              top: room.top,
              width: room.width,
              height: room.height,
              child: _RoomTile(room: room, onTap: () => onRoomTap(room)),
            ),
        ],
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.room, required this.onTap});

  final _Room room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: room.color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(room.icon, color: Colors.white, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    room.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

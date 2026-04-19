import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/run_state.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  static const LatLng _defaultCenter = LatLng(11.0168, 76.9558); // Coimbatore
  Timer? _durationTimer;
  Duration _elapsed = Duration.zero;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initLocation();
  }

  Future<void> _initLocation() async {
    final runState = context.read<RunState>();
    final granted = await _locationService.requestPermission();
    if (!granted) return;
    _locationService.startTracking(runState);
    runState.stopTracking(); // passive mode — show location but don't record
  }

  void _onStartRun() {
    final runState = context.read<RunState>();
    _locationService.stopTracking(runState);
    _locationService.startTracking(runState);
    _elapsed = Duration.zero;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  void _onStopRun() {
    _durationTimer?.cancel();
    _locationService.stopTracking(context.read<RunState>());
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _pulseController.dispose();
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RunState>(builder: (context, runState, _) {
      final position = runState.currentPosition;
      if (position != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (runState.isTracking) _mapController.move(position, 17.0);
        });
      }

      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: Stack(children: [
          // ── MAP ──────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: position ?? _defaultCenter,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kora',
              ),
              if (runState.pathPoints.length >= 2)
                PolylineLayer(polylines: [
                  Polyline(
                    points: runState.pathPoints,
                    color: AppTheme.accent,
                    strokeWidth: 5.0,
                    borderColor: AppTheme.accent.withValues(alpha: 0.3),
                    borderStrokeWidth: 10,
                  ),
                ]),
              if (position != null)
                MarkerLayer(markers: [
                  Marker(
                    point: position,
                    width: 36,
                    height: 36,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 36 * _pulseController.value + 10,
                            height: 36 * _pulseController.value + 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (runState.isTracking
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentBlue)
                                  .withValues(alpha: 0.25 * (1 - _pulseController.value)),
                            ),
                          ),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: runState.isTracking
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentBlue,
                              border:
                              Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: (runState.isTracking
                                      ? AppTheme.accentGreen
                                      : AppTheme.accentBlue)
                                      .withValues(alpha: 0.8),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
            ],
          ),

          // ── TOP GRADIENT ─────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0, height: 140,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.bg,
                    AppTheme.bg.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // ── STATS HUD ─────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16, right: 16,
            child: _StatsHUD(
              distance: runState.totalDistanceMeters / 1000,
              duration: _elapsed,
              isTracking: runState.isTracking,
              formatDuration: _formatDuration,
            ),
          ),

          // ── BOTTOM GRADIENT ───────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0, height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppTheme.bg, AppTheme.bg.withValues(alpha: 0)],
                ),
              ),
            ),
          ),

          // ── START/STOP BUTTON ─────────────────────────────────────
          Positioned(
            bottom: 36, left: 0, right: 0,
            child: Center(
              child: _RunButton(
                isTracking: runState.isTracking,
                onStart: _onStartRun,
                onStop: _onStopRun,
              ),
            ),
          ),

          // ── RECENTER BUTTON ───────────────────────────────────────
          Positioned(
            bottom: 120, right: 20,
            child: GestureDetector(
              onTap: () {
                if (position != null) _mapController.move(position, 17.0);
              },
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(Icons.my_location, color: AppTheme.accentBlue, size: 22),
              ),
            ),
          ),
        ]),
      );
    });
  }
}

// ── Stats HUD ──────────────────────────────────────────────────────────────

class _StatsHUD extends StatelessWidget {
  final double distance;
  final Duration duration;
  final bool isTracking;
  final String Function(Duration) formatDuration;

  const _StatsHUD({
    required this.distance,
    required this.duration,
    required this.isTracking,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _HudStat(
          label: 'DISTANCE',
          value: '${distance.toStringAsFixed(2)}',
          unit: 'km',
          color: AppTheme.accent,
        ),
        Container(width: 1, height: 36, color: AppTheme.border),
        _HudStat(
          label: 'TIME',
          value: formatDuration(duration),
          unit: '',
          color: AppTheme.accentBlue,
        ),
        Container(width: 1, height: 36, color: AppTheme.border),
        _HudStat(
          label: 'STATUS',
          value: isTracking ? 'LIVE' : 'IDLE',
          unit: '',
          color: isTracking ? AppTheme.accentGreen : AppTheme.textSecondary,
        ),
      ]),
    );
  }
}

class _HudStat extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _HudStat({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, letterSpacing: 1.5)),
      const SizedBox(height: 4),
      Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1)),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: 2),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(unit, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 11)),
          ),
        ]
      ]),
    ]);
  }
}

// ── Run Button ──────────────────────────────────────────────────────────────

class _RunButton extends StatelessWidget {
  final bool isTracking;
  final VoidCallback onStart, onStop;
  const _RunButton({required this.isTracking, required this.onStart, required this.onStop});

  @override
  Widget build(BuildContext context) {
    final color = isTracking ? AppTheme.accent : AppTheme.accentGreen;
    return GestureDetector(
      onTap: isTracking ? onStop : onStart,
      child: Container(
        width: 110, height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.bgCard,
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 30, spreadRadius: 4),
          ],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: color, size: 42),
          Text(isTracking ? 'STOP' : 'START',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2)),
        ]),
      ),
    );
  }
}

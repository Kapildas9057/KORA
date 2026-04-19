import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const TerritoryRunnerApp());
}

class TerritoryRunnerApp extends StatelessWidget {
  const TerritoryRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Territory Runner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const TrackerScreen(),
    );
  }
}

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  final List<LatLng> _pathPoints = [];
  StreamSubscription<Position>? _positionSub;
  bool _isTracking = false;
  String _status = 'Ready';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _status = 'Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _status = 'Location permission denied');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      _currentPosition = position;
      _status = 'Location ready';
    });

    _moveCameraToCurrent();
  }

  void _startTracking() {
    if (_isTracking) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) {
        final point = LatLng(position.latitude, position.longitude);

        setState(() {
          _currentPosition = position;
          _pathPoints.add(point);
        });

        _moveCameraToCurrent();
      },
      onError: (error) {
        setState(() => _status = 'GPS stream error: $error');
      },
    );

    setState(() {
      _isTracking = true;
      _status = 'Tracking started';
    });
  }

  void _stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
    setState(() {
      _isTracking = false;
      _status = 'Tracking stopped';
    });
  }

  void _clearPath() {
    setState(() {
      _pathPoints.clear();
      _status = 'Path cleared';
    });
  }

  void _moveCameraToCurrent() {
    final pos = _currentPosition;
    if (pos == null) return;

    _mapController.move(
      LatLng(pos.latitude, pos.longitude),
      17,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLatLng = _currentPosition == null
        ? const LatLng(37.7749, -122.4194)
        : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('Territory Runner - Step 1')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: currentLatLng, initialZoom: 16),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.territory_runner',
                ),
                if (_pathPoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: _pathPoints, strokeWidth: 5, color: Colors.blue),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 30,
                      height: 30,
                      point: currentLatLng,
                      child: const Icon(Icons.my_location, color: Colors.red, size: 28),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.black87,
            child: Text(
              'Status: $_status | Points: ${_pathPoints.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTracking ? null : _startTracking,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTracking ? _stopTracking : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearPath,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

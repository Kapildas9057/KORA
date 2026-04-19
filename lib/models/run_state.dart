import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class RunRecord {
  final DateTime date;
  final double distanceKm;
  final Duration duration;
  final int tilesVisited;

  RunRecord({
    required this.date,
    required this.distanceKm,
    required this.duration,
    required this.tilesVisited,
  });
}

class RunState extends ChangeNotifier {
  final List<LatLng> pathPoints = [];
  LatLng? currentPosition;
  bool isTracking = false;
  DateTime? _startTime;

  // Fake run history for dashboard
  final List<RunRecord> runHistory = [
    RunRecord(date: DateTime.now().subtract(const Duration(days: 1)), distanceKm: 3.2, duration: const Duration(minutes: 22), tilesVisited: 18),
    RunRecord(date: DateTime.now().subtract(const Duration(days: 2)), distanceKm: 5.1, duration: const Duration(minutes: 34), tilesVisited: 27),
    RunRecord(date: DateTime.now().subtract(const Duration(days: 4)), distanceKm: 2.8, duration: const Duration(minutes: 19), tilesVisited: 14),
    RunRecord(date: DateTime.now().subtract(const Duration(days: 6)), distanceKm: 6.4, duration: const Duration(minutes: 41), tilesVisited: 33),
    RunRecord(date: DateTime.now().subtract(const Duration(days: 7)), distanceKm: 4.0, duration: const Duration(minutes: 27), tilesVisited: 21),
  ];

  // Fake leaderboard data
  final List<Map<String, dynamic>> leaderboard = [
    {'rank': 1, 'name': 'ArjunRunner', 'tiles': 284, 'km': 87.4, 'avatar': '🦅'},
    {'rank': 2, 'name': 'SpeedQueen', 'tiles': 241, 'km': 72.1, 'avatar': '⚡'},
    {'rank': 3, 'name': 'YOU', 'tiles': 198, 'km': 61.5, 'avatar': '🔥'},
    {'rank': 4, 'name': 'NightRunner', 'tiles': 176, 'km': 54.2, 'avatar': '🌙'},
    {'rank': 5, 'name': 'TerritoryX', 'tiles': 154, 'km': 47.8, 'avatar': '🎯'},
    {'rank': 6, 'name': 'UrbanWolf', 'tiles': 132, 'km': 41.3, 'avatar': '🐺'},
    {'rank': 7, 'name': 'DawnPatrol', 'tiles': 119, 'km': 36.9, 'avatar': '🌅'},
    {'rank': 8, 'name': 'GridMaster', 'tiles': 98, 'km': 30.2, 'avatar': '🗺️'},
  ];

  int get totalTilesOwned => 198;
  int get totalRuns => runHistory.length;
  double get totalKm => runHistory.fold(0, (sum, r) => sum + r.distanceKm);
  Duration get currentRunDuration =>
      _startTime != null ? DateTime.now().difference(_startTime!) : Duration.zero;

  void addPoint(LatLng point) {
    currentPosition = point;
    if (isTracking) pathPoints.add(point);
    notifyListeners();
  }

  void startTracking() {
    isTracking = true;
    _startTime = DateTime.now();
    pathPoints.clear();
    notifyListeners();
  }

  void stopTracking() {
    if (isTracking && pathPoints.length >= 2) {
      runHistory.insert(0, RunRecord(
        date: DateTime.now(),
        distanceKm: totalDistanceMeters / 1000,
        duration: currentRunDuration,
        tilesVisited: (totalDistanceMeters / 50).round(),
      ));
    }
    isTracking = false;
    _startTime = null;
    notifyListeners();
  }

  double get totalDistanceMeters {
    if (pathPoints.length < 2) return 0.0;
    const Distance distance = Distance();
    double total = 0;
    for (int i = 0; i < pathPoints.length - 1; i++) {
      total += distance(pathPoints[i], pathPoints[i + 1]);
    }
    return total;
  }
}

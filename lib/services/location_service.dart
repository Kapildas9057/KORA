import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/run_state.dart';

class LocationService {
  StreamSubscription<Position>? _positionStream;

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) return false;
    return true;
  }

  void startTracking(RunState runState) {
    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    _positionStream = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((Position position) {
      runState.addPoint(LatLng(position.latitude, position.longitude));
    });
    runState.startTracking();
  }

  void stopTracking(RunState runState) {
    _positionStream?.cancel();
    _positionStream = null;
    runState.stopTracking();
  }

  void dispose() => _positionStream?.cancel();
}

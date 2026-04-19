# KORA - Territory Runner MVP (Step 1)

This repository contains Step 1 of the MVP:
- Get GPS location continuously
- Display location on map
- Draw path polyline while tracking

## Tech
- Flutter
- geolocator
- flutter_map (OpenStreetMap)
- latlong2

## Run
1. Install Flutter SDK.
2. From project root run:
   ```bash
   flutter pub get
   flutter run
   ```

## Permissions
- Android: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- iOS: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`

## Notes
This environment did not have Flutter installed, so files were scaffolded manually.

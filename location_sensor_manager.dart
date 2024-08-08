import 'package:geolocator/geolocator.dart';
import 'package:home_smart/model/geofence.dart';

class LocationSensorManager {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Position? _currentPosition;
  final List<Geofence> _geofences = [];

  Stream<Position> get locationStream =>
      _geolocatorPlatform.getPositionStream();

  Position? get currentPosition => _currentPosition;

  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return false;
      }
    }

    return true;
  }

  void dispose() {}

  void addGeofence(Geofence geofence) {
    _geofences.add(geofence);
  }

  void clearGeofences() {
    _geofences.clear();
  }

  bool isInsideGeofence(Position position) {
    for (final geofence in _geofences) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        geofence.latitude,
        geofence.longitude,
      );

      if (distance <= geofence.radius) {
        return true; // Inside a geofence
      }
    }

    return false; // Outside all geofences
  }
}

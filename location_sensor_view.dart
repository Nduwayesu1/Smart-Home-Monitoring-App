import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:home_smart/notifications/notification_manager.dart';
import 'package:home_smart/model/geofence.dart';
import 'package:home_smart/ui/geofence_selection_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:home_smart/sensors/location_sensor_manager.dart'; // Ensure this import is correct

class LocationSensorView extends StatefulWidget {
  const LocationSensorView({Key? key}) : super(key: key);

  @override
  _LocationSensorViewState createState() => _LocationSensorViewState();
}

class _LocationSensorViewState extends State<LocationSensorView> {
  late LocationSensorManager _locationSensorManager;
  final NotificationManager _notificationManager = NotificationManager();

  bool _isInsideGeofence = false;
  String _permissionStatus = 'Checking permissions...';
  List<Geofence> _selectedGeofences = [];
  Position? _currentPosition;
  String _currentLocationName = 'Fetching location...';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _locationSensorManager = LocationSensorManager();
    _notificationManager.init();
    _requestPermission();
  }

  @override
  void dispose() {
    _locationSensorManager.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    bool permissionGranted = await _locationSensorManager.requestPermission();
    setState(() {
      _permissionStatus = permissionGranted ? 'Permissions granted' : 'Permissions denied';
    });
  }

  void _showGeofenceSelectionScreen() {
    List<Geofence> availableGeofences = [
      Geofence(id: 'home', latitude: -1.9515333, longitude: 30.1146561, radius: 100.0),
      Geofence(id: 'office', latitude: -1.95554, longitude: 30.104281, radius: 200.0),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeofenceSelectionScreen(
          availableGeofences: availableGeofences,
          selectedGeofences: _selectedGeofences,
          onGeofencesSelected: (selectedGeofences) {
            setState(() {
              _selectedGeofences = selectedGeofences;
              _locationSensorManager.clearGeofences();
              _selectedGeofences.forEach(_locationSensorManager.addGeofence);
            });
          },
        ),
      ),
    );
  }

  Future<void> _updateLocationDetails(Position position) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () async {
      setState(() {
        _currentPosition = position;
      });

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          setState(() {
            _currentLocationName = [
              placemark.name,
              placemark.subLocality,
              placemark.locality,
              placemark.administrativeArea,
              placemark.country,
              placemark.postalCode,
            ].where((part) => part != null).join(', ') ?? 'Unknown Location';

            // Additional location details if available
            String district = placemark.subAdministrativeArea ?? 'N/A';
            String sector = placemark.locality ?? 'N/A';
            String cell = placemark.subLocality ?? 'N/A';
            String village = placemark.thoroughfare ?? 'N/A';

            _currentLocationName += '\nDistrict: $district\nSector: $sector\nCell: $cell\nVillage: $village';
          });
        } else {
          setState(() {
            _currentLocationName = 'No location found';
          });
        }
      } catch (e) {
        setState(() {
          _currentLocationName = 'Error fetching location';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Background color
      appBar: AppBar(
        title: const Text('Location Sensor'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<Position>(
        stream: _locationSensorManager.locationStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error occurred'));
          }

          final position = snapshot.data;
          if (position != null) {
            if (_currentPosition != position) {
              _updateLocationDetails(position);

              bool isInsideGeofence = _locationSensorManager.isInsideGeofence(position);

              if (isInsideGeofence != _isInsideGeofence) {
                _isInsideGeofence = isInsideGeofence;
                if (isInsideGeofence) {
                  _notificationManager.showGeofenceEntryNotification();
                } else {
                  _notificationManager.showGeofenceExitNotification();
                }
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Location: $_currentLocationName',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Geofence Status: ${_isInsideGeofence ? 'Inside' : 'Outside'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: Card(
                      elevation: 5,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(position.latitude, position.longitude),
                              ],
                              isCurved: true,
                              color: Colors.blue,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showGeofenceSelectionScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'Select Geofences',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Fetching location...'));
          }
        },
      ),
    );
  }
}

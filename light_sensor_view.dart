import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_smart/sensors/light_sensor_manager.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LightSensorView extends StatefulWidget {
  const LightSensorView({Key? key}) : super(key: key);

  @override
  _LightSensorViewState createState() => _LightSensorViewState();
}

class _LightSensorViewState extends State<LightSensorView> {
  final LightSensorManager _lightSensorManager = LightSensorManager();
  double _currentLightLevel = 0.0;
  final ScreenBrightness _screenBrightness = ScreenBrightness();
  final List<FlSpot> _lightLevelData = [];
  bool _shouldUpdateChart = false;

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _initSensor();
  }

  @override
  void dispose() {
    _lightSensorManager.dispose();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon'); // Ensure 'app_icon' is added in your assets

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _initSensor() async {
    try {
      _lightSensorManager.lightLevelStream.listen((lightLevel) {
        setState(() {
          _currentLightLevel = lightLevel;
          _lightLevelData.add(FlSpot(_lightLevelData.length.toDouble(), lightLevel));
          _shouldUpdateChart = true;
        });
        _adjustScreenBrightness(lightLevel);
        _controlSmartLights(lightLevel);
        _notifyUserIfNeeded(lightLevel);
      });
    } on PlatformException catch (e) {
      print("Failed to initialize ambient light sensor: '${e.message}'.");
    }
  }

  void _adjustScreenBrightness(double lightLevel) {
    try {
      _screenBrightness.setScreenBrightness(lightLevel / 100);
    } on PlatformException catch (e) {
      print("Failed to set screen brightness: ${e.message}");
    }
  }

  Future<void> _controlSmartLights(double lightLevel) async {
    // Mock implementation for smart light control
    // Replace with actual smart light API call
    try {
      final intensity = lightLevel / 100;
      print("Adjusting smart light intensity to: $intensity");

      // Example API call (Replace with actual API call)
      // await SmartLightAPI.setLightIntensity(intensity);

    } catch (e) {
      print("Failed to control smart lights: ${e.toString()}");
    }
  }

  Future<void> _notifyUserIfNeeded(double lightLevel) async {
    if (lightLevel < 10) { // Example threshold for notification
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'light_sensor_channel_id', 'Light Sensor Notifications',
              channelDescription: 'Channel for light sensor notifications',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await _notificationsPlugin.show(
        0,
        'Low Light Level',
        'Current light level is ${lightLevel.toStringAsFixed(1)} lx',
        platformChannelSpecifics,
        payload: 'item x',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Light Sensor Monitor'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChart(),
            const SizedBox(height: 24),
            _buildLightLevelControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 1.7,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: _shouldUpdateChart ? _lightLevelData : [],
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false), // Non-const initialization
              ),
            ],
            titlesData: const FlTitlesData(show: false), // Hide default titles
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.blueAccent,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildLightLevelControls() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Slider(
              value: _currentLightLevel,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${_currentLightLevel.toStringAsFixed(1)} lx',
              onChanged: (newValue) {
                setState(() {
                  _currentLightLevel = newValue;
                });
                _adjustScreenBrightness(newValue);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Light Level: ${_currentLightLevel.toStringAsFixed(1)} lx',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

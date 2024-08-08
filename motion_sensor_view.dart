import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_smart/notifications/notification_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class MotionSensorView extends StatefulWidget {
  @override
  _MotionSensorViewState createState() => _MotionSensorViewState();
}

class _MotionSensorViewState extends State<MotionSensorView> {
  bool isMotionDetected = false;
  late StreamSubscription<AccelerometerEvent> _streamSubscription;
  final NotificationManager _notificationManager = NotificationManager();
  final List<FlSpot> _accelerometerData = [];
  bool _shouldUpdateChart = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    startListening();
  }

  Future<void> _initializeNotifications() async {
    await _notificationManager.init();
  }

  void startListening() {
    _streamSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      double x = event.x;
      double y = event.y;
      double z = event.z;

      double magnitude = sqrt(x * x + y * y + z * z);
      bool motionDetected = magnitude > 15.0;

      setState(() {
        isMotionDetected = motionDetected;
        _accelerometerData.add(FlSpot(_accelerometerData.length.toDouble(), magnitude));
        _shouldUpdateChart = true;
      });

      if (motionDetected) {
        _notificationManager.showMotionDetectedNotification();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isMotionDetected ? Colors.red.shade100 : Colors.green.shade100,
      appBar: AppBar(
        title: Text('Motion Sensor'),
        backgroundColor: isMotionDetected ? Colors.red : Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusCard(),
            SizedBox(height: 16),
            _buildChart(),
            SizedBox(height: 16),
            _buildMotionIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          isMotionDetected ? 'Motion Detected' : 'No Motion Detected',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _shouldUpdateChart ? _accelerometerData : [],
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotionIcon() {
    return Icon(
      isMotionDetected ? Icons.person : Icons.person_outline,
      size: 100,
      color: isMotionDetected ? Colors.red : Colors.green,
    );
  }
}

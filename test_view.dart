import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class TestView extends StatefulWidget {
  @override
  _TestViewState createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  bool isMotionDetected = false;
  StreamSubscription<AccelerometerEvent>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    startListening();
  }

  void startListening() {
    _streamSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double x = event.x;
      double y = event.y;
      double z = event.z;

      // Perform motion detection logic here
      // Example: Check if the magnitude of acceleration exceeds a threshold
      double magnitude = (x * x) + (y * y) + (z * z);
      bool motionDetected = magnitude > 10.0;

      setState(() {
        isMotionDetected = motionDetected;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Stop listening to accelerometer events and cancel the subscription
    _streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Motion Detection Test',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 16),
          Text(
            isMotionDetected ? 'Motion Detected' : 'No Motion Detected',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

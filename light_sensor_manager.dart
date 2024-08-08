import 'package:flutter/material.dart';
import 'package:light/light.dart';

class LightSensorManager {
  final Light _lightSensor = Light();
  double _currentLightLevel = 0.0;

  Stream<double> get lightLevelStream =>
      _lightSensor.lightSensorStream.map((value) {
        _currentLightLevel = value.toDouble();
        return _currentLightLevel;
      });

  double get currentLightLevel => _currentLightLevel;

  void dispose() {
    // No need to dispose _lightSensor as it doesn't have a dispose method
  }
}

import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class MotionDetector {
  final double shakeThresholdGravity;
  final int shakeSlopTimeMS;
  final int shakeCountResetTime;
  final int minimumShakeCount;

  final StreamController<bool> _motionDetectionController =
      StreamController<bool>.broadcast();

  int _shakeTimestamp = DateTime.now().millisecondsSinceEpoch;
  int _shakeCount = 0;
  StreamSubscription? _streamSubscription;

  MotionDetector({
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
    this.minimumShakeCount = 1,
  });

  Stream<bool> get motionDetectionStream => _motionDetectionController.stream;

  void startListening() {
    _streamSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        double x = event.x;
        double y = event.y;
        double z = event.z;

        double gX = x / 9.80665;
        double gY = y / 9.80665;
        double gZ = z / 9.80665;

        double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

        if (gForce > shakeThresholdGravity) {
          var now = DateTime.now().millisecondsSinceEpoch;
          if (_shakeTimestamp + shakeSlopTimeMS > now) {
            return;
          }

          if (_shakeTimestamp + shakeCountResetTime < now) {
            _shakeCount = 0;
          }

          _shakeTimestamp = now;
          _shakeCount++;

          if (_shakeCount >= minimumShakeCount) {
            _motionDetectionController.add(true);
          }
        }
      },
      cancelOnError: true,
      onError: (error) {
        print('Error: $error');
      },
    );
  }

  void stopListening() {
    _streamSubscription?.cancel();
    _motionDetectionController.close();
  }
}

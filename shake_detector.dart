import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

typedef PhoneShakeCallback = void Function();

class ShakeDetector {
  final PhoneShakeCallback onPhoneShake;
  final double shakeThresholdGravity;
  final int shakeSlopTimeMS;
  final int shakeCountResetTime;
  final int minimumShakeCount;

  int mShakeTimestamp = DateTime.now().millisecondsSinceEpoch;
  int mShakeCount = 0;
  StreamSubscription? streamSubscription;

  ShakeDetector.waitForStart({
    required this.onPhoneShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
    this.minimumShakeCount = 1,
  });

  ShakeDetector.autoStart({
    required this.onPhoneShake,
    this.shakeThresholdGravity = 2.7,
    this.shakeSlopTimeMS = 500,
    this.shakeCountResetTime = 3000,
    this.minimumShakeCount = 1,
  }) {
    startListening();
  }

  void startListening() {
    // ignore: deprecated_member_use
    streamSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        double x = event.x;
        double y = event.y;
        double z = event.z;

        double gX = x / 9.80665;
        double gY = y / 9.80665;
        double gZ = z / 9.80665;

        double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

        print('Accelerometer Event: x=$x, y=$y, z=$z, gForce=$gForce');

        if (gForce > shakeThresholdGravity) {
          var now = DateTime.now().millisecondsSinceEpoch;
          if (mShakeTimestamp + shakeSlopTimeMS > now) {
            return;
          }

          if (mShakeTimestamp + shakeCountResetTime < now) {
            mShakeCount = 0;
          }

          mShakeTimestamp = now;
          mShakeCount++;

          if (mShakeCount >= minimumShakeCount) {
            print("Shake detected! Count: $mShakeCount");
            onPhoneShake();
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
    streamSubscription?.cancel();
  }
}

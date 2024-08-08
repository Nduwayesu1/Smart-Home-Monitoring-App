import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() {
    return _instance;
  }

  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> showMotionDetectedNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'motion_channel',
      'Motion Detection',
      importance: Importance.high,
      priority: Priority.high,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Motion Detected',
      'Unexpected movement has been detected.',
      platformChannelSpecifics,
    );
  }

  Future<void> showGeofenceEntryNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence',
      importance: Importance.high,
      priority: Priority.high,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      1,
      'Geofence Entered',
      'You have entered the predefined area.',
      platformChannelSpecifics,
    );
  }

  Future<void> showGeofenceExitNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence',
      importance: Importance.high,
      priority: Priority.high,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      2,
      'Geofence Exited',
      'You have exited the predefined area.',
      platformChannelSpecifics,
    );
  }
}

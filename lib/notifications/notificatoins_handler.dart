import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {

  NotificationHandler(): _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationDetails get details {
    final androidDetails = AndroidNotificationDetails(
      ANDROID_CHANNEL_ID,
      ANDROID_CHANNEL_NAME,
      ANDROID_CHANNEL_DESCRIPTION,
      importance: Importance.Max,
      priority: Priority.High,
      showProgress: true,
      progress: 0,
      channelShowBadge: true,
    );
    final iosDetails = IOSNotificationDetails();
    final allDetails = NotificationDetails(androidDetails, iosDetails);
    return allDetails;
  }

  void init() {
    final androidInitSettings =
        AndroidInitializationSettings('mipmap/ic_launcher');
    final iosInitSettings = IOSInitializationSettings();

    final initSettings =
        InitializationSettings(androidInitSettings, iosInitSettings);

    _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> scedule(int id, String title, String body, DateTime date,
      {String payload}) async {
    return _flutterLocalNotificationsPlugin.schedule(
      id,
      title,
      body,
      date,
      this.details,
      payload: payload,
    );
  }

  Future<void> show(int id, String title, String body, {String payload}) async {
    return _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      this.details,
      payload: payload,
    );
  }

  static NotificationHandler instance = NotificationHandler();

  static const String ANDROID_CHANNEL_ID =
          "com.hayat.hayat_app/notification_channel",
      ANDROID_CHANNEL_NAME = "Hayat App Channel",
      ANDROID_CHANNEL_DESCRIPTION = "Notification Channel for Hayat App";
}

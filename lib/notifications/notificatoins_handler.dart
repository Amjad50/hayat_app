import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hayat_app/notifications/notification_data.dart';

class NotificationHandler {
  NotificationHandler()
      : _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
        AndroidInitializationSettings(ANDROID_ICON_LOCATION);
    final iosInitSettings = IOSInitializationSettings();

    final initSettings =
        InitializationSettings(androidInitSettings, iosInitSettings);

    _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> show(int id, String title, String body, {String payload}) {
    return _flutterLocalNotificationsPlugin.show(
      _getNormalID(id),
      title,
      body,
      this.details,
      payload: payload,
    );
  }

  Future<void> scedule(int id, String title, String body, DateTime date,
      {String payload}) {
    return _flutterLocalNotificationsPlugin.schedule(
      _getScheduleID(id),
      title,
      body,
      date,
      this.details,
      payload: payload,
    );
  }

  Future<void> setupDailyNotifications() async {
    final notifies = <DailyNotificationData>[
      DailyNotificationData(
        "Good Morning",
        "Start your day with a nice morning and add some tasks to organize your day.",
        Time(8),
      ),
      DailyNotificationData(
        "Good Night",
        "Check your today's tasks completion and how you imporoved from yesterday.",
        Time(12 + 8),
      )
    ];

    for (int i = 0; i < notifies.length; i++) {
      final child = notifies[i];
      await _flutterLocalNotificationsPlugin.showDailyAtTime(
        _getDailyID(i),
        child.title,
        child.body,
        child.time,
        this.details,
        payload: child.payload,
      );
    }
  }

  int _getNormalID(int i) => _NORMAL_ID_BASE + i;
  int _getScheduleID(int i) => _SCHEDULE_ID_BASE + i;
  int _getDailyID(int i) => _DAILY_ID_BASE + i;

  static const int _NORMAL_ID_BASE = 0,
      _SCHEDULE_ID_BASE = 1000,
      _DAILY_ID_BASE = 3000;

  static NotificationHandler instance = NotificationHandler();

  static const String ANDROID_CHANNEL_ID =
          "com.hayat.hayat_app/notification_channel",
      ANDROID_CHANNEL_NAME = "Hayat App Channel",
      ANDROID_CHANNEL_DESCRIPTION = "Notification Channel for Hayat App",
      ANDROID_ICON_LOCATION =
          "mipmap/ic_launcher"; // TODO: design a logo and use it.
}

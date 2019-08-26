import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationData {
  NotificationData(this.title, this.body, {this.payload});

  final String title;
  final String body;
  final String payload;
}

class DailyNotificationData extends NotificationData {
  DailyNotificationData(String title, String body, this.time, {String payload})
      : super(title, body, payload: payload);

  final Time time;
}

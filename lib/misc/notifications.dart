import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:planner/misc/colors.dart';

abstract class LocalNotification {
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'Task notifications',
          channelKey: 'Task notifications',
          channelName: 'Task notifications',
          channelDescription: 'A channel for sending notifications about tasks.',
          defaultColor: mainColor,
          importance: NotificationImportance.Max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          onlyAlertOnce: true
        )
      ],
    );
    await AwesomeNotifications().requestPermissionToSendNotifications(
      permissions: [
        NotificationPermission.FullScreenIntent,
        NotificationPermission.Alert,
        NotificationPermission.Light,
        NotificationPermission.PreciseAlarms,
        NotificationPermission.Sound,
        NotificationPermission.Vibration,
      ]
    );
  }

  static Future<void> schedule(DateTime time, String title, String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: time.millisecondsSinceEpoch~/1000, 
        channelKey: 'Task notifications',
        title: title,
        body: message,
        wakeUpScreen: true,
        autoDismissible: true,
        category: NotificationCategory.Alarm
      ),
      actionButtons: [
        NotificationActionButton(
          key: "Postpone", 
          label: "Postpone",
        )
      ],
      schedule: NotificationCalendar.fromDate(
        date: time,
        allowWhileIdle: true,
        preciseAlarm: false,
        repeats: false,
      )
    );
  }

  static Future<void> cancelNotification(DateTime time) async {
    await AwesomeNotifications().cancel(time.millisecondsSinceEpoch~/1000);
  }

  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }

  static Future<void> debug() async {
    var temp = await AwesomeNotifications().listScheduledNotifications();
    temp.sort(
      (a,b) => DateTime.fromMillisecondsSinceEpoch(a.content!.id!*1000).compareTo(
        DateTime.fromMillisecondsSinceEpoch(b.content!.id!*1000)
      )
    );
    print("Printing debug info...");
    for(var i in temp) {
      print("${DateTime.fromMillisecondsSinceEpoch(i.content!.id!*1000)} - ${i.content!.title} - ${i.content!.body}");
    }
  }

}
// ignore_for_file: avoid_print, unused_element

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io'; // At the top of your file
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 🚀 This code runs even if the app is closed!
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 1. Initialize the service
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    // 1. 🚀 THE FCM LISTENER: This catches the "Poke" while the app is open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _notifications.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_reminder_channel', // Matches your channel ID
              'Daily Reminders',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // 2. 🛡️ CHANNEL REGISTRATION: Register the high-importance channel with Android
    final dynamic androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_reminder_channel',
          'Daily Reminders',
          description: 'Used for attendance pokes from Lenovo LOQ',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    // 3. 🔑 TOKEN FETCH: Print the token so you can paste it into your Python script
    String? token = await FirebaseMessaging.instance.getToken();
    print("-------------------------------------------------------");
    print("🚀 YOUR FCM TOKEN: $token");
    print("-------------------------------------------------------");
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // 1. Create the target time for today
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 2. 🛡️ YOUR BUFFER LOGIC:
    // If the time is within 15 seconds of 'now',
    // we treat it as "already passed" to avoid double-triggering or instant-firing glitches.
    if (scheduledDate.isBefore(now.add(const Duration(seconds: 15)))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 3. Add a small 15ms-15s "fudge factor" if you want to ensure it doesn't
    // fire at the exact millisecond the system is busy.
    return scheduledDate.add(const Duration(milliseconds: 150));
  }

  // Add this inside your NotificationService class in notification_service.dart
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> checkAndRequestAlarmPermission() async {
    if (Platform.isAndroid) {
      // 1. Check if we already have the permission
      final status = await Permission.scheduleExactAlarm.status;

      if (status.isDenied || status.isPermanentlyDenied) {
        // 2. This opens the "Alarms & Reminders" settings page specifically for YOUR app
        await openAppSettings();
        // Note: You can also use the 'permission_handler' to open the specific Alarm page
      }
    }
  }

  // 2. Simple Alert (For immediate warnings)
  static Future<void> showAttendanceWarning(String subject, int percent) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily attendance reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );
    Future<void> setupCloudNotifications() async {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request permission (Required for Android 13+)
      NotificationSettings settings = await messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 🚀 THIS IS THE KEY: Get the unique token for your Lenovo/Phone
        String? token = await messaging.getToken();
        print("--- YOUR DEVICE TOKEN ---");
        print(token);
        print("-------------------------");
      }
    }

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      1, // Notification ID
      '🚨 Danger Zone: $subject',
      'Your attendance is now $percent%. Attend the next class!',
      details,
    );
  }
}

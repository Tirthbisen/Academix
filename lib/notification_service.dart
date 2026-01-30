

// ignore_for_file: unused_element, avoid_print

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io'; 
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _notifications.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_reminder_channel', 
              'Daily Reminders',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    
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

    
    String? token = await FirebaseMessaging.instance.getToken();
    print("-------------------------------------------------------");
    print("🚀 YOUR FCM TOKEN: $token");
    print("-------------------------------------------------------");
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    
    
    
    if (scheduledDate.isBefore(now.add(const Duration(seconds: 15)))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    
    
    return scheduledDate.add(const Duration(milliseconds: 150));
  }

  
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> checkAndRequestAlarmPermission() async {
    if (Platform.isAndroid) {
      
      final status = await Permission.scheduleExactAlarm.status;

      if (status.isDenied || status.isPermanentlyDenied) {
        
        await openAppSettings();
        
      }
    }
  }

  
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

      
      NotificationSettings settings = await messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        
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
      1, 
      '🚨 Danger Zone: $subject',
      'Your attendance is now $percent%. Attend the next class!',
      details,
    );
  }
}

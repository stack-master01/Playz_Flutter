import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'package:flutter_playz_test/views/booking_history_screen.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> messages = [
    "⚡ Book now before it's gone!",
    "🔥 Hot deals waiting for you!",
    "⏳ Hurry! Limited time offer!",
    "🚀 Don't miss out, act fast!",
    "🎯 Perfect deal just for you!",
    "💥 Prices dropping fast!",
    "📢 Everyone is booking this now!",
    "👀 Still thinking? Grab it now!",
    "🎉 Special offer just unlocked!",
    "💎 Premium deal available!",
    "⚠️ Last few spots left!",
    "🛍️ Your next favorite is here!",
    "📈 Trending now, book fast!",
    "⏰ Time is running out!",
    "🚨 Deal ending soon!",
    "🎁 Surprise deal inside!",
    "🌟 Highly rated, book now!",
    "📌 Reserved just for you!",
    "🔥 Selling out quickly!",
    "💡 Smart users already booked!",
    "🎯 Best choice today!",
    "🚀 Fast movers are grabbing this!",
    "⚡ Instant booking available!",
    "📢 Don't wait, act now!",
    "💥 Deal of the day!",
    "🎉 Your offer is ready!",
    "🕒 Only a few minutes left!",
    "🔥 High demand alert!",
    "🎯 Top pick for today!",
    "📦 Ready when you are!",
    "💎 Exclusive deal unlocked!",
    "🚀 Join others booking now!",
    "⚠️ Limited availability!",
    "🎁 Grab your reward now!",
    "📈 Going fast!",
    "🔥 Act before it's gone!",
    "🎯 Perfect timing!",
    "🛍️ Best deal waiting!",
    "📢 Just dropped!",
    "💥 Flash sale live!",
    "⏰ Don't delay!",
    "🚨 Almost sold out!",
    "🎉 Lucky you!",
    "💡 Smart choice!",
    "📌 Your deal is live!",
    "🔥 Trending fast!",
    "🎯 You don't want to miss this!",
    "🚀 Book in seconds!",
    "⚡ Quick action needed!",
    "🎁 Special just for you!"
  ];

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload == 'booking_history') {
          Get.to(() => const BookingHistoryScreen());
        }
      },
    );
  }

  Future<void> requestPermission() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> scheduleBulkNotifications() async {
    await requestPermission(); // Safely request permission after UI is mounted
    
    const androidDetails = AndroidNotificationDetails(
      'bulk_channel',
      'Bulk Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );

    const details = NotificationDetails(android: androidDetails);

    for (int i = 0; i < messages.length; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: i,
        title: "🚀 Booking Alert",
        body: messages[i],
        scheduledDate: tz.TZDateTime.now(tz.local).add(Duration(minutes: i + 1)),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> showSlotBookedNotification(String date, String time, String turf) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Booking Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );

    const details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id: 888, // Unique ID for instant bookings
      title: "✅ Slot Booked Successfully!",
      body: "Your slot at $turf for $date, $time is confirmed. Tap to view.",
      notificationDetails: details,
      payload: 'booking_history',
    );
  }
}

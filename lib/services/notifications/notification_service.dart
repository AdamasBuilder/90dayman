import 'dart:io';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  FirebaseMessaging? _messaging;
  String? _fcmToken;
  bool _initialized = false;

  NotificationService._();

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await firebase_core.Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      // Request permission for iOS
      if (Platform.isIOS) {
        final settings = await _messaging!.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        print('Auth status: ${settings.authorizationStatus}');
      }

      // Get token
      _fcmToken = await _messaging!.getToken();
      print('FCM Token: $_fcmToken');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background/notification tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      _initialized = true;
    } catch (e) {
      print('Firebase init error: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      print('Received: ${notification.title} - ${notification.body}');
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('Tapped: ${message.notification?.title}');
  }

  Future<void> showTestNotification() async {
    print('Test notification sent');
  }
}

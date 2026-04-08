class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  String? _fcmToken;

  NotificationService._();

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // Placeholder for Firebase Cloud Messaging setup
    // To enable push notifications on iOS/Android, you'll need to:
    // 1. Create a Firebase project at https://console.firebase.google.com
    // 2. Add your app (iOS/Android) and download google-services.json / GoogleService-Info.plist
    // 3. Run: flutter pub add firebase_core firebase_messaging
    // 4. Re-implement this service with Firebase

    print('NotificationService initialized (placeholder)');
    print('To enable real push notifications, add Firebase to the project');
  }

  Future<void> showTestNotification() async {
    // For now, just print a message
    // Real implementation requires Firebase setup
    print('TEST NOTIFICATION: Il tuo percorso inizia oggi!');
  }

  Future<void> scheduleDailyMessage({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // Placeholder for scheduling
    print('Scheduled daily message at $hour:$minute: $title - $body');
  }
}

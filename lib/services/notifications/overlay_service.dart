class FocusModeHelper {
  static bool isMorningTime() {
    final hour = DateTime.now().hour;
    return hour >= 7 && hour < 9;
  }

  static bool isEveningTime() {
    final hour = DateTime.now().hour;
    return hour >= 21 && hour < 23;
  }

  static String getNextReminderTime() {
    final now = DateTime.now();

    if (now.hour < 7) {
      return '7:00';
    } else if (now.hour < 21) {
      return '21:00';
    } else {
      return 'Domani 7:00';
    }
  }
}

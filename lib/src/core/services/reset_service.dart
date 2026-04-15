import 'package:shared_preferences/shared_preferences.dart';

class ResetService {
  static const _lastResetKey = 'last_reset_date';

  Future<DateTime?> getLastResetDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastResetKey);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  Future<void> saveResetDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastResetKey, date.toIso8601String());
  }

  Future<bool> shouldReset() async {
    final lastReset = await getLastResetDate();
    final now = DateTime.now();

    if (lastReset == null) return true;

    return now.month != lastReset.month || now.year != lastReset.year;
  }
}

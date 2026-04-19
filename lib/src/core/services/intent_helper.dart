import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io';

class IntentHelper {
  static Future<void> openDataLimitSettings() async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.DATA_USAGE_SETTINGS',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      try {
        await intent.launch();
      } catch (e) {
        print("Gagal membuka pengaturan: $e");

        const fallbackIntent = AndroidIntent(
          action: 'android.settings.SETTINGS',
        );

        await fallbackIntent.launch();
      }
    }
  }
}
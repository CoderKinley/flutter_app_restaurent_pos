import 'package:flutter/services.dart';

class ImmersiveModeHelper {
  static Future<void> enterFullImmersiveMode() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive,
      overlays: [],
    );
  }

  static void setupImmersiveModeListener() {
    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
      if (systemOverlaysAreVisible) {
        // When system UI becomes visible, hide it again after a short delay
        await Future.delayed(const Duration(seconds: 1));
        await enterFullImmersiveMode();
      }
    });
  }
}

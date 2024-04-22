import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class DisableScreenshots {
  static Future<void> disable() async {
    if (Platform.isAndroid) {
      await _disableScreenshotsAndroid();
    } else if (Platform.isIOS) {
      await _disableScreenshotsIOS();
    }
  }

  static Future<void> _disableScreenshotsAndroid() async {
    try {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } on PlatformException catch (e) {
      print("Error disabling screenshots on Android: ${e.message}");
    }
  }

  static Future<void> _disableScreenshotsIOS() async {
    final platform = const MethodChannel('disable_screenshots');
    try {
      await platform.invokeMethod('disable');
    } on PlatformException catch (e) {
      print("Error disabling screenshots on iOS: ${e.message}");
    }
  }
}

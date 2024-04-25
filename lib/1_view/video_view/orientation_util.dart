import 'package:flutter/services.dart';

class OrientationUtil {
  static void enableOrientationAll() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  static void setPortraitUp() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  static void setPortraitDown() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
    ]);
  }

  static void setLandscape({
    bool isLeft = true,
  }) {
    if (isLeft) {
      setLandscapeLeft();
    } else {
      setLandscapeRight();
    }
  }

  static void setLandscapeLeft() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
  }

  static void setLandscapeRight() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
  }
}

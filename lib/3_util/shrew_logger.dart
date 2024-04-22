import 'package:logger/web.dart';

class SLogger {
  static void log(String message) {
    Logger().log(Level.info, 'info:$message');
  }

  static void error(String message) {
    Logger().log(Level.error, 'error:$message');
  }

  static void warning(String message) {
    Logger().log(Level.warning, 'warning:$message');
  }

  static void debug(String message) {
    Logger().log(Level.debug, 'debug:$message');
  }
}

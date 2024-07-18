import 'package:dotg_playground/0_init/route/dotg_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DotgNavigator {
  static Future<void> _goTo(BuildContext context, String name) async {
    return context.goNamed(name);
  }

  /// 홈화면
  static Future<void> navigateToHome(BuildContext context) {
    return _goTo(context, DotgRoute.home.name);
  }

  /// looping page view
  static Future<void> navigateToLoopingTest(BuildContext context) {
    return _goTo(context, DotgRoute.loopingTest.name);
  }

  /// round test view
  static Future<void> navigateToRoundTest(BuildContext context) {
    return _goTo(context, DotgRoute.roundTest.name);
  }

  /// fuse view
  static Future<void> navigateToFuseTest(BuildContext context) {
    return _goTo(context, DotgRoute.fuseTest.name);
  }

  /// quill view
  static Future<void> navigateToQuillTest(BuildContext context) {
    return _goTo(context, DotgRoute.quillTest.name);
  }

  /// tab indicator view
  static Future<void> navigateToTabIndicatorTest(BuildContext context) {
    return _goTo(context, DotgRoute.tanIndicatorTest.name);
  }

  /// bottom sliver view
  static Future<void> navigateToBottomSliverTest(BuildContext context) {
    return _goTo(context, DotgRoute.bottomSliverTest.name);
  }

  /// youtube player view
  static Future<void> navigateToYoutubePlayerTest(BuildContext context) {
    return _goTo(context, DotgRoute.youtubePlayerTest.name);
  }

  /// drag test view
  static Future<void> navigateToDragTest(BuildContext context) {
    return _goTo(context, DotgRoute.dragTest.name);
  }

  /// snap scroll test view
  static Future<void> navigateToSnapScrollTest(BuildContext context) {
    return _goTo(context, DotgRoute.sanpScrollTest.name);
  }

  /// scroll test view
  static Future<void> navigateToScrollTest(BuildContext context) {
    return _goTo(context, DotgRoute.scrollTest.name);
  }
}

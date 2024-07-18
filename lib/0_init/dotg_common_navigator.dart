import 'package:dotg_playground/0_init/route/dotg_common_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DotgCommonNavigator {
  static Future<void> _pushTo(
    BuildContext context,
    String routeName, {
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    Object? extra,
  }) {
    return context.pushNamed(routeName);
  }

  /// youtube link view
  static Future<void> navigateToYoutubeLink(
    BuildContext context, {
    required String videoUrl,
  }) async {
    return _pushTo(
      context,
      DotgCommonRoute.youtubePlayer.name,
      queryParams: {
        'videoId': videoUrl,
      },
    );
  }
}

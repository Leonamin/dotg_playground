import 'package:dotg_playground/0_init/route/dotg_common_route.dart';
import 'package:dotg_playground/0_init/route/dotg_route.dart';
import 'package:dotg_playground/1_view/bottom_sliver_view.dart';
import 'package:dotg_playground/1_view/drag_test_view.dart';
import 'package:dotg_playground/1_view/fuse_view.dart';
import 'package:dotg_playground/1_view/home_view.dart';
import 'package:dotg_playground/1_view/looping_page_view.dart';
import 'package:dotg_playground/1_view/quill_view.dart';
import 'package:dotg_playground/1_view/round_test_view.dart';
import 'package:dotg_playground/1_view/tab_indicator_view.dart';
import 'package:dotg_playground/1_view/test/scroll_ensure_test_view.dart';
import 'package:dotg_playground/1_view/test/snap_scroll_test_view.dart';
import 'package:dotg_playground/1_view/video_view/imfine_youtube_player_view.dart';
import 'package:dotg_playground/1_view/video_view/youtube_link_view.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(routes: [
  GoRoute(
    path: '/',
    redirect: (ctx, p1) => DotgRoute.home.path,
  ),
  GoRoute(
    name: DotgRoute.home.name,
    path: DotgRoute.home.path,
    builder: (context, state) => const HomeView(),
    routes: homeRoutes,
  ),
  ...commonRoutes,
]);

final homeRoutes = [
  GoRoute(
    name: DotgRoute.loopingTest.name,
    path: DotgRoute.loopingTest.path,
    builder: (context, state) => const LoopPageView('asd'),
  ),
  GoRoute(
    name: DotgRoute.roundTest.name,
    path: DotgRoute.roundTest.path,
    builder: (context, state) => const RoundTestView(),
  ),
  GoRoute(
    name: DotgRoute.fuseTest.name,
    path: DotgRoute.fuseTest.path,
    builder: (context, state) => const FuseView(),
  ),
  GoRoute(
    name: DotgRoute.quillTest.name,
    path: DotgRoute.quillTest.path,
    builder: (context, state) => QuillView(),
  ),
  GoRoute(
    name: DotgRoute.tanIndicatorTest.name,
    path: DotgRoute.tanIndicatorTest.path,
    builder: (context, state) => const TabIndicatorView(),
  ),
  GoRoute(
    name: DotgRoute.bottomSliverTest.name,
    path: DotgRoute.bottomSliverTest.path,
    builder: (context, state) => const BottomSliverView(),
  ),
  GoRoute(
    name: DotgRoute.youtubePlayerTest.name,
    path: DotgRoute.youtubePlayerTest.path,
    builder: (context, state) => const YoutubeTestView(),
  ),
  GoRoute(
    name: DotgRoute.dragTest.name,
    path: DotgRoute.dragTest.path,
    builder: (context, state) => const DragTestView(),
  ),
  GoRoute(
    name: DotgRoute.sanpScrollTest.name,
    path: DotgRoute.sanpScrollTest.path,
    builder: (context, state) => const SnapScrollTestView(),
  ),
  GoRoute(
    name: DotgRoute.scrollTest.name,
    path: DotgRoute.scrollTest.path,
    builder: (context, state) => const ScrollEnsureTestView(),
  ),
];

final commonRoutes = [
  GoRoute(
    name: DotgCommonRoute.youtubePlayer.name,
    path: DotgCommonRoute.youtubePlayer.path,
    builder: (context, state) {
      final videoUrl = state.uri.queryParameters['videoUrl'] ?? '';
      return ImfineYoutubePlayerView(videoUrl: videoUrl);
    },
  ),
];

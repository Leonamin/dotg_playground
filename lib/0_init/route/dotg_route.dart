enum DotgRoute {
  // 홈
  home,
  // 홈 하위
  loopingTest,
  roundTest,
  fuseTest,
  quillTest,
  tanIndicatorTest,
  bottomSliverTest,
  youtubePlayerTest,
  dragTest,
  sanpScrollTest,
  scrollTest;

  String get name => toString();

  String get path {
    switch (this) {
      case DotgRoute.home:
        return '/home';
      case DotgRoute.loopingTest:
        return 'looping_test';
      case DotgRoute.roundTest:
        return 'round_test';
      case DotgRoute.fuseTest:
        return 'fuse_test';
      case DotgRoute.quillTest:
        return 'quill_test';
      case DotgRoute.tanIndicatorTest:
        return 'tab_indicator_test';
      case DotgRoute.bottomSliverTest:
        return 'bottom_sliver_test';
      case DotgRoute.youtubePlayerTest:
        return 'youtube_player_test';
      case DotgRoute.dragTest:
        return 'drag_test';
      case DotgRoute.sanpScrollTest:
        return 'run_js_test';
      case DotgRoute.scrollTest:
        return 'scroll_test';
    }
  }
}

enum DotgCommonRoute {
  youtubePlayer;

  String get name => toString();
  String get path {
    switch (this) {
      case DotgCommonRoute.youtubePlayer:
        return '/youtube_player';
    }
  }
}

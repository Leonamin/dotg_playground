import 'package:dotg_playground/1_view/video_view/drag_action_widget.dart';
import 'package:dotg_playground/1_view/video_view/orientation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ImfineYoutubeThumbnailView extends StatelessWidget {
  final String videoUrl;
  final BuildContext context;
  final Function(String videoUrl)? onTapThumbnail;

  const ImfineYoutubeThumbnailView({
    super.key,
    required this.videoUrl,
    required this.context,
    this.onTapThumbnail,
  });

  String get _videoId => YoutubePlayer.convertUrlToId(videoUrl) ?? '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTapThumbnail?.call(videoUrl),
      child: Stack(
        children: [
          Image.network(
            YoutubePlayer.getThumbnail(
              videoId: _videoId,
            ),
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : Container(color: Colors.black),
            errorBuilder: (context, _, __) => Image.network(
              YoutubePlayer.getThumbnail(
                videoId: _videoId,
                webp: false,
              ),
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : Container(color: Colors.black),
              errorBuilder: (context, _, __) => Container(color: Colors.black),
            ),
          ),
          const Positioned.fill(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 60.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImfineYoutubePlayerView extends StatefulWidget {
  final String videoUrl;

  const ImfineYoutubePlayerView({
    super.key,
    required this.videoUrl,
  });

  @override
  State<ImfineYoutubePlayerView> createState() =>
      _ImfineYoutubePlayerViewState();
}

class _ImfineYoutubePlayerViewState extends State<ImfineYoutubePlayerView>
    with WidgetsBindingObserver {
  late YoutubePlayerController _vc;

  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    _vc = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    OrientationUtil.enableOrientationAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// 현재화면에서 앱 밖으로 나갔을 때, 시스템 UI가 보이도록 설정
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _hideSystemUi();
        if (_isFullScreen) {
          _setLandscape();
        } else {
          _setPortrait();
        }
        break;
      case AppLifecycleState.paused:
        _showSystemUi();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _hideSystemUi();

    final appBar = AppBar(
      backgroundColor: Colors.black,
    );

    return OrientationBuilder(builder: (context, orientation) {
      final isLandScape = orientation == Orientation.landscape;

      _isFullScreen = isLandScape;

      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (_isFullScreen) {
            _setPortrait();
          } else {
            Navigator.of(context).pop();
          }
        },
        child: GestureDetector(
          onTap: _onTapBackground,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _isFullScreen ? null : appBar,
            backgroundColor: Colors.black,
            body: DragActionWidget(
              // enableWidgetDrag: _isFullScreen,
              onDragEnd: () {
                if (_isFullScreen) {
                  _setPortrait();
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: _VideoContent(
                    vc: _vc,
                    ratio: _getRatio(_isFullScreen),
                    isFullScreen: _isFullScreen,
                    onTapFullScreen: _onTapFullScreen,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _setPortrait();
    _showSystemUi();
    super.dispose();
  }

  void _setPortrait() {
    OrientationUtil.setPortrait();
  }

  void _setLandscape() {
    OrientationUtil.setLandscape();
  }

  void _onTapFullScreen() {
    if (_isFullScreen) {
      _setPortrait();
    } else {
      _setLandscape();
    }
  }

  /// 영상의 재생바, 재생버튼 등을 보여주려는 용도
  void _onTapBackground() {
    if (_vc.value.isControlsVisible) {
      _vc.updateValue(_vc.value.copyWith(isControlsVisible: false));
    } else {
      _vc.updateValue(_vc.value.copyWith(isControlsVisible: true));
    }
  }

  double _getRatio(bool isFullScreen) {
    if (isFullScreen) {
      return MediaQuery.of(context).size.height /
          MediaQuery.of(context).size.width;
    } else {
      return 16 / 9;
    }
  }

  void _showSystemUi() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  void _hideSystemUi() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }
}

class SizeFactorBox extends StatelessWidget {
  // min 0.0 max 1.0
  final double? heightSizeFactor;
  final double? widthSizeFactor;
  final double? height;
  final double? width;
  final Widget child;

  const SizeFactorBox({
    super.key,
    this.heightSizeFactor,
    this.widthSizeFactor,
    this.height,
    this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = heightSizeFactor != null
            ? constraints.maxHeight * heightSizeFactor!
            : this.height;
        final width = widthSizeFactor != null
            ? constraints.maxWidth * widthSizeFactor!
            : this.width;

        return SizedBox(
          height: height,
          width: width,
          child: child,
        );
      },
    );
  }
}

class _VideoContent extends StatelessWidget {
  final YoutubePlayerController vc;
  final double ratio;
  final bool isFullScreen;
  final VoidCallback onTapFullScreen;

  final Color? progressIndicatorColor;

  const _VideoContent({
    required this.vc,
    required this.ratio,
    required this.isFullScreen,
    required this.onTapFullScreen,
    this.progressIndicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      key: key,
      controller: vc,
      aspectRatio: ratio,
      showVideoProgressIndicator: true,
      progressIndicatorColor: progressIndicatorColor ?? Colors.blue,
      progressColors: ProgressBarColors(
        playedColor: progressIndicatorColor ?? Colors.blue,
        handleColor: progressIndicatorColor ?? Colors.blue,
        backgroundColor: Colors.black12,
      ),
      bottomActions: [
        const SizedBox(width: 14.0),
        CurrentPosition(),
        const SizedBox(width: 8.0),
        ProgressBar(
          isExpanded: true,
          colors: ProgressBarColors(
            playedColor: progressIndicatorColor ?? Colors.blue,
            handleColor: progressIndicatorColor ?? Colors.blue,
            backgroundColor: Colors.black12,
          ),
        ),
        RemainingDuration(),
        const PlaybackSpeedButton(),
        _FullScreenButton(
          isFullScreen: isFullScreen,
          onTap: onTapFullScreen,
        ),
      ],
    );
  }
}

class _FullScreenButton extends StatelessWidget {
  final bool isFullScreen;
  final VoidCallback? onTap;
  final Color? color;

  const _FullScreenButton({
    required this.isFullScreen,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: color ?? Colors.white,
      ),
      onPressed: onTap,
    );
  }
}

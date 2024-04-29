import 'package:dotg_playground/0_component/drag/0_data/drag_properties.dart';
import 'package:dotg_playground/0_component/drag/drag_transition_widget.dart';
import 'package:dotg_playground/1_view/video_view/orientation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
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

  double _lastAccelerometerX = 0.0;

  DateTime _lastUserInteraction =
      DateTime.now().subtract(_userInteractionTimeout);

  static const Duration _userInteractionTimeout = Duration(seconds: 1);

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

    accelerometerEvents.listen(_onListenAccelerometer);
  }

  /// 현재화면에서 앱 밖으로 나갔을 때, 시스템 UI가 보이도록 설정
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _hideSystemUi();
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

      final widgetHeight = MediaQuery.of(context).size.height;
      final widgetWidth = MediaQuery.of(context).size.width;

      final moveUpThreshold = MediaQuery.of(context).size.height / 10;
      final moveDownThreshold = MediaQuery.of(context).size.height / 3;
      final zoomInThreshold = MediaQuery.of(context).size.height / 6;

      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          _onActionBack(context);
        },
        child: GestureDetector(
          onTap: _onTapBackground,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _isFullScreen ? null : appBar,
            backgroundColor: Colors.black,
            body: DragTransitionWidget(
              enableMove: true,
              moveConfig: DragMoveConfig(
                moveTopToBottom: DragMoveProperties(
                  dragThreshold: moveDownThreshold,
                ),
                moveBottomToTop: DragMoveProperties(
                  dragThreshold: moveUpThreshold,
                ),
              ),
              zoomConfig: DragZoomConfig(
                zoomTopToBottom: DragZoomProperties(
                  type: DragZoomType.zoomOut,
                  scaleLimit: 0.8,
                  dragThreshold: zoomInThreshold,
                ),
                zoomBottomToTop: DragZoomProperties(
                  type: DragZoomType.zoomIn,
                  scaleLimit: 1.2,
                  dragThreshold: zoomInThreshold,
                ),
              ),
              dragEndEvents: [
                DragEndEventConfig(
                  direction: DragDirection.down,
                  dragThreshold: moveDownThreshold,
                  onDragEnd: () => _onActionBack(context),
                ),
                DragEndEventConfig(
                  direction: DragDirection.up,
                  dragThreshold: moveUpThreshold,
                  onDragEnd: () => _onActionDragUp(context),
                ),
              ],
              child: SizedBox(
                width: widgetWidth,
                height: widgetHeight,
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
    _setFullScreen(false);
    _showSystemUi();
    super.dispose();
  }

  void _onListenAccelerometer(AccelerometerEvent event) {
    _lastAccelerometerX = event.x;

    // 가로모드가 아닌 경우 무시
    if (!_isFullScreen) return;

    if (!_isAfterUserInteraction(DateTime.now())) return;

    _setFullScreen(true);
  }

  bool _isAfterUserInteraction(DateTime dt) {
    return dt.isAfter(_lastUserInteraction.add(_userInteractionTimeout));
  }

  void _onActionBack(BuildContext context) {
    if (_isFullScreen) {
      _lastUserInteraction = DateTime.now();
      _setFullScreen(false);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onActionDragUp(BuildContext context) {
    if (!_isFullScreen) {
      _lastUserInteraction = DateTime.now();
      _setFullScreen(true);
    }
  }

  void _setFullScreen(bool fullScreen) {
    if (fullScreen) {
      _setLandscape();
    } else {
      _setPortrait();
    }
  }

  void _setPortrait() {
    OrientationUtil.setPortraitUp();
  }

  void _setLandscape() {
    if (_lastAccelerometerX > -7.0) {
      _setLandScapeLeft();
    } else {
      _setLandScapeRight();
    }
  }

  void _setLandScapeLeft() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void _setLandScapeRight() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _onTapFullScreen() {
    _lastUserInteraction = DateTime.now();

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

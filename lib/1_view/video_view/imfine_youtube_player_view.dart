import 'package:dotg_playground/0_component/animation/animated_skip_widget.dart';
import 'package:dotg_playground/0_component/drag/0_data/drag_properties.dart';
import 'package:dotg_playground/0_component/drag/drag_transition_widget.dart';
import 'package:dotg_playground/1_view/video_view/orientation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  late final AnimatedSkipController _skipAc = AnimatedSkipController();
  late YoutubePlayerController _vc;

  bool _isFullScreen = false;

  double _lastAccelerometerX = 0.0;

  DateTime _lastUserInteraction =
      DateTime.now().subtract(_userInteractionTimeout);

  DateTime _lastFastForward = DateTime.now().subtract(_userInteractionTimeout);

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
              onLongPressStart: _onLongPressStart,
              onLongPressEnd: _onLongPressEnd,
              onTapDoubleDown: _onTapDoubleDown,
              child: SizedBox(
                width: widgetWidth,
                height: widgetHeight,
                child: Center(
                  child: _VideoContent(
                    vc: _vc,
                    skipAc: _skipAc,
                    ratio: _getRatio(_isFullScreen),
                    isFullScreen: _isFullScreen,
                    isSpeedUp: _isSpeedUp,
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

  ///  배속 관련
  double _lastPlaybackRate = PlaybackRate.normal;

  bool _isSpeedUp = false;

  void _onLongPressStart(LongPressStartDetails details) {
    _lastPlaybackRate = _vc.value.playbackRate;
    _vc.setPlaybackRate(PlaybackRate.twice);
    setState(() {
      _isSpeedUp = true;
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _vc.setPlaybackRate(_lastPlaybackRate);
    setState(() {
      _isSpeedUp = false;
    });
  }

  // 빨리 감기
  void _onTapDoubleDown(TapDownDetails details) {
    if (!_isAfterUserInteraction(DateTime.now())) return;

    final halfWidth = MediaQuery.of(context).size.width / 2;
    details.globalPosition.dx < halfWidth ? _onRewind() : _onFastForward();
  }

  void _onFastForward() {
    _skipAc.animateFastForward();
    _lastFastForward = DateTime.now();
    _vc.seekTo(_vc.value.position + const Duration(seconds: 10));
  }

  void _onRewind() {
    _skipAc.animateRewind();
    _lastFastForward = DateTime.now();
    _vc.seekTo(_vc.value.position - const Duration(seconds: 10));
  }
}

class _VideoContent extends StatelessWidget {
  final YoutubePlayerController vc;
  final AnimatedSkipController skipAc;

  final double ratio;
  final Color? progressIndicatorColor;

  final bool isFullScreen;
  final bool isSpeedUp;

  final VoidCallback onTapFullScreen;

  const _VideoContent({
    required this.vc,
    required this.skipAc,
    required this.ratio,
    required this.isFullScreen,
    required this.isSpeedUp,
    required this.onTapFullScreen,
    this.progressIndicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        YoutubePlayer(
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
        ),
        Positioned.fill(
          top: 8,
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              opacity: isSpeedUp ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: const _SpeedUpIndicator(),
            ),
          ),
        ),
        Positioned.fill(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedSkipWidget(
            controller: skipAc,
          ),
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

class _SpeedUpIndicator extends StatelessWidget {
  const _SpeedUpIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.fast_forward,
              color: Colors.white,
              size: 14.0,
            ),
            SizedBox(width: 8.0),
            Text(
              '2.0x',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

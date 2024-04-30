import 'package:dotg_playground/0_component/animation/animated_skip_widget.dart';
import 'package:dotg_playground/0_component/drag/0_data/drag_properties.dart';
import 'package:dotg_playground/0_component/drag/drag_transition_widget.dart';
import 'package:dotg_playground/1_view/video_view/0_component/from_to.dart';
import 'package:dotg_playground/1_view/video_view/orientation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

part '0_component/imfine_youtube_player.dart';

class ImfineYoutubePlayerView extends StatefulWidget {
  final String videoUrl;

  /// 빨리감기, 되감기 시간
  final Duration skipDuration;

  /// 전체 너비 중 되감기 영역의 비율
  final FromTo rewindAreaFactor;

  /// 전체 너비 중 빨리감기 영역의 비율
  final FromTo fastForwardAreaFactor;

  /// 사용자 터치 무시하는 타임아웃
  final Duration userInteractionTimeout;

  const ImfineYoutubePlayerView({
    super.key,
    required this.videoUrl,
    this.skipDuration = const Duration(seconds: 10),
    this.rewindAreaFactor = const FromTo(0.0, 0.4),
    this.fastForwardAreaFactor = const FromTo(0.6, 1.0),
    this.userInteractionTimeout = const Duration(seconds: 1),
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

  late DateTime _lastUserInteraction =
      DateTime.now().subtract(_userInteractionTimeout);

  Duration get _userInteractionTimeout => widget.userInteractionTimeout;

  FromTo get _rewindAreaFactor => widget.rewindAreaFactor;
  FromTo get _fastForwardAreaFactor => widget.fastForwardAreaFactor;

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
                  child: ImfineYoutubePlayer(
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

    final touchX = details.globalPosition.dx;

    if (_isInRewindArea(touchX)) {
      _onRewind();
    }

    if (_isInFastForwardArea(touchX)) {
      _onFastForward();
    }
  }

  bool _isInRewindArea(double x) {
    final rewindAreaStart =
        MediaQuery.of(context).size.width * _rewindAreaFactor.from;
    final rewindAreaEnd =
        MediaQuery.of(context).size.width * _rewindAreaFactor.to;

    return x >= rewindAreaStart && x <= rewindAreaEnd;
  }

  bool _isInFastForwardArea(double x) {
    final fastForwardAreaStart =
        MediaQuery.of(context).size.width * _fastForwardAreaFactor.from;
    final fastForwardAreaEnd =
        MediaQuery.of(context).size.width * _fastForwardAreaFactor.to;

    return x >= fastForwardAreaStart && x <= fastForwardAreaEnd;
  }

  void _onFastForward() {
    _skipAc.animateFastForward();
    _vc.seekTo(_vc.value.position + widget.skipDuration);
  }

  void _onRewind() {
    _skipAc.animateRewind();
    _vc.seekTo(_vc.value.position - widget.skipDuration);
  }
}

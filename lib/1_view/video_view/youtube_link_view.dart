import 'package:dotg_playground/1_view/video_view/device_orientation_util.dart';
import 'package:dotg_playground/3_util/shrew_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeLinkView extends StatefulWidget {
  const YoutubeLinkView({super.key});

  @override
  State<YoutubeLinkView> createState() => _YoutubeLinkViewState();
}

class _YoutubeLinkViewState extends State<YoutubeLinkView> {
  final GlobalKey _youtubeKey = GlobalKey();
  late YoutubePlayerController _vc;

  double _ratio = 16 / 9;

  bool _isFullScreen = false;

  Duration _lastPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(
        'https://youtu.be/fD8Yj4kNh50?list=RDfD8Yj4kNh50');

    _vc = YoutubePlayerController(
      initialVideoId: videoId ?? 'iLnmTe5Q2Qw',
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('사실 다시 빌드하기 때문에 의미 없어!');
    final videoWidget = _buildYoutube(ratio: _getRatio(_isFullScreen));

    return OrientationBuilder(builder: (context, orientation) {
      final isPortrait = orientation == Orientation.portrait;
      final isLandScape = orientation == Orientation.landscape;

      // if (isLandScape) {
      //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // } else {
      //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // }
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          print('DOTG 나가자!, $didPop');
          if (isLandScape) {
            _setPortrait();
            _isFullScreen = false;
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: isPortrait ? AppBar() : null,
          body: _isFullScreen
              ? _VideoContent(
                  key: _youtubeKey,
                  vc: _vc,
                  ratio: _ratio,
                  isFullScreen: _isFullScreen,
                  onTapFullScreen: _onTapFullScreen,
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _VideoContent(
                        key: _youtubeKey,
                        vc: _vc,
                        ratio: _ratio,
                        isFullScreen: _isFullScreen,
                        onTapFullScreen: _onTapFullScreen,
                      )
                    ],
                  ),
                ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _setPortrait();
    super.dispose();
  }

  void _setPortrait() {
    DeviceOrientationUtil.setPortrait();
  }

  void _setLandscape() {
    DeviceOrientationUtil.setLandscape();
  }

  Widget _buildYoutube({
    required double ratio,
  }) {
    SLogger.debug(
      'DOTG 마지막 포지션, ${_vc.value.position}',
    );
    return YoutubePlayer(
      key: _youtubeKey,
      controller: _vc,
      aspectRatio: ratio,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.amber,
      progressColors: const ProgressBarColors(
        playedColor: Colors.amber,
        handleColor: Colors.amberAccent,
      ),
      onReady: () {
        _vc.addListener(_onReadyListener);
      },
      bottomActions: [
        const SizedBox(width: 14.0),
        CurrentPosition(),
        const SizedBox(width: 8.0),
        ProgressBar(
          isExpanded: true,
          colors: ProgressBarColors(
            playedColor: Colors.amber,
            handleColor: Colors.amberAccent,
          ),
        ),
        RemainingDuration(),
        const PlaybackSpeedButton(),
        _FullScreenButton(
          isFullScreen: _isFullScreen,
          onTap: _onTapFullScreen,
        ),
      ],
    );
  }

  void _onReadyListener() {}

  void _onTapFullScreen() {
    _isFullScreen = !_isFullScreen;
    _lastPosition = _vc.value.position;
    setState(() {});
    if (_isFullScreen) {
      _setLandscape();
      Future.delayed(const Duration(milliseconds: 2500), () {
        _vc.play();
      });
    } else {
      _setPortrait();

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          _vc.play();
        });
      });
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
}

class _VideoContent extends StatelessWidget {
  final YoutubePlayerController vc;
  final double ratio;
  final bool isFullScreen;
  final VoidCallback onTapFullScreen;

  const _VideoContent({
    super.key,
    required this.vc,
    required this.ratio,
    required this.isFullScreen,
    required this.onTapFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      key: key,
      controller: vc,
      aspectRatio: ratio,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.amber,
      progressColors: const ProgressBarColors(
        playedColor: Colors.amber,
        handleColor: Colors.amberAccent,
      ),
      onReady: () {},
      bottomActions: [
        const SizedBox(width: 14.0),
        CurrentPosition(),
        const SizedBox(width: 8.0),
        ProgressBar(
          isExpanded: true,
          colors: ProgressBarColors(
            playedColor: Colors.amber,
            handleColor: Colors.amberAccent,
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
    super.key,
    required this.isFullScreen,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: color,
      ),
      onPressed: onTap,
    );
  }
}

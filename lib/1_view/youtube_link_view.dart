import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeLinkView extends StatefulWidget {
  const YoutubeLinkView({super.key});

  @override
  State<YoutubeLinkView> createState() => _YoutubeLinkViewState();
}

class _YoutubeLinkViewState extends State<YoutubeLinkView> {
  late YoutubePlayerController _vc;

  double _ratio = 16 / 9;

  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(
        'https://youtu.be/fD8Yj4kNh50?list=RDfD8Yj4kNh50');

    _vc = YoutubePlayerController(
      initialVideoId: videoId ?? 'iLnmTe5Q2Qw',
      flags: YoutubePlayerFlags(
        autoPlay: true,
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
              ? videoWidget
              : SingleChildScrollView(
                  child: Column(
                    children: [videoWidget],
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _setLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Widget _buildYoutube({
    required double ratio,
  }) {
    return YoutubePlayer(
      key: const ValueKey('youtube_player'),
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
    setState(() {});
    if (_isFullScreen) {
      _setLandscape();
    } else {
      _setPortrait();
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

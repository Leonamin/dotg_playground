part of '../imfine_youtube_player_view.dart';

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

  ProgressBarColors get progressColors => ProgressBarColors(
        playedColor: progressIndicatorColor ?? Colors.blue,
        handleColor: progressIndicatorColor ?? Colors.blue,
        backgroundColor: Colors.black12,
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        YoutubePlayer(
          controller: vc,
          aspectRatio: ratio,
          showVideoProgressIndicator: true,
          progressIndicatorColor: progressIndicatorColor ?? Colors.blue,
          progressColors: progressColors,
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
            PlaybackSpeedButton(),
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

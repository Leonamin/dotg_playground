import 'package:dotg_playground/0_component/animation/animated_skip_widget.dart';
import 'package:dotg_playground/1_view/video_view/imfine_youtube_player_view.dart';
import 'package:flutter/material.dart';
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

class YoutubeTestView extends StatelessWidget {
  const YoutubeTestView({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = AnimatedSkipController();

    TextEditingController tc = TextEditingController();
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // FastForwardIconsWidget(),
              GestureDetector(
                onDoubleTapDown: (details) {
                  final halfWidth = MediaQuery.of(context).size.width / 2;
                  details.globalPosition.dx < halfWidth
                      ? ac.animateRewind()
                      : ac.animateFastForward();
                },
                child: SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: AnimatedSkipWidget(
                    controller: ac,
                  ),
                ),
              ),
              TextField(
                controller: tc,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (tc.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a video URL'),
                      ),
                    );
                    return;
                  }
                  _onTapGoYoutube(context, tc.text);
                },
                child: const Text('Go Youtube'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _onTapGoMagnetic(context);
                },
                child: const Text('Go Magnetic'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapGoMagnetic(BuildContext context) {
    _onTapGoYoutube(context, 'https://youtu.be/fD8Yj4kNh50');
  }

  void _onTapGoYoutube(BuildContext context, String videoUrl) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ImfineYoutubePlayerView(
            videoUrl: videoUrl,
          );
        },
      ),
    );
  }
}

import 'dart:io';

import 'package:dotg_playground/1_view/bottom_sliver_view.dart';
import 'package:dotg_playground/1_view/drag_test_view.dart';
import 'package:dotg_playground/1_view/fuse_view.dart';
import 'package:dotg_playground/1_view/looping_page_view.dart';
import 'package:dotg_playground/1_view/quill_view.dart';
import 'package:dotg_playground/1_view/round_test_view.dart';
import 'package:dotg_playground/1_view/tab_indicator_view.dart';
import 'package:dotg_playground/1_view/test/scroll_ensure_test_view.dart';
import 'package:dotg_playground/1_view/test/snap_scroll_test_view.dart';
import 'package:dotg_playground/1_view/video_view/youtube_link_view.dart';
import 'package:dotg_playground/3_util/navigator_helper.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _lastPopTime = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onActionPopInvoked();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('땃쥐 놀이터'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  NavigatorHelper.push(
                    context,
                    const LoopPageView('asd'),
                  );
                },
                child: const Text('Looping Page View'),
              ),
              ElevatedButton(
                onPressed: () {
                  NavigatorHelper.push(
                    context,
                    const RoundTestView(),
                  );
                },
                child: const Text('Round Test View'),
              ),
              ElevatedButton(
                onPressed: () {
                  NavigatorHelper.push(
                    context,
                    const FuseView(),
                  );
                },
                child: const Text('Fuse View'),
              ),
              ElevatedButton(
                onPressed: () {
                  NavigatorHelper.push(
                    context,
                    QuillView(),
                  );
                },
                child: const Text('Quill View'),
              ),
              ElevatedButton(
                onPressed: () {
                  NavigatorHelper.push(
                    context,
                    const TabIndicatorView(),
                  );
                },
                child: const Text('TabIndicator View'),
              ),
              const _NavigatorButton(
                  text: 'BottomSliverView', page: BottomSliverView()),
              const _NavigatorButton(
                  text: 'YoutubeLinkView', page: YoutubeTestView()),
              const _NavigatorButton(text: 'DragTest', page: DragTestView()),
              const _NavigatorButton(text: 'RunJs', page: SnapScrollTestView()),
              const _NavigatorButton(
                  text: 'ScrollTest', page: ScrollEnsureTestView()),
            ],
          ),
        ),
      ),
    );
  }

  void _onActionPopInvoked() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastPopTime > 1000) {
      _lastPopTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('한 번 더 누르면 종료됩니다.'),
        ),
      );
    } else {
      exit(0);
    }
  }
}

class _NavigatorButton extends StatelessWidget {
  final String text;
  final Widget page;
  const _NavigatorButton({
    super.key,
    required this.text,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        NavigatorHelper.push(
          context,
          page,
        );
      },
      child: Text(text),
    );
  }
}

import 'dart:io';

import 'package:dotg_playground/0_init/dotg_navigator.dart';
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
                  DotgNavigator.navigateToLoopingTest(context);
                },
                child: const Text('Looping Page View'),
              ),
              ElevatedButton(
                onPressed: () {
                  DotgNavigator.navigateToRoundTest(context);
                },
                child: const Text('Round Test View'),
              ),
              ElevatedButton(
                onPressed: () {
                  DotgNavigator.navigateToFuseTest(context);
                },
                child: const Text('Fuse View'),
              ),
              ElevatedButton(
                onPressed: () {
                  DotgNavigator.navigateToQuillTest(context);
                },
                child: const Text('Quill View'),
              ),
              ElevatedButton(
                onPressed: () {
                  DotgNavigator.navigateToTabIndicatorTest(context);
                },
                child: const Text('TabIndicator View'),
              ),
              _NavigatorButton(
                text: 'BottomSliverView',
                onTap: () {
                  DotgNavigator.navigateToBottomSliverTest(context);
                },
              ),
              _NavigatorButton(
                  text: 'YoutubeLinkView',
                  onTap: () {
                    DotgNavigator.navigateToYoutubePlayerTest(context);
                  }),
              _NavigatorButton(
                text: 'DragTest',
                onTap: () {
                  DotgNavigator.navigateToDragTest(context);
                },
              ),
              _NavigatorButton(
                text: 'SnapScroll',
                onTap: () {
                  DotgNavigator.navigateToSnapScrollTest(context);
                },
              ),
              _NavigatorButton(
                text: 'ScrollTest',
                onTap: () {
                  DotgNavigator.navigateToScrollTest(context);
                },
              ),
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
  final VoidCallback onTap;

  const _NavigatorButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(text),
    );
  }
}

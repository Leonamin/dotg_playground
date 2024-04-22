import 'package:dotg_playground/1_view/bottom_sliver_view.dart';
import 'package:dotg_playground/1_view/fuse_view.dart';
import 'package:dotg_playground/1_view/looping_page_view.dart';
import 'package:dotg_playground/1_view/mixed_scroll_tab/one_way_scroll_physics.dart';
import 'package:dotg_playground/1_view/quill_view.dart';
import 'package:dotg_playground/1_view/round_test_view.dart';
import 'package:dotg_playground/1_view/run_js_view.dart';
import 'package:dotg_playground/1_view/tab_indicator_view.dart';
import 'package:dotg_playground/3_util/navigator_helper.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('땃쥐 놀이터'),
      ),
      body: Column(
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
          // ElevatedButton(
          //   onPressed: () {
          //     NavigatorHelper.push(
          //       context,
          //       const OneWayScrollView(),
          //     );
          //   },
          //   child: const Text('TabIndicator View'),
          // ),
          _NavigatorButton(text: 'BottomSliverView', page: BottomSliverView()),
          _NavigatorButton(text: 'RunJsView', page: RunJsView()),
        ],
      ),
    );
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

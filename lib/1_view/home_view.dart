import 'package:dotg_playground/1_view/fuse_view.dart';
import 'package:dotg_playground/1_view/looping_page_view.dart';
import 'package:dotg_playground/1_view/quill_view.dart';
import 'package:dotg_playground/1_view/round_test_view.dart';
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
        ],
      ),
    );
  }
}

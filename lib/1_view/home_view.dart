import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('땃쥐 놀이터'),
      ),
      body: const Center(
        child: Text(
          '땃쥐 놀이터에 오신 것을 환영합니다!',
        ),
      ),
    );
  }
}

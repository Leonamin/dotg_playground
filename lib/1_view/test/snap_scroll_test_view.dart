import 'package:dotg_playground/1_view/physics/snap_scroll_physics.dart';
import 'package:flutter/material.dart';

class SnapScrollTestView extends StatelessWidget {
  const SnapScrollTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snap Scroll Test View'),
      ),
      body: ListView.builder(
        physics: const SnapScrollPhysics(snapSize: 100),
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            color: index.isEven ? Colors.white : Colors.black12,
            child: Center(
              child: Text('$index'),
            ),
          );
        },
      ),
    );
  }
}

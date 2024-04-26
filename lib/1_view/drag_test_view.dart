import 'package:dotg_playground/0_component/drag/0_data/drag_properties.dart';
import 'package:dotg_playground/0_component/drag/drag_transition_widget.dart';
import 'package:flutter/material.dart';

class DragTestView extends StatelessWidget {
  const DragTestView({super.key});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height / 3;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: DragTransitionWidget(
              enableMove: true,
              moveConfig: DragMoveConfig(
                moveTopToBottom: DragMoveProperties(
                  dragThreshold: maxHeight,
                ),
                moveBottomToTop: DragMoveProperties(
                  dragThreshold: MediaQuery.of(context).size.height / 10,
                ),
              ),
              zoomConfig: DragZoomConfig(
                zoomTopToBottom: DragZoomProperties(
                  type: DragZoomType.zoomOut,
                  scaleLimit: 0.9,
                  dragThreshold: MediaQuery.of(context).size.height / 10,
                ),
                zoomBottomToTop: DragZoomProperties(
                  type: DragZoomType.zoomIn,
                  scaleLimit: 1.1,
                  dragThreshold: MediaQuery.of(context).size.height / 10,
                ),
              ),
              dragEndEvents: [
                DragEndEventConfig(
                  direction: DragDirection.down,
                  dragThreshold: 100,
                  onDragEnd: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('100 Top to Bottom Drag End'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                DragEndEventConfig(
                  direction: DragDirection.down,
                  dragThreshold: 200,
                  onDragEnd: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('200 Top to Bottom Drag End'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
              child: Container(
                color: Colors.red,
                height: maxHeight,
                width: maxWidth,
              ),
            ),
          )
        ],
      ),
    );
  }
}

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
                // moveBottomToTop: DragMoveProperties(
                //   dragThreshold: maxHeight,
                // ),
                // moveLeftToRight: DragMoveProperties(
                //   dragThreshold: maxHeight,
                // ),
                // moveRightToLeft: DragMoveProperties(
                //   dragThreshold: maxHeight,
                // ),
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

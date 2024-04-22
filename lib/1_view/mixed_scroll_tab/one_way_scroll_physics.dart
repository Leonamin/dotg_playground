import 'package:flutter/material.dart';

class OneWayScrollView extends StatefulWidget {
  const OneWayScrollView({super.key});

  @override
  State<OneWayScrollView> createState() => _OneWayScrollViewState();
}

class _OneWayScrollViewState extends State<OneWayScrollView> {
  bool checkDir = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneWayScrollPhysics'),
      ),
      body: PageView.builder(
        physics: OneWayScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            child: Text('Page $index'),
          );
        },
      ),
    );
  }
}

class OneWayScrollPhysics extends ScrollPhysics {
  OneWayScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  bool isGoingLeft = false;

  @override
  OneWayScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OneWayScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    isGoingLeft = offset.sign < 0;
    return offset;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    //print("applyBoundaryConditions");
    assert(() {
      if (value == position.pixels) {
        throw FlutterError(
            '$runtimeType.applyBoundaryConditions() was called redundantly.\n'
            'The proposed new position, $value, is exactly equal to the current position of the '
            'given ${position.runtimeType}, ${position.pixels}.\n'
            'The applyBoundaryConditions method should only be called when the value is '
            'going to actually change the pixels, otherwise it is redundant.\n'
            'The physics object in question was:\n'
            '  $this\n'
            'The position object in question was:\n'
            '  $position\n');
      }
      return true;
    }());
    if (value < position.pixels && position.pixels <= position.minScrollExtent)
      return value - position.pixels;
    if (position.maxScrollExtent <= position.pixels && position.pixels < value)
      // overscroll
      return value - position.pixels;
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) // hit top edge

      return value - position.minScrollExtent;

    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) // hit bottom edge
      return value - position.maxScrollExtent;

    if (!isGoingLeft) {
      return value - position.pixels;
    }
    return 0.0;
  }
}

// class OneWayScrollPhysics extends ScrollPhysics {
//   @override
//   ScrollPhysics applyTo(ScrollPhysics ancestor) {
//     return OneWayScrollPhysics(parent: ancestor);
//   }

//   @override
//   double applyPhysicsToUserOffset(Scrollable scrollable, double offset) {
//     // 다음 페이지로 이동은 허용, 이전 페이지로 이동은 막음
//     if (offset < 0) {
//       return 0.0;
//     } else {
//       return super.applyPhysicsToUserOffset(scrollable, offset);
//     }
//   }

//   @override
//   double applyBoundaryConditions(Scrollable scrollable, double value) {
//     // 다음 페이지로 이동은 허용, 이전 페이지로 이동은 막음
//     if (value < 0.0) {
//       return 0.0;
//     } else {
//       return super.applyBoundaryConditions(scrollable, value);
//     }
//   }

//   const OneWayScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);
// }

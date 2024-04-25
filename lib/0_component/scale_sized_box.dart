import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScaleSizedBox extends StatelessWidget {
  const ScaleSizedBox({
    super.key,
    this.axis = Axis.vertical,
    required this.sizeFactor,
    this.axisAlignment = 0.0,
    this.fixedCrossAxisSizeFactor,
    this.child,
  }) : assert(fixedCrossAxisSizeFactor == null ||
            fixedCrossAxisSizeFactor >= 0.0);

  final Axis axis;
  final double sizeFactor;

  final double axisAlignment;

  final double? fixedCrossAxisSizeFactor;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final AlignmentDirectional alignment;
    if (axis == Axis.vertical) {
      alignment = AlignmentDirectional(-1.0, axisAlignment);
    } else {
      alignment = AlignmentDirectional(axisAlignment, -1.0);
    }
    return ClipRect(
      child: Align(
        alignment: alignment,
        heightFactor: axis == Axis.vertical
            ? math.max(sizeFactor, 0.0)
            : fixedCrossAxisSizeFactor,
        widthFactor: axis == Axis.horizontal
            ? math.max(sizeFactor, 0.0)
            : fixedCrossAxisSizeFactor,
        child: child,
      ),
    );
  }
}

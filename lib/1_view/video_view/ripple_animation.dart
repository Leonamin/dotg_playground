import 'package:flutter/material.dart';

enum RippleState {
  idle,
  animating,
}

class RippleAnimation extends StatefulWidget {
  final Color? highlightColor;
  final Color? splashColor;

  const RippleAnimation({
    super.key,
    this.highlightColor,
    this.splashColor,
  });

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// 애니메이션이 발생할 때 배경이 되는 색상
  Color get splashColor => widget.splashColor ?? Colors.grey.shade100;

  /// 애니메이션이 발생하면서 퍼져나가는 색상
  Color get highlightColor => widget.highlightColor ?? Colors.grey.shade300;

  RippleState _rippleState = RippleState.idle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      final maxHeight = constraints.maxHeight;

      return GestureDetector(
        onTapDown: _onTapDown,
        child: ClipRRect(
          child: CustomPaint(
            painter: RipplePainter(
              _tapPosition,
              _controller.value,
              highlightColor,
            ),
            child: Container(
              width: 100,
              height: 100,
            ),
          ),
        ),
      );
    });
  }

  Offset _tapPosition = Offset.zero;

  void _onTapDown(TapDownDetails details) {
    _tapPosition = details.localPosition;
    _animate();
  }

  void _animate() {
    _controller.forward(from: 0.0).then((value) {
      _controller.reset();
      setState(() {
        _rippleState = RippleState.idle;
      });
    });
    setState(() {
      _rippleState = RippleState.animating;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class RipplePainter extends CustomPainter {
  final Offset position;
  final double progress;
  final Color highlightColor;

  RipplePainter(
    this.position,
    this.progress,
    this.highlightColor,
  );

  double get sizeFactor => progress * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = highlightColor;
    canvas.drawCircle(size.center(position), size.width * sizeFactor, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

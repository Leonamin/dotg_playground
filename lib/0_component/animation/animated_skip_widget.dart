import 'package:flutter/material.dart';

class CustomQuadCurve extends Curve {
  @override
  double transform(double t) {
    return -4 * t * (t - 1); // 이 곡선은 t=0.5에서 최대값 1.0에 도달
  }
}

enum AnimationStatus {
  idle,
  requesting,
}

class AnimatedSkipController extends ChangeNotifier {
  AnimatedSkipController();

  AnimationStatus fastforwardStatus = AnimationStatus.idle;
  AnimationStatus rewindStatus = AnimationStatus.idle;

  void animateFastForward() {
    reset();
    fastforwardStatus = AnimationStatus.requesting;
    notifyListeners();
  }

  void animateRewind() {
    reset();
    rewindStatus = AnimationStatus.requesting;
    notifyListeners();
  }

  bool get hasRequestingStatus =>
      fastforwardStatus == AnimationStatus.requesting ||
      rewindStatus == AnimationStatus.requesting;

  void reset() {
    fastforwardStatus = AnimationStatus.idle;
    rewindStatus = AnimationStatus.idle;
    notifyListeners();
  }
}

class AnimatedSkipWidget extends StatefulWidget {
  final AnimatedSkipController controller;
  final Color? backgroundColor;
  final Color? fastForwardColor;

  final Duration? duration;

  const AnimatedSkipWidget({
    super.key,
    required this.controller,
    this.backgroundColor,
    this.fastForwardColor,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<AnimatedSkipWidget> createState() => _AnimatedSkipWidgetState();
}

class _AnimatedSkipWidgetState extends State<AnimatedSkipWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController ac;
  late Animation<double> _splashOpacityTween;
  late Animation<double> _fastForwardTween;

  Color get backgroundColor => widget.backgroundColor ?? Colors.black;
  Color get fastForwardColor => widget.fastForwardColor ?? Colors.white;

  double get _splashCircleSize => MediaQuery.of(context).size.width * 3;

  @override
  void initState() {
    super.initState();
    _initAnimation();

    _initListeners();
  }

  void _initAnimation() {
    ac = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 500),
    );

    _splashOpacityTween = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: ac,
        curve: CustomQuadCurve(),
      ),
    );

    _fastForwardTween =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: ac,
      curve: Curves.linear,
    ));
  }

  void _initListeners() {
    widget.controller.addListener(_onListenStatusChanged);
  }

  void _onListenStatusChanged() {
    if (widget.controller.hasRequestingStatus) {
      ac.forward(from: 0.0).then(_onAnimationEnded);
    }
  }

  void _onAnimationEnded(void value) {
    ac.reset();
    widget.controller.reset();
  }

  double get _fastForwardOpacity {
    if (widget.controller.fastforwardStatus == AnimationStatus.requesting) {
      return _splashOpacityTween.value;
    }
    return 0.0;
  }

  double get _rewindOpacity {
    if (widget.controller.rewindStatus == AnimationStatus.requesting) {
      return _splashOpacityTween.value;
    }
    return 0.0;
  }

  bool get _showFastForward =>
      widget.controller.fastforwardStatus == AnimationStatus.requesting;

  bool get _showRewind =>
      widget.controller.rewindStatus == AnimationStatus.requesting;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final halfWidth = constraints.maxWidth / 2;
      return AnimatedBuilder(
        animation: ac,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 백그라운드 스플래시
              Positioned.fill(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: backgroundColor.withOpacity(_splashOpacityTween.value),
                ),
              ),
              // 되감기 스플래시
              Positioned(
                right: halfWidth,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: _splashCircleSize,
                    height: _splashCircleSize,
                    decoration: BoxDecoration(
                      color: fastForwardColor.withOpacity(_rewindOpacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // 빨리감기 스플래시
              Positioned(
                left: halfWidth,
                child: Container(
                  width: _splashCircleSize,
                  height: _splashCircleSize,
                  decoration: BoxDecoration(
                    color: fastForwardColor.withOpacity(_fastForwardOpacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (_showRewind)
                Positioned.fill(
                  top: 0,
                  left: 0,
                  right: halfWidth,
                  bottom: 0,
                  child: Transform.flip(
                    flipX: true,
                    child: AnimatedLinearOpacity(
                      progress: _fastForwardTween.value,
                      iconColor: Colors.white,
                    ),
                  ),
                ),
              if (_showFastForward)
                Positioned.fill(
                  top: 0,
                  left: halfWidth,
                  right: 0,
                  bottom: 0,
                  child: AnimatedLinearOpacity(
                    progress: _fastForwardTween.value,
                    iconColor: Colors.white,
                  ),
                ),
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _closeController();
    super.dispose();
  }

  void _closeController() {
    ac.dispose();
  }
}

class FromTo {
  final double from;
  final double to;

  const FromTo(this.from, this.to);
}

class AnimatedLinearOpacity extends StatelessWidget {
  final double progress;
  final List<FromTo> forwardStatus;
  final Color? iconColor;

  const AnimatedLinearOpacity({
    super.key,
    this.progress = 0.0,
    this.forwardStatus = const [
      FromTo(0.0, 0.75),
      FromTo(0.125, 0.875),
      FromTo(0.25, 1.0),
    ],
    this.iconColor,
  });

  /// 2차함수 그래프를 이용하여 투명도를 계산
  double getParabolicOpacity(double progress, double start, double end) {
    if (progress < start || progress > end) {
      return 0.0;
    }
    double mid = (start + end) / 2; // 최대값 1.0이 되는 중간 지점
    // 2차 함수를 구현 (정점 형식)
    double opacity = -4 /
            ((end - start) * (end - start)) *
            (progress - mid) *
            (progress - mid) +
        1;
    return opacity.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final fromTo in forwardStatus)
            Opacity(
              opacity: getParabolicOpacity(progress, fromTo.from, fromTo.to),
              child: _PlayIconWidget(
                color: iconColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayIconWidget extends StatelessWidget {
  final Color? color;
  final double size;
  const _PlayIconWidget({
    super.key,
    this.color = Colors.white,
    this.size = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    // 삼각형 위젯
    return CustomPaint(
      size: Size(size, size),
      painter: _PlayIconPainter(color: color, widthFactor: 0.8),
    );
  }
}

class _PlayIconPainter extends CustomPainter {
  final Color? color;
  // 삼각형의 너비를 조절하는 요소
  final double widthFactor;

  _PlayIconPainter({this.color, this.widthFactor = 1.0}) {
    assert(widthFactor >= 0.0 && widthFactor <= 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * widthFactor, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

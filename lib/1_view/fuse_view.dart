import 'dart:math';
import 'package:flutter/material.dart';

class FuseView extends StatelessWidget {
  const FuseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuse View'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Sparkler(),
      ),
    );
  }
}

class Particle extends StatefulWidget {
  const Particle({
    super.key,
    this.duration = const Duration(
      milliseconds: 300,
    ),
  });

  final Duration duration;
  @override
  State<StatefulWidget> createState() {
    return _ParticleState();
  }
}

class _ParticleState extends State<Particle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double randomSpawnDelay = 0.0;
  double randomSize = 0.0;
  double arcImpact = 0.0;
  bool isStar = false;
  double starPosition = 0.0;
  bool visible = true;

  @override
  void initState() {
    super.initState();
    randomSpawnDelay = Random().nextDouble();
    randomSize = Random().nextDouble();
    arcImpact = Random().nextDouble() * 2 - 1;
    isStar = Random().nextDouble() > 0.9;
    starPosition = Random().nextDouble() + 0.5;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _startNextAnimation(
        Duration(milliseconds: (Random().nextDouble() * 1000).toInt()));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        visible = false;
        _startNextAnimation();
      }
    });

    _controller.addListener(() {
      setState(() {});
    });
  }

  void _startNextAnimation([Duration? after]) {
    if (after == null) {
      int millis = (randomSpawnDelay * 300).toInt();
      after = Duration(milliseconds: millis);
    }

    Future.delayed(after, () {
      if (!mounted) {
        return;
      }

      setState(() {
        randomSpawnDelay = Random().nextDouble();
        randomSize = Random().nextDouble() * 1;
        arcImpact = Random().nextDouble() * 2 - 1;
        // isStar = Random().nextDouble() > 0.1;
        isStar = true;
        starPosition = Random().nextDouble() * 10;
        visible = true;
      });

      _controller.forward(from: 0.0);
    });
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: randomSize * 1.5,
      height: 30,
      child: Opacity(
        opacity: visible ? 1.0 : 0.0,
        child: CustomPaint(
          painter: ParticlePainter(
            currentLifetime: _controller.value,
            randomSize: randomSize,
            arcImpact: arcImpact,
            isStar: isStar,
            starPosition: starPosition,
          ),
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter({
    required this.currentLifetime,
    required this.randomSize,
    required this.arcImpact,
    required this.isStar,
    required this.starPosition,
  });

  final double currentLifetime;
  final double randomSize;
  final double arcImpact;
  final bool isStar;
  final double starPosition;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    double width = size.width;
    double height = size.height * randomSize * currentLifetime * 2.5;

    if (isStar) {
      _drawStar(paint, width, height, size, canvas);
    }

    _drawParticle(paint, width, height, size, canvas);
  }

  void _drawParticle(
      Paint paint, double width, double height, Size size, Canvas canvas) {
    Rect rect = Rect.fromLTWH(0, 0, width, height);

    Path path = Path();
    LinearGradient gradient = LinearGradient(colors: [
      Colors.transparent,
      Color.fromRGBO(255, 255, 160, 1.0),
      Color.fromRGBO(255, 255, 160, 0.7),
      Color.fromRGBO(255, 180, 120, 0.7)
    ], stops: [
      0,
      size.height * currentLifetime / 30,
      0.6,
      1.0
    ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    paint.shader = gradient.createShader(rect);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width;
    path.cubicTo(0, 0, width * 4 * arcImpact, height * 0.5, width, height);

    canvas.drawPath(path, paint);
  }

  void _drawStar(
      Paint paint, double width, double height, Size size, Canvas canvas) {
    Path path = Path();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width * 0.25;
    paint.color = Color.fromRGBO(255, 255, 160, 1.0);

    double starSize = size.width * 2.5;
    double starBottom = height * starPosition;

    path.moveTo(0, starBottom - starSize);
    path.lineTo(starSize, starBottom);
    path.moveTo(starSize, starBottom - starSize);
    path.lineTo(0, starBottom);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Sparkler extends StatefulWidget {
  const Sparkler({super.key});

  @override
  State<Sparkler> createState() => _SparklerState();
}

class _SparklerState extends State<Sparkler>
    with SingleTickerProviderStateMixin {
  final double width = 300;

  late final AnimationController _controller;

  double get progress => _controller.value;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      width: width,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, widget) {
          return SizedBox(
            height: 100,
            child: Stack(
              children: getParticles(),
            ),
          );
        },
      ),
    ));
  }

  List<Widget> getParticles() {
    List<Widget> particles = [];
    double width = 300;
    particles.add(
      CustomPaint(
        painter: StickPainter(progress: progress),
        child: Container(),
      ),
    );

    int maxParticles = 160;
    for (var i = 1; i <= maxParticles; i++) {
      if (progress >= 1) {
        continue;
      }
      particles.add(
        Padding(
          padding: EdgeInsets.only(left: progress * width, top: 20),
          child: Transform.rotate(
            angle: maxParticles / i * pi,
            child: Padding(
              padding: EdgeInsets.only(top: 30),
              child: Particle(),
            ),
          ),
        ),
      );
    }

    return particles;
  }
}

class StickPainter extends CustomPainter {
  StickPainter({required this.progress, this.height = 4});

  final double progress;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    double burntStickHeight = height * 0.75;
    double burntStickWidth = progress * size.width;

    _drawBurntStick(burntStickHeight, burntStickWidth, size, canvas);
    _drawIntactStick(burntStickWidth, size, canvas);
  }

  void _drawIntactStick(double burntStickWidth, Size size, Canvas canvas) {
    Paint paint = Paint()..color = Color.fromARGB(255, 100, 100, 100);

    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(burntStickWidth, size.height / 2 - height / 2,
              size.width - burntStickWidth, height),
          Radius.circular(3),
        ),
      );

    canvas.drawPath(path, paint);
  }

  void _drawBurntStick(double burntStickHeight, double burntStickWidth,
      Size size, Canvas canvas) {
    double startHeat = progress - 0.1 <= 0 ? 0 : progress - 0.1;
    double endHeat = progress + 0.05 >= 1 ? 1 : progress + 0.05;

    LinearGradient gradient = LinearGradient(colors: [
      Color.fromARGB(255, 80, 80, 80),
      Color.fromARGB(255, 100, 80, 80),
      Colors.red,
      Color.fromARGB(255, 130, 100, 100),
      Color.fromARGB(255, 130, 100, 100)
    ], stops: [
      0,
      startHeat,
      progress,
      endHeat,
      1.0
    ]);

    Paint paint = Paint();
    Rect rect = Rect.fromLTWH(0, size.height / 2 - burntStickHeight / 2,
        size.width, burntStickHeight);
    paint.shader = gradient.createShader(rect);

    Path path = Path()..addRect(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CirclePathPainter extends CustomPainter {
  final double progress;

  CirclePathPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    var center = Offset(size.width / 2, size.height / 2);
    var radius = size.width / 4;
    var angle = 2 * pi * progress;
    var pointX = center.dx + radius * cos(angle);
    var pointY = center.dy + radius * sin(angle);
    var currentPoint = Offset(pointX, pointY);

    canvas.drawCircle(center, radius, paint); // 원 그리기
    canvas.drawCircle(
        currentPoint, 10, paint..style = PaintingStyle.fill); // 원 위의 점 그리기
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CircleAnimationWidget extends StatefulWidget {
  final Widget child;
  final double radius;

  const CircleAnimationWidget({
    super.key,
    required this.child,
    this.radius = 100.0,
  });

  @override
  State<CircleAnimationWidget> createState() => _CircleAnimationWidgetState();
}

class _CircleAnimationWidgetState extends State<CircleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double radius = widget.radius; // 원의 반지름을 정의
        final double angle = 2 * pi * controller.value;
        final double x = radius * cos(angle) + radius; // 원의 중심을 기준으로 X 좌표 계산
        final double y = radius * sin(angle) + radius; // 원의 중심을 기준으로 Y 좌표 계산

        return Stack(
          children: <Widget>[
            Positioned(
              left: x,
              top: y,
              child: Container(
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

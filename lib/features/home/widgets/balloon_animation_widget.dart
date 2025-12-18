import 'dart:math';
import 'package:flutter/material.dart';

class BalloonAnimationWidget extends StatelessWidget {
  final double width;
  final double height;
  final double balloonSpeed;
  final double balloonDensity;
  final double minBalloonSize;
  final double maxBalloonSize;
  final List<Color> balloonColors;

  const BalloonAnimationWidget({
    super.key,
    required this.width,
    required this.height,
    this.balloonSpeed = 1500.0,
    this.balloonDensity = 60.0,
    this.minBalloonSize = 25.0,
    this.maxBalloonSize = 55.0,
    this.balloonColors = const [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Stack(
          children: _buildBalloonLayers(),
        ),
      ),
    );
  }

  List<Widget> _buildBalloonLayers() {
    final Random random = Random();

    return [
      _buildLayer(random,
          swayAmplitude: 15.0, swayFrequency: 0.8, distanceFactor: 3.0),
      _buildLayer(random,
          swayAmplitude: 25.0, swayFrequency: 1.2, distanceFactor: 1.8),
      _buildLayer(random,
          swayAmplitude: 35.0, swayFrequency: 1.6, distanceFactor: 1.0),
    ];
  }

  Widget _buildLayer(Random random,
      {required double swayAmplitude,
      required double swayFrequency,
      required double distanceFactor}) {
    final int balloonCount =
        (width / 1000 * balloonDensity / 3 * (1 / distanceFactor)).ceil();

    final List<Widget> balloons = [];

    for (int i = 0; i < balloonCount; i++) {
      final double balloonSize = (minBalloonSize +
              random.nextDouble() * (maxBalloonSize - minBalloonSize)) /
          distanceFactor;

      final double speedVariation = 0.8 + random.nextDouble() * 0.4;
      final double effectiveSpeed =
          balloonSpeed * speedVariation / distanceFactor;

      final double riseDistance = height + balloonSize * 2;
      final double durationSec = riseDistance / effectiveSpeed;
      final double delaySec = random.nextDouble() * durationSec;

      final double left = random.nextDouble() * width;
      final double initialOffset = random.nextDouble() * swayAmplitude;

      final Color balloonColor =
          balloonColors[random.nextInt(balloonColors.length)];
      final double opacity = (0.7 + random.nextDouble() * 0.3) / distanceFactor;

      balloons.add(
        Positioned(
          left: left,
          bottom: -balloonSize,
          child: Balloon(
            duration: Duration(milliseconds: (durationSec * 1000).toInt()),
            delay: Duration(milliseconds: (delaySec * 1000).toInt()),
            size: balloonSize,
            color: balloonColor.withOpacity(opacity),
            riseDistance: riseDistance,
            swayAmplitude: swayAmplitude,
            swayFrequency: swayFrequency,
            initialOffset: initialOffset,
          ),
        ),
      );
    }

    return Stack(children: balloons);
  }
}

class Balloon extends StatefulWidget {
  final Duration duration;
  final Duration delay;
  final double size;
  final Color color;
  final double riseDistance;
  final double swayAmplitude;
  final double swayFrequency;
  final double initialOffset;

  const Balloon({
    super.key,
    required this.duration,
    required this.delay,
    required this.size,
    required this.color,
    required this.riseDistance,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.initialOffset,
  });

  @override
  State<Balloon> createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double progress = _animation.value;
        final double verticalOffset = progress * widget.riseDistance;
        final double horizontalOffset = widget.initialOffset +
            sin(progress * pi * 2 * widget.swayFrequency) *
                widget.swayAmplitude;

        return Transform.translate(
          offset: Offset(horizontalOffset, -verticalOffset),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: BalloonPainter(color: widget.color),
          ),
        );
      },
    );
  }
}

class BalloonPainter extends CustomPainter {
  final Color color;

  BalloonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint balloonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.9),
          color.withOpacity(0.7),
          color.withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Paint outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;

    final Paint stringPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;

    // Draw balloon body (circle)
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      balloonPaint,
    );

    // Draw balloon outline
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      outlinePaint,
    );

    // Draw balloon knot
    final Path knotPath = Path();
    knotPath.moveTo(size.width / 2, size.height);
    knotPath.cubicTo(
      size.width / 2 - size.width * 0.15,
      size.height + size.height * 0.1,
      size.width / 2 + size.width * 0.15,
      size.height + size.height * 0.1,
      size.width / 2,
      size.height,
    );
    canvas.drawPath(knotPath, balloonPaint);

    // Draw string
    canvas.drawLine(
      Offset(size.width / 2, size.height),
      Offset(size.width / 2, size.height + size.height * 0.3),
      stringPaint,
    );

    // Draw festive ribbon
    final Paint ribbonPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final Path ribbonPath = Path();
    ribbonPath.moveTo(size.width / 2, size.height);
    ribbonPath.cubicTo(
      size.width / 2 - size.width * 0.2,
      size.height - size.height * 0.1,
      size.width / 2 - size.width * 0.2,
      size.height - size.height * 0.2,
      size.width / 2,
      size.height - size.height * 0.1,
    );
    ribbonPath.cubicTo(
      size.width / 2 + size.width * 0.2,
      size.height - size.height * 0.2,
      size.width / 2 + size.width * 0.2,
      size.height - size.height * 0.1,
      size.width / 2,
      size.height,
    );
    canvas.drawPath(ribbonPath, ribbonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

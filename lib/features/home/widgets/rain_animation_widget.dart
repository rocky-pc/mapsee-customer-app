import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/images.dart';

class RainAnimationWidget extends StatelessWidget {
  final double width;
  final double height;
  final double rainSpeed;
  final double rainDensity;
  final double rainAngle;
  final Color rainColor;
  final double minDropWidth;
  final double maxDropWidth;
  final double minDropHeight;
  final double maxDropHeight;

  // Editable Thunder Parameters
  final double thunder1XFactor;
  final double thunder1YOffset;
  final double thunder1Size;

  final double thunder2XFactor;
  final double thunder2YOffset;
  final double thunder2Size;

  const RainAnimationWidget({
    super.key,
    required this.width,
    required this.height,
    this.rainSpeed = 1000.0,
    this.rainDensity = 120.0,
    this.rainAngle = 35.0,
    this.rainColor = Colors.white,
    this.minDropWidth = 1.5,
    this.maxDropWidth = 4.5,
    this.minDropHeight = 30.0,
    this.maxDropHeight = 60.0,
    this.thunder1XFactor = 0.25,
    this.thunder1YOffset = 10.0,
    this.thunder1Size = 280.0,
    this.thunder2XFactor = 0.75,
    this.thunder2YOffset = 30.0,
    this.thunder2Size = 320.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.black, // This sets the background color to black
      child: ClipRect(
        child: Stack(
          children: [
            // Thunder 1: Uses Images.thunder
            ThunderWidget(
              imagePath: Images.thunder,
              top: thunder1YOffset,
              centerX: width * thunder1XFactor,
              size: thunder1Size,
              isFlipped: false,
              pauseDuration: const Duration(seconds: 2),
              initialDelay: const Duration(seconds: 1),
            ),

            // Background Rain layers
            ..._buildRainLayers(),

            // Thunder 2: Uses Images.thunder1
            ThunderWidget(
              imagePath: Images.thunder1,
              top: thunder2YOffset,
              centerX: width * thunder2XFactor,
              size: thunder2Size,
              isFlipped: true,
              pauseDuration: const Duration(seconds: 3),
              initialDelay: const Duration(seconds: 4),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRainLayers() {
    final Random random = Random();
    final double angleRad = rainAngle * pi / 180.0;
    final double tanAngle = tan(angleRad);

    return [
      _buildLayer(random, angleRad, tanAngle, distanceFactor: 3.0),
      _buildLayer(random, angleRad, tanAngle, distanceFactor: 1.8),
      _buildLayer(random, angleRad, tanAngle, distanceFactor: 1.0),
    ];
  }

  Widget _buildLayer(Random random, double angleRad, double tanAngle,
      {required double distanceFactor}) {
    final int dropCount = (width / 1000 * rainDensity / 3 * (1 / distanceFactor)).ceil();
    final double totalFallDistance = height + maxDropHeight * 2;
    final double horizontalShift = totalFallDistance * tanAngle;
    final List<Widget> drops = [];

    for (int i = 0; i < dropCount; i++) {
      final double dropWidth = (minDropWidth + random.nextDouble() * (maxDropWidth - minDropWidth)) / distanceFactor;
      final double dropHeight = (minDropHeight + random.nextDouble() * (maxDropHeight - minDropHeight)) / distanceFactor;
      final double speedVariation = 0.8 + random.nextDouble() * 0.4;
      final double effectiveSpeed = rainSpeed * speedVariation / distanceFactor;
      final double fallDistance = height + dropHeight * 4;
      final double durationSec = fallDistance / effectiveSpeed;
      final double delaySec = random.nextDouble() * durationSec;
      final double spawnRange = width + horizontalShift.abs();
      final double left = (random.nextDouble() * spawnRange) - (horizontalShift > 0 ? horizontalShift : 0);
      final double opacity = (0.2 + random.nextDouble() * 0.4) / distanceFactor;

      drops.add(
        Positioned(
          left: left,
          top: -dropHeight * 2,
          child: RainDrop(
            duration: Duration(milliseconds: (durationSec * 1000).toInt()),
            delay: Duration(milliseconds: (delaySec * 1000).toInt()),
            angle: angleRad,
            tanAngle: tanAngle,
            width: dropWidth,
            height: dropHeight,
            color: rainColor.withOpacity(opacity),
            fallDistance: fallDistance,
          ),
        ),
      );
    }
    return Stack(children: drops);
  }
}

class ThunderWidget extends StatefulWidget {
  final String imagePath;
  final double centerX;
  final double top;
  final double size;
  final bool isFlipped;
  final Duration pauseDuration;
  final Duration initialDelay;

  const ThunderWidget({
    super.key,
    required this.imagePath,
    required this.centerX,
    required this.top,
    required this.size,
    required this.isFlipped,
    required this.pauseDuration,
    required this.initialDelay,
  });

  @override
  State<ThunderWidget> createState() => _ThunderWidgetState();
}

class _ThunderWidgetState extends State<ThunderWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 65),
    ]).animate(_controller);

    _startCycle();
  }

  void _startCycle() async {
    await Future.delayed(widget.initialDelay);
    if (mounted) _playStrike();
  }

  void _playStrike() async {
    if (!mounted) return;
    _controller.forward(from: 0);
    await Future.delayed(widget.pauseDuration);
    if (mounted) _playStrike();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.centerX - (widget.size / 2),
      top: widget.top,
      child: FadeTransition(
        opacity: _opacity,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(widget.isFlipped ? pi : 0),
          child: Image.asset(
            widget.imagePath,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class RainDrop extends StatefulWidget {
  final Duration duration;
  final Duration delay;
  final double angle;
  final double tanAngle;
  final double width;
  final double height;
  final Color color;
  final double fallDistance;

  const RainDrop({
    super.key,
    required this.duration,
    required this.delay,
    required this.angle,
    required this.tanAngle,
    required this.width,
    required this.height,
    required this.color,
    required this.fallDistance,
  });

  @override
  State<RainDrop> createState() => _RainDropState();
}

class _RainDropState extends State<RainDrop> with SingleTickerProviderStateMixin {
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
        final double verticalOffset = progress * widget.fallDistance;
        final double horizontalOffset = verticalOffset * widget.tanAngle;

        return Transform.translate(
          offset: Offset(horizontalOffset, verticalOffset),
          child: Transform.rotate(
            angle: widget.angle,
            child: CustomPaint(
              size: Size(widget.width, widget.height),
              painter: RoundedTeardropPainter(color: widget.color),
            ),
          ),
        );
      },
    );
  }
}

class RoundedTeardropPainter extends CustomPainter {
  final Color color;
  RoundedTeardropPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.6),
          color,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height - (size.width / 2));
    path.arcTo(
      Rect.fromLTWH(0, size.height - size.width, size.width, size.width),
      0, pi, false,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
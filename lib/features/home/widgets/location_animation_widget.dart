import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LocationAnimationWidget extends StatefulWidget {
  final Function() onAnimationComplete;
  const LocationAnimationWidget({super.key, required this.onAnimationComplete});

  @override
  State<LocationAnimationWidget> createState() => _LocationAnimationWidgetState();
}

class _LocationAnimationWidgetState extends State<LocationAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _flightController;
  late Animation<double> _scaleAnimation;
  Path? _flightPath;
  bool _showPlane = true;
  bool _isPathReady = false;

  @override
  void initState() {
    super.initState();

    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.5), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 80),
    ]).animate(CurvedAnimation(parent: _flightController, curve: Curves.easeOut));

    _flightController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showPlane = false;
        });
        widget.onAnimationComplete();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _calculateFlightPath();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _flightController.forward();
      });
    });
  }

  void _calculateFlightPath() {
    final Size size = MediaQuery.of(context).size;
    final Offset start = Offset(size.width * 0.85, 350);
    final Offset end = const Offset(24, 24);
    final Offset controlPoint = Offset(size.width * 0.9, 50);

    Path path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

    setState(() {
      _flightPath = path;
      _isPathReady = true;
    });
  }

  Offset? _calculatePosition(double value) {
    if (_flightPath == null) return null;
    PathMetrics pathMetrics = _flightPath!.computeMetrics();
    PathMetric pathMetric = pathMetrics.elementAt(0);
    value = pathMetric.length * value;
    Tangent? pos = pathMetric.getTangentForOffset(value);
    return pos?.position;
  }

  double _calculateRotation(double value) {
    if (_flightPath == null) return 0.0;
    PathMetrics pathMetrics = _flightPath!.computeMetrics();
    PathMetric pathMetric = pathMetrics.elementAt(0);
    value = pathMetric.length * value;
    Tangent? pos = pathMetric.getTangentForOffset(value);

    if (pos == null) return 0.0;
    final double direction = -atan2(pos.vector.dx, pos.vector.dy) - (pi / 2);
    return direction + 3.9;
  }

  @override
  void dispose() {
    _flightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showPlane || !_isPathReady) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _flightController,
      builder: (context, child) {
        final position = _calculatePosition(_flightController.value);
        final rotation = _calculateRotation(_flightController.value);

        if (position == null) return const SizedBox.shrink();

        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Transform.rotate(
            angle: rotation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                CupertinoIcons.location_fill,
                size: 26,
                color: Theme.of(context).cardColor,
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(5, 5),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

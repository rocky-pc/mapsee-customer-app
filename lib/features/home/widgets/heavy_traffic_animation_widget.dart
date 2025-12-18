import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

class HeavyTrafficAnimationWidget extends StatelessWidget {
  final double width;
  // Editable position parameters
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const HeavyTrafficAnimationWidget({
    super.key,
    required this.width,
    this.top,
    this.bottom,
    this.left,
    this.right = 0, // Default to right side
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: SizedBox(
          width: width,
          height: 70, // Slightly increased height to accommodate trees
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 1. Background Tree (Placed behind the road)
              Positioned(
                left: 20,
                bottom: -3,
                child: CustomAssetImageWidget(Images.tree1, height: 45, width: 30),
              ),

              // 2. The Road Line
              Container(
                height: 1.5,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 2),
                color: Colors.black12,
              ),

              // 3. Traffic Signal
              Positioned(
                right: 15,
                bottom: 2,
                child: CustomAssetImageWidget(Images.traffic, height: 37),
              ),

              // 4. Moving Vehicles
              TrafficQueue(screenWidth: width),

              // 5. Foreground Tree (Placed in front of the road/vehicles for depth)
              Positioned(
                right: 70,
                bottom: 0,
                child: CustomAssetImageWidget(Images.tree2, height: 35, width: 25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrafficQueue extends StatefulWidget {
  final double screenWidth;
  const TrafficQueue({super.key, required this.screenWidth});

  @override
  State<TrafficQueue> createState() => _TrafficQueueState();
}

class _TrafficQueueState extends State<TrafficQueue> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0);
      }
    });
    _controller.forward();
  }

  double getVehiclePos({
    required double startPos,
    required double stopPos,
    required double endPos,
    required double delayFactor,
  }) {
    double t = _controller.value;
    if (t < 0.35) {
      // PHASE 1: ARRIVING
      double localT = (t / 0.35).clamp(0.0, 1.0);
      return startPos + (stopPos - startPos) * Curves.easeOut.transform(localT);
    } else if (t < 0.75) {
      // PHASE 2: WAITING (approx 4 seconds)
      return stopPos;
    } else {
      // PHASE 3: DEPARTING (Staggered exit)
      double startTime = 0.75 + (delayFactor * 0.04);
      if (t < startTime) return stopPos;
      double localT = ((t - startTime) / (1.0 - startTime)).clamp(0.0, 1.0);
      return stopPos + (endPos - stopPos) * Curves.easeIn.transform(localT);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double stopLine = widget.screenWidth - 70;
        double exitPoint = widget.screenWidth + 100;

        return Stack(
          children: [
            // Order: Truck -> Car -> Bike
            Positioned(
              left: getVehiclePos(startPos: -50, stopPos: stopLine - 15, endPos: exitPoint, delayFactor: 0),
              bottom: 2,
              child: CustomAssetImageWidget(Images.truck, width: 55),
            ),
            Positioned(
              left: getVehiclePos(startPos: -100, stopPos: stopLine - 65, endPos: exitPoint - 45, delayFactor: 1),
              bottom: 0,
              child: CustomAssetImageWidget(Images.car, width: 50),
            ),
            Positioned(
              left: getVehiclePos(startPos: -140, stopPos: stopLine - 95, endPos: exitPoint - 80, delayFactor: 2),
              bottom: 0,
              child: CustomAssetImageWidget(Images.bike, width: 25),
            ),
          ],
        );
      },
    );
  }
}
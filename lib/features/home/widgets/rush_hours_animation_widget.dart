import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';

class RushHoursAnimationWidget extends StatelessWidget {
  final double width;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const RushHoursAnimationWidget({
    super.key,
    required this.width,
    this.top,
    this.bottom,
    this.left,
    this.right = 0,
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
          height: 70,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 1. Background Tree
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

              // 3. Traffic Signal (Bike will pass by this without stopping)
              Positioned(
                right: 15,
                bottom: 2,
                child: CustomAssetImageWidget(Images.traffic, height: 37),
              ),

              // 4. Single Moving Bike
              SingleMovingBike(screenWidth: width),

              // 5. Foreground Tree
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

class SingleMovingBike extends StatefulWidget {
  final double screenWidth;
  const SingleMovingBike({super.key, required this.screenWidth});

  @override
  State<SingleMovingBike> createState() => _SingleMovingBikeState();
}

class _SingleMovingBikeState extends State<SingleMovingBike> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Reduced duration to 5 seconds for a smooth drive-by since it doesn't stop
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0); // Loop the animation
      }
    });
    _controller.forward();
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
        // Start off-screen left (-50) and go off-screen right (screenWidth + 50)
        double startPos = -50;
        double endPos = widget.screenWidth + 50;

        // Simple linear calculation: Start + (Total Distance * percentage)
        double currentPos = startPos + ((endPos - startPos) * _controller.value);

        return Stack(
          children: [
            Positioned(
              left: currentPos,
              bottom: -6,
              // Only the bike is rendered
              child: CustomAssetImageWidget(Images.rushhours, width: 50),
            ),
          ],
        );
      },
    );
  }
}
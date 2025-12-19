import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cuisine_card_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'dart:math' as math;

class CuisineViewWidget extends StatelessWidget {
  const CuisineViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CuisineController>(builder: (cuisineController) {
      return (cuisineController.cuisineModel != null && cuisineController.cuisineModel!.cuisines!.isEmpty)
          ? const SizedBox()
          : Stack(
        children: [

          /// 1. THE PLANES (Rendered first = Bottom layer)
          if(ResponsiveHelper.isMobile(context))
            const Positioned.fill(
              child: IgnorePointer(
                child: PlaneUShapeAnimation(),
              ),
            ),

          /// 2. THE CONTENT (Rendered second = Top layer)
          Container(
            width: Dimensions.webMaxWidth,
            margin: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.isMobile(context)
                  ? Dimensions.paddingSizeDefault
                  : Dimensions.paddingSizeLarge,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(Images.cuisineBgPng),
                // Using low alpha so the background image doesn't hide the planes completely
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor.withValues(alpha: 0.09),
                  BlendMode.color,
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(ResponsiveHelper.isMobile(context) ? 0 : Dimensions.radiusSmall),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'cuisine'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                        ],
                      ),
                      ArrowIconButtonWidget(onTap: () => Get.toNamed(RouteHelper.getCuisineRoute())),
                    ],
                  ),
                ),

                cuisineController.cuisineModel != null ? GridView.builder(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cuisineController.cuisineModel!.cuisines!.length > 7  ? 8 : cuisineController.cuisineModel!.cuisines!.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isMobile(context) ? 4 : ResponsiveHelper.isDesktop(context) ? 7 : 6,
                    mainAxisSpacing: Dimensions.paddingSizeLarge,
                    crossAxisSpacing: Dimensions.paddingSizeLarge,
                  ),
                  itemBuilder: (context, index) {
                    return CustomInkWellWidget(
                      onTap: () =>  Get.toNamed(RouteHelper.getCuisineRestaurantRoute(
                        cuisineController.cuisineModel!.cuisines![index].id,
                        cuisineController.cuisineModel!.cuisines![index].name,
                      )),
                      radius: Dimensions.radiusDefault,
                      child: CuisineCardWidget(
                        image: '${cuisineController.cuisineModel!.cuisines![index].imageFullUrl}',
                        name: cuisineController.cuisineModel!.cuisines![index].name ?? '',
                      ),
                    );
                  },
                ) : const CuisineShimmer(),

                const SizedBox(height: Dimensions.paddingSizeLarge),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class PlaneUShapeAnimation extends StatefulWidget {
  const PlaneUShapeAnimation({super.key});

  @override
  State<PlaneUShapeAnimation> createState() => _PlaneUShapeAnimationState();
}

class _PlaneUShapeAnimationState extends State<PlaneUShapeAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Total time for both plane journeys
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ADJUST THESE TO POSITION THE FLIGHT PATH BEHIND SPECIFIC CONTENT
    double uDepth = 70.0;           // Depth of the U-Curve
    double startY = -25;           // Y position (Lowered to fly behind icons)
    double offScreenPadding = 130.0; // Distance to fly fully out of view
    double maxTiltAngle = -0.5;      // Nose dive/climb angle

    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double val = _controller.value;

          // --- PLANE 1: RIGHT to LEFT (Moves during 0.0 to 0.5) ---
          double p1Progress = (val <= 0.5) ? (val * 2.0) : 1.5;
          double p1X = (width + offScreenPadding) - (width + (offScreenPadding * 2)) * p1Progress;
          double p1Y = (p1Progress <= 1.0) ? (uDepth * p1Progress * (p1Progress - 1) * -4) + startY : startY;
          double p1Tilt = (p1Progress < 0.5) ? (p1Progress * maxTiltAngle) : ((1 - p1Progress) * maxTiltAngle);

          // --- PLANE 2: LEFT to RIGHT (Moves during 0.5 to 1.0) ---
          double p2Progress = (val > 0.5) ? ((val - 0.5) * 2.0) : -0.5;
          double p2X = -offScreenPadding + (width + (offScreenPadding * 2)) * p2Progress;
          double p2Y = (p2Progress >= 0 && p2Progress <= 1.0) ? (uDepth * p2Progress * (p2Progress - 1) * -4) + startY : startY;
          double p2Tilt = (p2Progress < 0.5) ? (p2Progress * maxTiltAngle) : ((1 - p2Progress) * maxTiltAngle);

          return Stack(
            children: [
              // Render Plane 1 only during its turn
              if(val <= 0.5)
                Positioned(
                  left: p1X,
                  top: p1Y,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateY(math.pi) // Flip to face left
                      ..rotateZ(p1Tilt), // Dive tilt
                    child: Image.asset(Images.plane, width: 80),
                  ),
                ),

              // Render Plane 2 only during its turn
              if(val > 0.5)
                Positioned(
                  left: p2X,
                  top: p2Y,
                  child: Transform.rotate(
                    angle: p2Tilt,
                    child: Image.asset(Images.plane, width: 80),
                  ),
                ),
            ],
          );
        },
      );
    });
  }
}

class CuisineShimmer extends StatelessWidget {
  const CuisineShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: Dimensions.paddingSizeDefault,
        crossAxisSpacing: Dimensions.paddingSizeDefault,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 950 : 200],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Shimmer(
                      child: Container(
                        height: 100, width: 100,
                        color: Colors.grey[Get.find<ThemeController>().darkTheme ? 900 : 200],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
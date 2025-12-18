import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Your existing imports
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurants_card_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';


class NewOnStackFoodViewWidget extends StatelessWidget {
  final bool isLatest;
  const NewOnStackFoodViewWidget({super.key, required this.isLatest});

  @override
  Widget build(BuildContext context) {
    // Define the color based on your specific instruction
    final Color glassmorphismColor = Theme.of(context).secondaryHeaderColor;

    return GetBuilder<RestaurantController>(builder: (restController) {
      return (restController.latestRestaurantList != null && restController.latestRestaurantList!.isEmpty) ? const SizedBox() : Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
        child: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            height: 230,
            child: ClipRRect(
              // borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
              child: BackdropFilter(
                // Frosted Glass Effect
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    // --- UPDATED COLOR HERE ---
                    color: glassmorphismColor.withOpacity(0.7), // Using the themed orange color with transparency
                    // --------------------------
                    // borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.0,
                    ),
                    // Subtle Shadow for Depth
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(
                              '${'new_on'.tr} ${AppConstants.appName}',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.8),
                              )
                          ),

                          ArrowIconButtonWidget(
                            onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute(isLatest ? 'latest' : '')),
                          ),
                        ]),
                      ),

                      restController.latestRestaurantList != null ? SizedBox(
                        height: 150,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                          itemCount: restController.latestRestaurantList!.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    RouteHelper.getRestaurantRoute(restController.latestRestaurantList![index].id),
                                    arguments: RestaurantScreen(restaurant: restController.latestRestaurantList![index]),
                                  );
                                },
                                child: RestaurantsCardWidget(
                                  isNewOnStackFood: true,
                                  restaurant: restController.latestRestaurantList![index],
                                ),
                              ),
                            );
                          },
                        ),
                      ) : const RestaurantsCardShimmer(isNewOnStackFood: false),
                    ],
                  ),

                ),
              ),
            ),
          ),
        ),
      );
    }
    );
  }
}
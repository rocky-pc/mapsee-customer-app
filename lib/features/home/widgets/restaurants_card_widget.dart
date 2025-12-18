import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Your existing imports
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/overflow_container_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_available_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class RestaurantsCardWidget extends StatelessWidget {
  final Restaurant restaurant;
  final bool? isNewOnStackFood;
  const RestaurantsCardWidget({super.key, this.isNewOnStackFood, required this.restaurant});


  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && restaurant.active! ;
    double distance = Get.find<RestaurantController>().getRestaurantDistance(
      LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
    );
    String characteristics = '';
    if(restaurant.characteristics != null) {
      for (var v in restaurant.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
      }
    }

    return Stack(
      children: [
        ClipRRect( // 1. ClipRRect for rounded corners before BackdropFilter
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: BackdropFilter( // 2. BackdropFilter for the blurring effect
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              // **REDUCTION 1: Slightly reduced width for non-new cards**
              width: isNewOnStackFood! ? ResponsiveHelper.isMobile(context) ? 330 : 380  : ResponsiveHelper.isMobile(context) ? 300: 325,
              decoration: BoxDecoration(
                // 3. White/Light Transparent Color
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                // 4. Subtle Border for definition
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                // 5. Box Shadow (light)
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 1))],
              ),
              child: CustomInkWellWidget(
                onTap: () {
                  Get.toNamed(
                    RouteHelper.getRestaurantRoute(restaurant.id),
                    arguments: RestaurantScreen(restaurant: restaurant),
                  );
                },
                radius: Dimensions.radiusDefault,
                // **REDUCTION 2: Reduced internal padding from Dimensions.paddingSizeDefault to Dimensions.paddingSizeSmall**
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Stack(
                        children: [
                          Container(
                            // **REDUCTION 3: Reduced logo size for non-new cards (95 -> 60, 65 -> 55)**
                            padding: EdgeInsets.all(isNewOnStackFood! ? 2 : 3),
                            height: isNewOnStackFood! ? 95 : 55, width: isNewOnStackFood! ? 95 : 55,
                            decoration:  BoxDecoration(
                              // Adjusting inner container color to fit the glassmorphism theme
                              color: Theme.of(context).cardColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child:  CustomImageWidget(
                                image: '${restaurant.logoFullUrl}',
                                fit: BoxFit.cover, height: isNewOnStackFood! ? 95 : 55, width: isNewOnStackFood! ? 95 : 55,
                                isRestaurant: true,
                              ),
                            ),
                          ),

                          isAvailable ? const SizedBox() : const NotAvailableWidget(isRestaurant: true),

                        ],
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              restaurant.name!,
                              overflow: TextOverflow.ellipsis, maxLines: 1,
                              style: robotoMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            // **REDUCTION 4: Reduced spacing**
                            SizedBox(height: isNewOnStackFood! ? Dimensions.paddingSizeExtraSmall : 2),

                            characteristics != '' ? Text(
                              characteristics,
                              overflow: TextOverflow.ellipsis, maxLines: 1,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            ) : const SizedBox(),
                            // **REDUCTION 5: Reduced spacing**
                            SizedBox(height: isNewOnStackFood! ? Dimensions.paddingSizeExtraSmall : 2),

                            Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                              isNewOnStackFood! ? restaurant.freeDelivery! ? ImageWithTextRowWidget(
                                widget: Image.asset(Images.deliveryIcon, height: 18, width: 18), // **REDUCTION 6: Reduced icon size**
                                text: 'free'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), // **REDUCTION 7: Reduced font size**
                              ) : const SizedBox() : IconWithTextRowWidget(
                                  icon: Icons.star_border, text: restaurant.avgRating!.toStringAsFixed(1),
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall) // **REDUCTION 7: Reduced font size**
                              ),
                              isNewOnStackFood! ? const SizedBox(width : Dimensions.paddingSizeExtraSmall) : const SizedBox(width: Dimensions.paddingSizeSmall),

                              isNewOnStackFood! ? ImageWithTextRowWidget(
                                widget: Image.asset(Images.distanceKm, height: 18, width: 18), // **REDUCTION 6: Reduced icon size**
                                text: '${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), // **REDUCTION 7: Reduced font size**
                              ) : restaurant.freeDelivery! ? ImageWithTextRowWidget(widget: Image.asset(Images.deliveryIcon, height: 18, width: 18), // **REDUCTION 6: Reduced icon size**
                                  text: 'free'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)) : const SizedBox(), // **REDUCTION 7: Reduced font size**
                              isNewOnStackFood! ? const SizedBox(width : Dimensions.paddingSizeExtraSmall) : restaurant.freeDelivery! ? const SizedBox(width: Dimensions.paddingSizeSmall) : const SizedBox(),

                              isNewOnStackFood! ? ImageWithTextRowWidget(
                                widget: Image.asset(Images.itemCount, height: 18, width: 18), // **REDUCTION 6: Reduced icon size**
                                text: '${restaurant.foodsCount! > 8 ? '8 +' : '${restaurant.foodsCount}'} ${'item'.tr}',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), // **REDUCTION 7: Reduced font size**
                              ) : IconWithTextRowWidget(
                                icon: Icons.access_time_outlined,
                                text: restaurant.deliveryTime!,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), // **REDUCTION 7: Reduced font size**
                              ),

                            ]),
                          ],
                        ),
                      ),
                    ]),

                    // **REMOVAL 8: Remove the food stack section when isNewOnStackFood is false to save significant height**
                    isNewOnStackFood! ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      restaurant.foods != null && restaurant.foods!.isNotEmpty ? Expanded(
                        child: Stack(children: [

                          OverFlowContainerWidget(image: restaurant.foods![0].imageFullUrl ?? ''),

                          restaurant.foods!.length > 1 ? Positioned(
                            left: 22, bottom: 0,
                            child: OverFlowContainerWidget(image: restaurant.foods![1].imageFullUrl ?? ''),
                          ) : const SizedBox(),

                          restaurant.foods!.length > 2 ? Positioned(
                            left: 42, bottom: 0,
                            child: OverFlowContainerWidget(image: restaurant.foods![2].imageFullUrl ?? ''),
                          ) : const SizedBox(),

                          restaurant.foods!.length > 4 ? Positioned(
                            left: 82, bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              height: 30, width: 80,
                              decoration:  BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1), // Adjusted opacity
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${restaurant.foodsCount! > 11 ? '12 +' : restaurant.foodsCount!} ',
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                                  ),
                                  Text('items'.tr, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).primaryColor)),
                                ],
                              ),
                            ),
                          ) : const SizedBox(),

                          restaurant.foods!.length > 3 ?  Positioned(
                            left: 62, bottom: 0,
                            child: OverFlowContainerWidget(image: restaurant.foods![3].imageFullUrl ?? ''),
                          ) : const SizedBox(),
                        ]),
                      ) : const SizedBox(),

                      Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor, size: 20),
                    ]) : const SizedBox(), // Replaced the entire Row with a SizedBox for non-new cards
                  ]),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: 5, right: 5, // **REDUCTION 9: Reduced position of favourite button**
          child: GetBuilder<FavouriteController>(builder: (favouriteController) {
            bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
            return CustomFavouriteWidget(
              isWished: isWished,
              isRestaurant: true,
              restaurant: restaurant,
            );
          }),
        ),
      ],
    );
  }
}
// --- RestaurantsCardShimmer is also modified for a whiter loading state ---
class RestaurantsCardShimmer extends StatelessWidget {
  final bool? isNewOnStackFood;
  const RestaurantsCardShimmer({super.key, this.isNewOnStackFood});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // **SHIMMER ADJUSTMENT 1: Adjusted height for non-new cards to reflect the reduced size (130 -> 85)**
      height: isNewOnStackFood! ? 300 : ResponsiveHelper.isDesktop(context) ? 100 : 85,
      child: isNewOnStackFood! ? GridView.builder(
        padding: const EdgeInsets.only(left: 17, right: 17, bottom: 17),
        itemCount: 6,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 17, crossAxisSpacing: 17,
          mainAxisExtent: 130,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            child: Container(
              width: 380, height: 80,
              // **SHIMMER ADJUSTMENT 2: Reduced internal padding from Dimensions.paddingSizeDefault to Dimensions.paddingSizeSmall**
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              // Shimmer Container Look Adjusted for White Glassmorphism
              decoration: BoxDecoration(
                // ⭐️ MODIFIED: Lighter shimmer background (Increased opacity)
                color: Colors.white.withOpacity(0.65), // Increased from 0.5 to 0.65
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                // ⭐️ MODIFIED: Border color (Increased opacity)
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1), // Increased from 0.1 to 0.3
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          // **SHIMMER ADJUSTMENT 3: Reduced shimmer logo size (80 -> 55)**
                          height: 55, width: 55,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: Container(
                              color: Colors.grey[Get.find<ThemeController>().darkTheme ? 600 : 200], // Shimmer foreground color
                              height: 55, width: 55, // **SHIMMER ADJUSTMENT 3: Reduced shimmer logo size (80 -> 55)**
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 15, width: 100,
                                color: Colors.grey[Get.find<ThemeController>().darkTheme ? 600 : 200],
                              ),
                              // **SHIMMER ADJUSTMENT 4: Reduced spacing**
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Container(
                                height: 15, width: 200,
                                color: Colors.grey[Get.find<ThemeController>().darkTheme ? 600 : 200],
                              ),
                              // **SHIMMER ADJUSTMENT 4: Reduced spacing**
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 15, width: 50,
                                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 600 : 200],
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Container(
                                    height: 15, width: 50,
                                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 600 : 200],
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),

                                  Container(
                                    height: 15, width: 50,
                                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 600 : 200],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // **SHIMMER ADJUSTMENT 5: Removed bottom space**
                  ]
              ),
            ),
          );
        },
      ) : ListView.builder(
          itemCount: 3,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              child: Container(
                // **SHIMMER ADJUSTMENT 6: Reduced width**
                width: 325, height: 80,
                // **SHIMMER ADJUSTMENT 2: Reduced internal padding from Dimensions.paddingSizeDefault to Dimensions.paddingSizeSmall**
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Theme.of(context).shadowColor.withOpacity(0.5)),
                  // ⭐️ MODIFIED: Lighter shimmer background (Increased opacity)
                  color: Colors.white.withOpacity(0.65), // Increased from 0.5 to 0.65
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      // **SHIMMER ADJUSTMENT 3: Reduced shimmer logo size (80 -> 55)**
                      height: 40, width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: Shimmer(
                          child: Container(
                            color: Theme.of(context).shadowColor.withOpacity(0.5),
                            // **SHIMMER ADJUSTMENT 3: Reduced shimmer logo size (80 -> 55)**
                            height: 40, width: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                        Shimmer(child: Container(height: 15, width: 100, color: Theme.of(context).shadowColor.withOpacity(0.5))),
                        // **SHIMMER ADJUSTMENT 4: Reduced spacing**
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Shimmer(child: Container(height: 15, width: 200, color: Theme.of(context).shadowColor.withOpacity(0.5))),
                        // **SHIMMER ADJUSTMENT 4: Reduced spacing**
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                          Shimmer(child: Container(height: 15, width: 50, color: Theme.of(context).shadowColor.withOpacity(0.5))),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Shimmer(child: Container(height: 15, width: 50, color: Theme.of(context).shadowColor.withOpacity(0.5))),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Shimmer(child: Container(height: 15, width: 50, color: Theme.of(context).shadowColor.withOpacity(0.5))),

                        ]),
                      ]),
                    ),
                  ]),
                ]),
              ),
            );
          }
      ),
    );
  }
}
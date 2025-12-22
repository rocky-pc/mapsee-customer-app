import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_distance_cliper_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/coupon/domain/models/coupon_model.dart'
    as cm;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class RestaurantsViewWidget extends StatelessWidget {
  final List<Restaurant?>? restaurants;
  const RestaurantsViewWidget({super.key, this.restaurants});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: restaurants != null
          ? restaurants!.isNotEmpty
              ? GridView.builder(
                  shrinkWrap: true,
                  itemCount: restaurants!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isMobile(context)
                        ? 1
                        : ResponsiveHelper.isTab(context)
                            ? 3
                            : 4,
                    mainAxisSpacing: Dimensions.paddingSizeLarge,
                    crossAxisSpacing: Dimensions.paddingSizeLarge,
                    mainAxisExtent: 252, // DECREASED FROM 250 TO 230
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: !ResponsiveHelper.isDesktop(context)
                          ? Dimensions.paddingSizeDefault
                          : 0),
                  itemBuilder: (context, index) {
                    return RestaurantView(restaurant: restaurants![index]!);
                  },
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeOverLarge),
                    child: Column(
                      children: [
                        const SizedBox(height: 110),
                        const CustomAssetImageWidget(Images.emptyRestaurant,
                            height: 80, width: 80),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        Text('there_is_no_restaurant'.tr,
                            style: robotoMedium.copyWith(
                                color: Theme.of(context).disabledColor)),
                      ],
                    ),
                  ),
                )
          : GridView.builder(
              shrinkWrap: true,
              itemCount: 12,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isMobile(context)
                    ? 1
                    : ResponsiveHelper.isTab(context)
                        ? 3
                        : 4,
                mainAxisSpacing: Dimensions.paddingSizeLarge,
                crossAxisSpacing: Dimensions.paddingSizeLarge,
                mainAxisExtent: 230, // DECREASED FROM 250 TO 230
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: !ResponsiveHelper.isDesktop(context)
                      ? Dimensions.paddingSizeLarge
                      : 0),
              itemBuilder: (context, index) {
                return const WebRestaurantShimmer();
              },
            ),
    );
  }
}

// Replace the entire RestaurantView class with this updated version:

class RestaurantView extends StatelessWidget {
  final Restaurant restaurant;
  final Function()? onTap;
  final bool isSelected;

  const RestaurantView({
    super.key,
    required this.restaurant,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && restaurant.active!;
    bool isPureVeg = restaurant.veg == 1;
    bool isNonVeg = restaurant.nonVeg == 1;

    // --- RE-INTEGRATED CHARACTERISTICS LOGIC ---
    String characteristics = '';
    if (restaurant.characteristics != null) {
      for (var v in restaurant.characteristics!) {
        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CustomInkWellWidget(
        onTap: onTap ?? () {
          if (restaurant.restaurantStatus == 1) {
            Get.toNamed(RouteHelper.getRestaurantRoute(restaurant.id),
                arguments: RestaurantScreen(restaurant: restaurant));
          } else {
            showCustomSnackBar('restaurant_is_not_available'.tr);
          }
        },
        radius: Dimensions.radiusLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
                  child: CustomImageWidget(
                    image: restaurant.coverPhotoFullUrl ?? '',
                    fit: BoxFit.cover,
                    height: 160,
                    width: double.infinity,
                    isRestaurant: true,
                  ),
                ),

                // Delivery Time Badge (Reference Image Style)
                if (restaurant.deliveryTime != null)
                  Positioned(
                    bottom: 12,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            restaurant.deliveryTime!.toUpperCase(),
                            style: robotoBold.copyWith(fontSize: 13, color: Colors.black87),
                          ),
                          // Text(
                          //   'FREE DELIVERY',
                          //   style: robotoBold.copyWith(fontSize: 9, color: Colors.deepOrange),
                          // ),
                        ],
                      ),
                    ),
                  ),

                // Favorite
                Positioned(
                  top: 10,
                  right: 10,
                  child: CustomFavouriteWidget(
                    isWished: Get.find<FavouriteController>().wishRestIdList.contains(restaurant.id),
                    isRestaurant: true,
                    restaurant: restaurant,
                  ),
                ),
              ],
            ),

            // 2. Info Section
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Restaurant Name
                  Text(
                    restaurant.name ?? '',
                    style: robotoBold.copyWith(fontSize: 18, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Rating, Location and Distance Row
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.green[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.avgRating?.toStringAsFixed(1)} (${restaurant.ratingCount})',
                        style: robotoMedium.copyWith(fontSize: 13, color: Colors.black87),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('•', style: TextStyle(color: Colors.black54)),
                      ),
                      Expanded(
                        child: Text(
                          '${restaurant.address ?? 'White town'}, ${Get.find<RestaurantController>().getRestaurantDistance(
                            LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
                          ).toStringAsFixed(1)} km',
                          style: robotoRegular.copyWith(fontSize: 13, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Characteristics & Price for Two Row (DYNAMIC)
                  Row(
                    children: [
                      // Veg/Non-Veg Badges
                      if (isPureVeg) _buildVegBadge(true),
                      if (isPureVeg && isNonVeg) const SizedBox(width: 4),
                      if (isNonVeg) _buildVegBadge(false),

                      const SizedBox(width: 8),

                      // Combined Characteristics and Price
                      Expanded(
                        child: Text(
                          '${characteristics.isNotEmpty ? characteristics : ''}${characteristics.isNotEmpty && restaurant.minimumOrder != null ? ', ' : ''} • Starts from ₹${restaurant.minimumOrder?.toInt()}',
                          style: robotoRegular.copyWith(fontSize: 13, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVegBadge(bool isVeg) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Icon(
        Icons.circle,
        size: 7,
        color: isVeg ? Colors.green : Colors.red,
      ),
    );
  }
}

// Shimmer unchanged (kept as original)
class WebRestaurantShimmer extends StatelessWidget {
  final bool isDineInRestaurant;
  const WebRestaurantShimmer({super.key, this.isDineInRestaurant = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).shadowColor,
        border: Border.all(color: Theme.of(context).shadowColor),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Stack(clipBehavior: Clip.none, children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusDefault),
                topRight: Radius.circular(Dimensions.radiusDefault)),
            child: Shimmer(
              child: Container(
                height: 184,
                width: double.infinity,
                color: Theme.of(context).shadowColor,
              ),
            ),
          ),
          // ... (rest of shimmer unchanged)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Shimmer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 15, width: 100, color: Colors.grey[300]),
                  Container(height: 15, width: 50, color: Colors.grey[300]),
                ],
              ),
            ),
          ),
          Positioned(
            top: 184,
            left: 10,
            child: Container(
              height: 46,
              child: Center(
                child: Shimmer(
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 195,
            left: 60,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Shimmer(
                  child: Container(
                      height: 10,
                      width: context.width * 0.4,
                      color: Colors.grey[300]),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconWithTextRowWidget(
                      icon: Icons.star_border,
                      text: '0.0',
                      color: Theme.of(context).shadowColor,
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).shadowColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: Dimensions.paddingSizeSmall,
            right: Dimensions.paddingSizeSmall,
            child: Icon(Icons.favorite,
                size: 20, color: Theme.of(context).shadowColor),
          ),
        ]),
      ),
    );
  }
}

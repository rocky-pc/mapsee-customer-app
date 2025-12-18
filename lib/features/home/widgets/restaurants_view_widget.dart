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
import 'package:stackfood_multivendor/features/coupon/domain/models/coupon_model.dart' as cm;
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
          mainAxisExtent: 235, // DECREASED FROM 250 TO 230
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
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
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

  Future<List<cm.CouponModel>?> _getCoupons(int restaurantId) async {
    await Get.find<CouponController>()
        .getRestaurantCouponList(restaurantId: restaurantId);
    return Get.find<CouponController>().couponList;
  }

  @override
  Widget build(BuildContext context) {
    bool isAvailable = restaurant.open == 1 && restaurant.active!;
    String characteristics = '';
    // if (restaurant.characteristics != null) {
    //   for (var v in restaurant.characteristics!) {
    //     characteristics =
    //     '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
    //   }
    // }

    return FutureBuilder<List<cm.CouponModel>?>(
      future: _getCoupons(restaurant.id!),
      builder: (context, snapshot) {
        List<cm.CouponModel>? couponList = snapshot.data;
        cm.CouponModel? activeCoupon;
        String discountText = '';
        bool hasLiveCoupon = false;

        String formatValue(num value) {
          return value % 1 == 0 ? value.toInt().toString() : value.toString();
        }

        if (couponList != null && couponList.isNotEmpty) {
          try {
            activeCoupon = couponList.firstWhere((c) =>
            c.startDate != null &&
                c.expireDate != null &&
                DateTime.now().isAfter(DateTime.parse(c.startDate!)) &&
                DateTime.now().isBefore(DateTime.parse(c.expireDate!)));
          } catch (_) {
            activeCoupon = null;
          }

          if (activeCoupon != null) {
            discountText = activeCoupon.discountType == 'percent'
                ? '${formatValue(activeCoupon.discount as num)}% ${'off'.tr}'
                : '${formatValue(activeCoupon.discount as num)} ${'off'.tr}';
            if (activeCoupon.maxDiscount != null && activeCoupon.maxDiscount! > 0) {
              discountText = 'Up to ${formatValue(activeCoupon.maxDiscount!)} ${'off'.tr}';
            }
          } else if (couponList.isNotEmpty) {
            final first = couponList[0];
            discountText = first.discountType == 'percent'
                ? '${formatValue(first.discount as num)}% ${'off'.tr}'
                : '${formatValue(first.discount as num)} ${'off'.tr}';
          }
          hasLiveCoupon = true;
        }

        bool isPureVeg = restaurant.veg == true;
        bool isNonVeg = restaurant.nonVeg == true;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: isSelected
                ? Border.all(color: Theme.of(context).primaryColor, width: 1)
                : null,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.deepOrange.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: CustomInkWellWidget(
            onTap: onTap ??
                    () {
                  if (restaurant.restaurantStatus == 1) {
                    Get.toNamed(RouteHelper.getRestaurantRoute(restaurant.id),
                        arguments: RestaurantScreen(restaurant: restaurant));
                  } else if (restaurant.restaurantStatus == 0) {
                    showCustomSnackBar('restaurant_is_not_available'.tr);
                  }
                },
            radius: Dimensions.radiusDefault,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Cover Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radiusDefault),
                    topRight: Radius.circular(Dimensions.radiusDefault),
                  ),
                  child: CustomImageWidget(
                    image: restaurant.coverPhotoFullUrl ?? '',
                    fit: BoxFit.cover,
                    height: 179,
                    width: double.infinity,
                    isRestaurant: true,
                  ),
                ),

                // 2. Unavailable Overlay - Only on Cover Image
                if (!isAvailable)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 179, // Same height as the cover image
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radiusDefault),
                        topRight: Radius.circular(Dimensions.radiusDefault),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),

                // 3. Closed Badge
                if (!isAvailable)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'closed_now'.tr,
                        style: robotoMedium.copyWith(
                            color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                      ),
                    ),
                  ),

                // 4. Favourite Icon
                Positioned(
                  top: Dimensions.paddingSizeSmall,
                  right: Dimensions.paddingSizeSmall,
                  child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                    bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                    return CustomFavouriteWidget(
                      isWished: isWished,
                      isRestaurant: true,
                      restaurant: restaurant,
                    );
                  }),
                ),

                // 5. Distance Badge (unchanged position)
                Positioned(
                  top: 159,
                  right: 20,
                  child: ClipPath(
                    clipper: CurvedTopClipper(),
                    child: Container(
                      height: 25,
                      color: Theme.of(context).cardColor,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: Text(
                        '${Get.find<RestaurantController>().getRestaurantDistance(
                          LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
                        ).toStringAsFixed(2)} km',
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ),

                // 6. Logo (Left - unchanged)
                Positioned(
                  top: 185,
                  left: 16,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.3), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImageWidget(
                        image: restaurant.logoFullUrl ?? '',
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                        isRestaurant: true,
                      ),
                    ),
                  ),
                ),

                // 7. Main Info Area - Clean Two-Row Layout
                Positioned(
                  top: 182,
                  left: 70,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === TOP ROW: Name + Veg/NonVeg Badges + Rating ===
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name ?? '',
                              style: robotoBold.copyWith(fontSize: 15, color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Veg / Non-Veg Badges
                          if (isPureVeg )
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                border: Border.all(color: Colors.green, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Veg', style: robotoMedium.copyWith(color: Colors.green, fontSize: 10)),
                            ),
                          if (isNonVeg) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                border: Border.all(color: Colors.red, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Non-Veg', style: robotoMedium.copyWith(color: Colors.red, fontSize: 10)),
                            ),
                          ],

                          if (restaurant.ratingCount! > 0) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              restaurant.avgRating!.toStringAsFixed(1),
                              style: robotoMedium.copyWith(fontSize: 13),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 4),

                      // === BOTTOM ROW: Characteristics + Delivery Time + Coupon ===
                      Row(
                        children: [
                          // Characteristics
                          // if (characteristics.isNotEmpty)
                          //   Expanded(
                          //     flex: 3,
                          //     child: Text(
                          //       characteristics,
                          //       style: robotoRegular.copyWith(
                          //         fontSize: Dimensions.fontSizeSmall,
                          //         color: Theme.of(context).hintColor,
                          //       ),
                          //       maxLines: 1,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //   ),

                          // Delivery Time
                          if (restaurant.deliveryTime != null)
                            Row(
                              children: [
                                // if (characteristics.isNotEmpty) const SizedBox(width: 12),
                                Icon(Icons.access_time_filled, size: 14, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 4),
                                Text(
                                  restaurant.deliveryTime!,
                                  style: robotoMedium.copyWith(fontSize: 12),
                                ),
                              ],
                            ),

                          // Coupon Badge
                          if (hasLiveCoupon) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_offer, size: 14, color: Colors.purple),
                                  const SizedBox(width: 4),
                                  Text(
                                    discountText,
                                    style: robotoBold.copyWith(fontSize: 11, color: Colors.purple),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Free Delivery
                          if (restaurant.freeDelivery!)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  Image.asset(Images.deliveryIcon, height: 16, width: 16),
                                  const SizedBox(width: 4),
                                  Text('free'.tr, style: robotoMedium.copyWith(fontSize: 11, color: Colors.green)),
                                ],
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
      },
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
                      width:context.width * 0.4,
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
            child: Icon(Icons.favorite, size: 20,
                color: Theme.of(context).shadowColor),
          ),
        ]),
      ),
    );
  }
}
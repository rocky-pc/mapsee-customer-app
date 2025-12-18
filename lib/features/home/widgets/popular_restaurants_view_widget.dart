import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/widgets/custom_distance_cliper_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/coupon/domain/models/coupon_model.dart' as cm;
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class PopularRestaurantsViewWidget extends StatelessWidget {
  final bool isRecentlyViewed;
  final double cardHeight;

  const PopularRestaurantsViewWidget({
    super.key,
    this.isRecentlyViewed = false,
    this.cardHeight = 170,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? restaurantList = isRecentlyViewed
          ? restController.recentlyViewedRestaurantList
          : restController.popularRestaurantList;

      if (restaurantList != null && restaurantList.isEmpty) {
        return const SizedBox();
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context)
              ? Dimensions.paddingSizeSmall
              : Dimensions.paddingSizeLarge,
        ),
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ResponsiveHelper.isDesktop(context)
                  ? Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRecentlyViewed ? 'recently_viewed_restaurants'.tr : 'popular_restaurants'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                    ),
                    ArrowIconButtonWidget(onTap: () {
                      Get.toNamed(RouteHelper.getAllRestaurantRoute(isRecentlyViewed ? 'recently_viewed' : 'popular'));
                    }),
                  ],
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRecentlyViewed ? 'recently_viewed_restaurants'.tr : 'popular_restaurants'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                    ),
                    ArrowIconButtonWidget(onTap: () {
                      Get.toNamed(RouteHelper.getAllRestaurantRoute(isRecentlyViewed ? 'recently_viewed' : 'popular'));
                    }),
                  ],
                ),
              ),

              // Horizontal Cards
              restaurantList != null
                  ? SizedBox(
                height: cardHeight,
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0,
                  ),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: restaurantList.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurantList[index];
                    bool isAvailable = restaurant.open == 1 && restaurant.active!;

                    return FutureBuilder<List<cm.CouponModel>?>(
                      future: getCoupons(restaurant.id!),
                      builder: (context, snapshot) {
                        List<cm.CouponModel>? couponList = snapshot.data;
                        cm.CouponModel? activeCoupon;
                        String discountText = '';

                        String formatValue(num value) {
                          return value % 1 == 0 ? value.toInt().toString() : value.toString();
                        }

                        if (couponList != null && couponList.isNotEmpty) {
                          // Try to find currently active coupon
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
                            // Active coupon found
                            if (activeCoupon.maxDiscount != null && activeCoupon.maxDiscount! > 0) {
                              discountText = 'UPTO ₹${formatValue(activeCoupon.maxDiscount!)} OFF';
                            } else {
                              discountText = activeCoupon.discountType == 'percent'
                                  ? '${formatValue(activeCoupon.discount as num)}% OFF'
                                  : '₹${formatValue(activeCoupon.discount as num)} OFF';
                            }
                          } else {
                            // Fallback: Show first available coupon (even if not active yet or expired)
                            final first = couponList.first;
                            discountText = first.discountType == 'percent'
                                ? '${formatValue(first.discount as num)}% OFF'
                                : '₹${formatValue(first.discount as num)} OFF';
                          }
                        }

                        double cardWidth = ResponsiveHelper.isDesktop(context)
                            ? 190
                            : MediaQuery.of(context).size.width * 0.45;

                        return Padding(
                          padding: EdgeInsets.only(
                            left: (ResponsiveHelper.isDesktop(context) && index == 0 && Get.find<LocalizationController>().isLtr)
                                ? 0
                                : Dimensions.paddingSizeDefault,
                          ),
                          child: SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: CustomInkWellWidget(
                              onTap: () => Get.toNamed(
                                RouteHelper.getRestaurantRoute(restaurant.id),
                                arguments: RestaurantScreen(restaurant: restaurant),
                              ),
                              radius: Dimensions.radiusDefault,
                              child: Stack(
                                children: [
                                  // Cover Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    child: CustomImageWidget(
                                      image: restaurant.coverPhotoFullUrl ?? '',
                                      fit: BoxFit.cover,
                                      height: cardHeight,
                                      width: cardWidth,
                                      isRestaurant: true,
                                    ),
                                  ),

                                  // Dark gradient overlay
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusDefault)),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Coupon / Discount Badge - NOW SHOWS RELIABLY
                                  if (discountText.isNotEmpty)
                                    Positioned(
                                      top: 6,
                                      left: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFC6011), // Orange
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          discountText,
                                          style: robotoBold.copyWith(
                                            color: Colors.white,
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Favourite
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GetBuilder<FavouriteController>(builder: (favController) {
                                      bool isWished = favController.wishRestIdList.contains(restaurant.id);
                                      return CustomFavouriteWidget(
                                        isWished: isWished,
                                        isRestaurant: true,
                                        restaurant: restaurant,
                                      );
                                    }),
                                  ),

                                  // Closed Overlay
                                  if (!isAvailable)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'closed_now'.tr,
                                            style: robotoBold.copyWith(
                                              color: Colors.white,
                                              fontSize: Dimensions.fontSizeSmall,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Bottom Info
                                  Positioned(
                                    bottom: 8,
                                    left: 6,
                                    right: 8,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          restaurant.name ?? '',
                                          style: robotoBold.copyWith(
                                            color: Colors.white,
                                            fontSize: Dimensions.fontSizeDefault,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (restaurant.ratingCount! > 0)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.star, color: Colors.white, size: 12),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      restaurant.avgRating!.toStringAsFixed(1),
                                                      style: robotoBold.copyWith(
                                                        color: Colors.white,
                                                        fontSize: Dimensions.fontSizeExtraSmall,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            const SizedBox(width: 4),
                                            IconWithTextRowWidget(
                                              icon: Icons.access_time,
                                              text: '${restaurant.deliveryTime} • ${restController.getRestaurantDistance(LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!))).toStringAsFixed(1)} km',
                                              style: robotoMedium.copyWith(
                                                color: Colors.white,
                                                fontSize: Dimensions.fontSizeExtraSmall,
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
                          ),
                        );
                      },
                    );
                  },
                ),
              )
                  : const PopularRestaurantShimmer(),
            ],
          ),
        ),
      );
    });
  }

  Future<List<cm.CouponModel>?> getCoupons(int restaurantId) async {
    await Get.find<CouponController>().getRestaurantCouponList(restaurantId: restaurantId);
    return Get.find<CouponController>().couponList;
  }
}

class PopularRestaurantShimmer extends StatelessWidget {
  const PopularRestaurantShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
        itemCount: 7,
        itemBuilder: (context, index) {
          double cardWidth = ResponsiveHelper.isDesktop(context)
              ? 190
              : MediaQuery.of(context).size.width * 0.45;

          return Container(
            width: cardWidth,
            height: 170,
            margin: EdgeInsets.only(left: index == 0 ? 0 : Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
            ),
            child: Shimmer(
              child: Stack(
                children: [
                  Container(color: Colors.grey[300]),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.black.withOpacity(0.8), Colors.transparent]),
                      ),
                    ),
                  ),
                  Positioned(bottom: 28, left: 8, child: Container(height: 14, width: 120, color: Colors.grey[300])),
                  Positioned(bottom: 8, left: 8, child: Row(children: [
                    Container(height: 18, width: 50, color: Colors.grey[300]),
                    const SizedBox(width: 8),
                    Container(height: 12, width: 80, color: Colors.grey[300]),
                  ])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/coupon/domain/models/coupon_model.dart' as cm;
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
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
    this.cardHeight = 225, // Height adjusted for the text content below
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? restaurantList = isRecentlyViewed
          ? restController.recentlyViewedRestaurantList
          : restController.popularRestaurantList;

      if (restaurantList != null) {
        restaurantList = restaurantList.where((restaurant) {
          double distance = restController.getRestaurantDistance(LatLng(
            double.parse(restaurant.latitude!),
            double.parse(restaurant.longitude!),
          ));
          return distance <= AppConstants.restaurantActiveDistance;
        }).toList();
      }

      if (restaurantList != null && restaurantList.isEmpty) {
        return const SizedBox();
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context)
              ? Dimensions.paddingSizeExtraOverSmall
              : Dimensions.paddingSizeLarge,
        ),
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeExtraSmall),
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
                    final restaurant = restaurantList![index];
                    double distance = restController.getRestaurantDistance(LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)));
                    bool isAvailable = restaurant.open == 1 && restaurant.active!;

                    // --- Characteristics Logic ---
                    String characteristics = '';
                    if (restaurant.characteristics != null) {
                      for (var v in restaurant.characteristics!) {
                        characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
                      }
                    }

                    return FutureBuilder<List<cm.CouponModel>?>(
                      future: getCoupons(restaurant.id!),
                      builder: (context, snapshot) {
                        List<cm.CouponModel>? couponList = snapshot.data;
                        cm.CouponModel? activeCoupon;
                        String discountText = '';

                        String formatValue(num value) {
                          return value % 1 == 0 ? value.toInt().toString() : value.toString();
                        }

                        // --- Original Discount Logic ---
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
                            if (activeCoupon.maxDiscount != null && activeCoupon.maxDiscount! > 0) {
                              discountText = 'UPTO ₹${formatValue(activeCoupon.maxDiscount!)} OFF';
                            } else {
                              discountText = activeCoupon.discountType == 'percent'
                                  ? '${formatValue(activeCoupon.discount as num)}% OFF'
                                  : '₹${formatValue(activeCoupon.discount as num)} OFF';
                            }
                          } else {
                            final first = couponList.first;
                            discountText = first.discountType == 'percent'
                                ? '${formatValue(first.discount as num)}% OFF'
                                : '₹${formatValue(first.discount as num)} OFF';
                          }
                        }

                        double cardWidth = ResponsiveHelper.isDesktop(context) ? 180 : 160;

                        return Padding(
                          padding: EdgeInsets.only(
                            left: (ResponsiveHelper.isDesktop(context) && index == 0 && Get.find<LocalizationController>().isLtr)
                                ? 0
                                : Dimensions.paddingSizeDefault,
                          ),
                          child: SizedBox(
                            width: cardWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Image Stack
                                CustomInkWellWidget(
                                  onTap: () {
                                    Get.toNamed(
                                      RouteHelper.getRestaurantRoute(restaurant.id),
                                      arguments: RestaurantScreen(restaurant: restaurant),
                                    );
                                  },
                                  radius: Dimensions.radiusDefault,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        child: CustomImageWidget(
                                          image: restaurant.coverPhotoFullUrl ?? '',
                                          fit: BoxFit.cover,
                                          height: 140,
                                          width: cardWidth,
                                          isRestaurant: true,
                                        ),
                                      ),

                                      // Discount Badge
                                      if (discountText.isNotEmpty)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFC6011),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              discountText,
                                              style: robotoBold.copyWith(
                                                color: Colors.white,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ),
                                        ),

                                      // Favourite
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GetBuilder<FavouriteController>(builder: (favController) {
                                          bool isWished = favController.wishRestIdList.contains(restaurant.id);
                                          return CustomFavouriteWidget(
                                            isWished: isWished,
                                            size: 20,
                                            isRestaurant: true,
                                            restaurant: restaurant,
                                          );
                                        }),
                                      ),

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
                                                textAlign: TextAlign.center,
                                                style: robotoBold.copyWith(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // 2. Info Section (Below Image)
                                Text(
                                  restaurant.name ?? '',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 2),

                                // Rating and Delivery Info Row
                                Row(
                                  children: [
                                    if (restaurant.avgRating! > 0) ...[
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Color(0xFF1B5E20), shape: BoxShape.circle),
                                        child: const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        restaurant.avgRating!.toStringAsFixed(1),
                                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('•', style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                                      const SizedBox(width: 4),
                                    ],
                                    Expanded(
                                      child: Text(
                                        '${restaurant.deliveryTime} • ${distance.toStringAsFixed(1)} km',
                                        style: robotoMedium.copyWith(
                                          color: Color(0xFF171717),
                                          fontSize: Dimensions.fontSizeExtraSmall,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 2),

                                // Characteristics (Categories like Biryani, Burger, etc.)
                                if (characteristics.isNotEmpty)
                                  Text(
                                    characteristics,
                                    style: robotoRegular.copyWith(
                                      color: Theme.of(context).disabledColor,
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
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
    return await Get.find<CouponController>().getRestaurantCouponList(restaurantId: restaurantId, setActive: false);
  }
}

class PopularRestaurantShimmer extends StatelessWidget {
  const PopularRestaurantShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
            child: Shimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 140, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(Dimensions.radiusDefault))),
                  const SizedBox(height: 8),
                  Container(height: 15, width: 100, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 130, color: Colors.grey[300]),
                  const SizedBox(height: 4),
                  Container(height: 10, width: 80, color: Colors.grey[300]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

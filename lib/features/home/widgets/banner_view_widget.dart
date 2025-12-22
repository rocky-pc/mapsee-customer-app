// banner_view_widget.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/product/domain/models/basic_campaign_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

// Increased radius for a more prominent, rounded banner card look
const double _bannerBorderRadius = 17.0;

class BannerViewWidget extends StatelessWidget {
  const BannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<HomeController>(builder: (homeController) {
      // Safety check: ensure the list is not null and not empty
      bool hasBanners = homeController.bannerImageList != null && homeController.bannerImageList!.isNotEmpty;

      return !hasBanners ? const SizedBox() : Container(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                // This makes the banner take up 95% of the viewport width.
                viewportFraction: 0.95,
                // Reduced scale factor slightly as the banner is wider
                enlargeFactor: 0.15,
                height: GetPlatform.isDesktop ? 300 : 130,
                autoPlay: true,
                enlargeCenterPage: true,
                disableCenter: false,
                autoPlayInterval: const Duration(seconds: 5),
                onPageChanged: (index, reason) {
                  homeController.setCurrentIndex(index, true);
                },
              ),
              itemCount: homeController.bannerImageList!.length,
              itemBuilder: (context, index, _) {
                bool isCenter = index == homeController.currentIndex;

                return InkWell(
                  onTap: () {
                    // Handle navigation/interaction based on banner data type
                    if(homeController.bannerDataList![index] is Product) {
                      Product? product = homeController.bannerDataList![index];
                      ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
                        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                        builder: (con) => ProductBottomSheetWidget(product: product),
                      ) : showDialog(context: context, builder: (con) => Dialog(
                          child: ProductBottomSheetWidget(product: product)),
                      );
                    }else if(homeController.bannerDataList![index] is Restaurant) {
                      Restaurant restaurant = homeController.bannerDataList![index];
                      Get.toNamed(
                        RouteHelper.getRestaurantRoute(restaurant.id),
                        arguments: RestaurantScreen(restaurant: restaurant),
                      );
                    }else if(homeController.bannerDataList![index] is BasicCampaignModel) {
                      BasicCampaignModel campaign = homeController.bannerDataList![index];
                      Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    // MODIFIED: Reduced margin to utilize the extra width created by viewportFraction: 0.95
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_bannerBorderRadius),
                      boxShadow: isCenter ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ] : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(_bannerBorderRadius),
                      child: GetBuilder<SplashController>(builder: (splashController) {
                        return CustomImageWidget(
                          image: '${homeController.bannerImageList![index]}',
                          fit: BoxFit.cover,
                        );
                      }),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            // Sleek, Linear Banner Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: homeController.bannerImageList!.asMap().entries.map((entry) {
                int index = entry.key;
                bool isActive = index == homeController.currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4.0,
                  width: isActive ? 20.0 : 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: isActive ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraOverSmall),
          ],
        ),
      );
    });
  }
}
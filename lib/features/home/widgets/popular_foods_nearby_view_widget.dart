import 'package:carousel_slider/carousel_slider.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularFoodNearbyViewWidget extends StatefulWidget {
  const PopularFoodNearbyViewWidget({super.key});

  @override
  State<PopularFoodNearbyViewWidget> createState() => _PopularFoodNearbyViewWidgetState();
}

class _PopularFoodNearbyViewWidgetState extends State<PopularFoodNearbyViewWidget> {
  final CarouselSliderController carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(builder: (productController) {
      // Hide entire section if no popular products
      if (productController.popularProductList != null &&
          productController.popularProductList!.isEmpty) {
        return const SizedBox();
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context)
              ? Dimensions.reducepadding
              : Dimensions.reducepadding,
        ),
        child: SizedBox(
          height: ResponsiveHelper.isMobile(context) ? 350 : 375,
          width: Dimensions.webMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title + Arrow (mobile) or just Title (desktop)
              ResponsiveHelper.isDesktop(context)
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 45),
                child: Text(
                  'popular_foods_nearby'.tr,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeLarge ,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'popular_foods_nearby'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ArrowIconButtonWidget(
                      onTap: () => Get.toNamed(
                          RouteHelper.getPopularFoodRoute(true)),
                    ),
                  ],
                ),
              ),

              // Carousel Row with arrows (desktop only)
              Expanded(
                child: Row(
                  children: [
                    // Left arrow - desktop only
                    ResponsiveHelper.isDesktop(context)
                        ? ArrowIconButtonWidget(
                      isLeft: true,
                      onTap: () => carouselController.previousPage(),
                    )
                        : const SizedBox(),

                    // Carousel
                    productController.popularProductList != null
                        ? Expanded(
                      child: CarouselSlider.builder(
                        carouselController: carouselController,
                        options: CarouselOptions(
                          height: ResponsiveHelper.isMobile(context)
                              ? 300
                              : 300,
                          viewportFraction:
                          ResponsiveHelper.isDesktop(context)
                              ? 0.2
                              : 0.47,
                          enlargeFactor:
                          ResponsiveHelper.isDesktop(context)
                              ? 0.2
                              : 0.35,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          disableCenter: true,
                          padEnds: true,
                        ),
                        itemCount:
                        productController.popularProductList!.length,
                        itemBuilder: (context, index, _) {
                          return Padding(
                            // Bottom padding for each card
                            padding: const EdgeInsets.only(
                                bottom: Dimensions.paddingSizeLarge),
                            child: ItemCardWidget(
                              product: productController
                                  .popularProductList![index],
                              isBestItem: true,
                              isPopularNearbyItem: true,
                            ),
                          );
                        },
                      ),
                    )
                        : const ItemCardShimmer(isPopularNearbyItem: true),

                    // Right arrow - desktop only
                    ResponsiveHelper.isDesktop(context)
                        ? ArrowIconButtonWidget(
                      onTap: () => carouselController.nextPage(),
                    )
                        : const SizedBox(),
                  ],
                ),
              ),

              // Extra bottom spacing for the whole section (optional but recommended)
              SizedBox(height: Dimensions.paddingSizeExtraOverSmall),
            ],
          ),
        ),
      );
    });
  }
}
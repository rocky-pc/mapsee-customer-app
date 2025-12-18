// what_on_your_mind_view_widget.dart

import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WhatOnYourMindViewWidget extends StatelessWidget {
  const WhatOnYourMindViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {
      return categoryController.categoryList != null && categoryController.categoryList!.isNotEmpty
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeOverLarge,
              left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeExtraSmall : 0,
              right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeExtraSmall,
              bottom: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeOverLarge,
            ),
            child: ResponsiveHelper.isDesktop(context)
                ? Text('what_on_your_mind'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600))
                : Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('what_on_your_mind'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600)),
                  ArrowIconButtonWidget(onTap: () => Get.toNamed(RouteHelper.getCategoryRoute())),
                ],
              ),
            ),
          ),

          SizedBox(
            // **DECREASED HEIGHT HERE:** 140 -> 120 (Mobile), 220 -> 200 (Desktop)
            height: ResponsiveHelper.isMobile(context) ? 120 : 200,
            child: categoryController.categoryList != null
                ? ListView.builder(
              physics: ResponsiveHelper.isMobile(context) ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
              itemCount: categoryController.categoryList!.length > 10 ? 10 : categoryController.categoryList!.length,
              itemBuilder: (context, index) {
                if (index == 9) {
                  return ResponsiveHelper.isDesktop(context)
                      ? Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraOverSmall, top: Dimensions.paddingSizeExtraOverSmall),
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          onTap: () => Get.toNamed(RouteHelper.getCategoryRoute()),
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                            ),
                            child: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ),
                  )
                      : const SizedBox();
                }

                // **DECREASED ITEM BASE SIZE HERE:** 90 -> 70 (Mobile), 140 -> 120 (Desktop)
                double size = ResponsiveHelper.isMobile(context) ? 90 : 120;
                double framePadding = ResponsiveHelper.isMobile(context) ? 4 : 10;

                // The item container now only needs to accommodate the image size
                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeDefault),
                  child: SizedBox(
                    width: size + framePadding * 2,
                    height: size + framePadding * 2 ,
                    child: CustomInkWellWidget(
                      onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                        categoryController.categoryList![index].id,
                        categoryController.categoryList![index].name!,
                      )),
                      radius: Dimensions.radiusDefault,
                      child: Padding(
                        padding: EdgeInsets.all(framePadding),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          // Use a Stack to overlay the text on the image
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Image (fills the space)
                              CustomImageWidget(
                                image: '${categoryController.categoryList![index].imageFullUrl}',
                                height: size,
                                width: size,
                                fit: BoxFit.cover,
                              ),

                              // Optional: Add a subtle overlay for better text readability
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.0),
                                      Colors.black.withOpacity(0.6), // Darken the bottom for white text
                                    ],
                                    stops: const [0.5, 1.0],
                                  ),
                                ),
                              ),

                              // 2. Text (Positioned at the bottom)
                              Positioned(
                                bottom: Dimensions.paddingSizeExtraSmall,
                                left: Dimensions.paddingSizeExtraSmall,
                                right: Dimensions.paddingSizeExtraSmall,
                                child: Text(
                                  categoryController.categoryList![index].name!,
                                  style: robotoMedium.copyWith(
                                    fontSize: ResponsiveHelper.isMobile(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
                                    color: Colors.white, // **White Color Text**
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
                : WebWhatOnYourMindViewShimmer(categoryController: categoryController),
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ],
      )
          : const SizedBox();
    });
  }
}

// Shimmer for Web/Desktop
class WebWhatOnYourMindViewShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const WebWhatOnYourMindViewShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    // **DECREASED SHIMMER ITEM BASE SIZE HERE:** 90 -> 70 (Mobile), 140 -> 120 (Desktop)
    double size = ResponsiveHelper.isMobile(context) ? 70 : 120;
    double framePadding = ResponsiveHelper.isMobile(context) ? 4 : 10;

    return SizedBox(
      // **DECREASED SHIMMER SIZEDBOX HEIGHT HERE:** 120 -> 100 (Mobile), 220 -> 200 (Desktop)
      height: ResponsiveHelper.isMobile(context) ? 100 : 200, // Match the new list height
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeDefault),
            child: SizedBox(
              width: size + framePadding * 2,
              height: size + framePadding * 2,
              child: Shimmer(
                child: Padding(
                  padding: EdgeInsets.all(framePadding),
                  child: Container(
                    height: size,
                    width: size,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
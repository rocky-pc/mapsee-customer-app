import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BestReviewItemViewWidget extends StatelessWidget {
  final bool isPopular;
  const BestReviewItemViewWidget({super.key, required this.isPopular});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<ReviewController>(builder: (reviewController) {
      if (reviewController.reviewedProductList == null ||
          reviewController.reviewedProductList!.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(
          vertical: isMobile ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge,
          horizontal: isDesktop ? Dimensions.paddingSizeLarge : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Header with Badge & See All
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraLarge,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Badge Style Label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'top_rated'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'best_reviewed_food'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ArrowIconButtonWidget(
                    onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute(isPopular)),
                    // color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Horizontal Scrollable Cards
            SizedBox(
              height: isMobile ? 295 : 220,
              child: ListView.builder(
                padding: EdgeInsets.only(
                  left: isMobile ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraLarge,
                  right: isMobile ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: reviewController.reviewedProductList!.length,
                itemBuilder: (context, index) {
                  final product = reviewController.reviewedProductList![index];

                  return Container(
                    width: isDesktop ? 220 : MediaQuery.of(context).size.width * 0.58,
                    margin: EdgeInsets.only(
                      right: Dimensions.paddingSizeLarge,
                      left: index == 0 ? 0 : 0,
                    ),
                    child: Stack(
                      children: [
                        ItemCardWidget(
                          isBestItem: true,
                          product: product,

                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurants_card_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderAgainViewWidget extends StatelessWidget {
  const OrderAgainViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Color orangeAccent = Theme.of(context).primaryColor;

    return GetBuilder<RestaurantController>(builder: (restController) {
      if (restController.orderAgainRestaurantList == null ||
          restController.orderAgainRestaurantList!.isEmpty) {
        return const SizedBox();
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isMobile(context)
              ? Dimensions.paddingSizeDefault
              : Dimensions.paddingSizeLarge,
          horizontal: ResponsiveHelper.isMobile(context)
              ? Dimensions.paddingSizeDefault
              : 0,
        ),
        child: Container(
          width: Dimensions.webMaxWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Helps minimize height
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'order_again'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge, // Slightly smaller than extraLarge
                              fontWeight: FontWeight.w700,
                              color: orangeAccent,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            '${'recently_you_ordered_from'.tr} ${restController.orderAgainRestaurantList!.length} ${'restaurants'.tr}',
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                              fontSize: Dimensions.fontSizeExtraSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ArrowIconButtonWidget(
                      onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute('order_again')),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall), // Reduced gap
                SizedBox(
                  height: ResponsiveHelper.isDesktop(context) ? 150 : 140, // Compact card height
                  child: ListView.builder(
                    itemCount: restController.orderAgainRestaurantList!.length,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: Dimensions.paddingSizeDefault,
                          left: index == 0 ? 0 : 0,
                        ),
                        child: RestaurantsCardWidget(
                          isNewOnStackFood: false,
                          restaurant: restController.orderAgainRestaurantList![index],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
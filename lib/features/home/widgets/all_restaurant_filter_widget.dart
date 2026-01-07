import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/home/widgets/filter_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurant_filter_button_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/light_theme.dart';
class AllRestaurantFilterWidget extends StatelessWidget {
  const AllRestaurantFilterWidget({super.key, });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(
      builder: (restaurantController) {
        List<Restaurant>? restaurantList = restaurantController.restaurantModel?.restaurants;

        if (restaurantList != null) {
          final restController = Get.find<RestaurantController>();
          restaurantList = restaurantList.where((restaurant) {
            if(restaurant.latitude != null && restaurant.longitude != null) {
              try {
                double distance = restController.getRestaurantDistance(LatLng(
                  double.parse(restaurant.latitude!),
                  double.parse(restaurant.longitude!),
                ));
                return distance <= AppConstants.restaurantActiveDistance;
              } catch (e) {
                return false;
              }
            }
            return false;
          }).toList();
        }

        return Center(
          child: ResponsiveHelper.isDesktop(context) ? Container(
              height: 70,
              width: Dimensions.webMaxWidth,
              color: Theme.of(context).colorScheme.surface,

              child: Row(
                children: [

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('all_restaurants'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600)),

                    Text(
                      '${restaurantList != null ? restaurantList.length : 0} ${'restaurants_near_you'.tr}',
                      style: robotoBold.copyWith(color:deepBlack, fontSize: Dimensions.fontSizeSmall),
                    ),
                  ]),

                  const Expanded(child: SizedBox()),

                  filter(context, restaurantController),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                ],
              )

          ) : Container(
            transform: Matrix4.translationValues(0, -2, 0),
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, /*vertical: Dimensions.paddingSizeExtraSmall*/),
            child: Column(children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('all_restaurants'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      text: '${restaurantList != null ? restaurantList.length : 0} ',
                      style: robotoRegular.copyWith(color: deepBlack, fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(text: 'restaurants_near_you'.tr, style: robotoRegular.copyWith(color: deepBlack, fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              filter(context, restaurantController),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              const Divider(),
            ]),
          ),
        );
      }
    );
  }

  Widget filter(BuildContext context, RestaurantController restaurantController) {
    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          ResponsiveHelper.isDesktop(context) ? const SizedBox() : const FilterViewWidget(),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          RestaurantsFilterButtonWidget(
            buttonText: 'top_rated'.tr,
            onTap: () => restaurantController.setTopRated(),
            isSelected: restaurantController.topRated == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          RestaurantsFilterButtonWidget(
            buttonText: 'discounted'.tr,
            onTap: () => restaurantController.setDiscount(),
            isSelected: restaurantController.discount == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          RestaurantsFilterButtonWidget(
            buttonText: 'veg'.tr,
            onTap: () => restaurantController.setVeg(),
            isSelected: restaurantController.veg == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          RestaurantsFilterButtonWidget(
            buttonText: 'non_veg'.tr,
            onTap: () => restaurantController.setNonVeg(),
            isSelected: restaurantController.nonVeg == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          ResponsiveHelper.isDesktop(context) ? const FilterViewWidget() : const SizedBox(),

        ],
      ),
    );
  }
}

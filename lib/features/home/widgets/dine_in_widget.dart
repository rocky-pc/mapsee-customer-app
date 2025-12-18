import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DineInWidget extends StatelessWidget {
  const DineInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the start and end colors for the gradient
    // Adjust opacity or color as needed for the desired look
    final Color startColor = Theme.of(context).primaryColor.withOpacity(0.9);
    final Color endColor = Theme.of(context).primaryColor.withOpacity(0.5);

    return Container(
      padding: EdgeInsets.only(
        top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall,
        left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeOverLarge,
      ),
      margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        // Implementation of the requested gradient
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

        // Assuming Images.dineInUser is a correctly defined asset path
        CustomAssetImageWidget(Images.dineInUser, height: 65, width: 80),

        Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
            children: [

              // Text color set to white for contrast against the dark gradient
              Text(
                'want_to_dine_in'.tr,
                style: robotoBold.copyWith(color: Colors.white),
              ),

              SizedBox(height: Dimensions.paddingSizeExtraSmall), // Spacer

              CustomButtonWidget(
                width: 115, height: 35, radius: Dimensions.radiusSmall,
                buttonText: 'view_restaurants'.tr,
                isBold: false, fontSize: Dimensions.fontSizeSmall,
                onPressed: () {
                  Get.toNamed(RouteHelper.getDineInRestaurantScreen());
                },
              ),

            ]),

      ]),
    );
  }
}
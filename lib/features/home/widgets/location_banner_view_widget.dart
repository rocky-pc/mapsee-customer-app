import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationBannerViewWidget extends StatelessWidget {
  const LocationBannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final Color primaryColor = Theme.of(context).primaryColor;
    final bool isMobile = ResponsiveHelper.isMobile(context);
    // final bool isDesktop = ResponsiveHelper.isDesktop(context); // Not strictly needed

    // Adjusted dynamic sizes for compactness
    final double horizontalPadding = isMobile ? Dimensions.paddingSizeDefault : 0;
    final double verticalPadding = isMobile ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge;
    // Removed containerHeight: height is now content-driven!
    final double innerPadding = isMobile ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge;
    final double imageSize = isMobile ? 55 : 80; // Slightly smaller image
    final double imageWidth = isMobile ? 68 : 100; // Slightly smaller image width
    final double titleFontSize = isMobile ? Dimensions.fontSizeDefault : Dimensions.fontSizeLarge; // More compact text
    final double subtitleFontSize = isMobile ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault; // More compact text

    // Button sizes
    final double buttonWidth = isMobile ? 90 : 120;
    final double buttonHeight = isMobile ? 30 : 40;
    final double iconSize = 25; // Icon size
    final double iconBackgroundSize = 40; // Icon background size

    // Gradient logic for both light and dark themes
    final List<Color> gradientColors = isDark
        ? [
      primaryColor.withOpacity(0.5),
      primaryColor.withOpacity(0.5),
    ]
        : [
      primaryColor.withOpacity(0.05),
      primaryColor.withOpacity(0.25),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Container(
        // The main fix: Removed fixed height. Let the content dictate the height.
        padding: EdgeInsets.all(isMobile ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: ResponsiveHelper.isDesktop(context) ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ] : null,
        ),
        child: IntrinsicHeight( // Ensures the Row children match the height of the tallest child
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children vertically
              children: [
                SizedBox(width: innerPadding),

                // --- Left Section: Image and Text ---
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image
                      CustomAssetImageWidget(
                          Images.nearbyRestaurant,
                          height: imageSize,
                          width: imageWidth,
                          fit: BoxFit.contain
                      ),
                      SizedBox(width: isMobile ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge),

                      // Text
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
                          children: [
                            // Title
                            Text(
                                'find_nearby'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                )
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall / 2), // Reduced spacing

                            // Subtitle
                            Text(
                              'restaurant_near_from_you'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: subtitleFontSize,
                                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Right Section: Icon and Button (The main structural fix) ---
                Padding(
                  padding: EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: innerPadding),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the group vertically
                      children: [
                        // Icon (Now integrated into the Column, no need for Stack/Positioned offsets)
                        Container(
                          height: iconBackgroundSize,
                          width: iconBackgroundSize,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5
                                )
                              ]
                          ),
                          child: Center(
                            child: CustomAssetImageWidget(
                              Images.nearbyLocation,
                              height: iconSize,
                              width: iconSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // const SizedBox(height: Dimensions.paddingSizeLarge), // Small space between icon and button

                        // Button
                        CustomButtonWidget(
                          buttonText: 'see_location'.tr,
                          width: buttonWidth,
                          height: buttonHeight,
                          fontSize: Dimensions.fontSizeSmall,
                          isBold: false,
                          radius: Dimensions.radiusDefault,
                          onPressed: () => Get.toNamed(RouteHelper.getMapViewRoute()),
                        ),
                      ]
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
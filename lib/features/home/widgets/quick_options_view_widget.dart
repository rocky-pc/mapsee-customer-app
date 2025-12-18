// quick_options_view_widget.dart
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuickOptionsViewWidget extends StatelessWidget {
  const QuickOptionsViewWidget({super.key});

  // Define a white color constant for text
  static const Color _whiteTextColor = Colors.white;

  // *** NEW: Define a constant for the custom font family name ***
  static const String _customFontFamily = 'SmoothCurveFont';

  // *** NEW: Define a custom TextStyle for the Title (Desktop/Mobile) ***
  TextStyle _getTitleTextStyle(BuildContext context, {required FontWeight fontWeight}) {
    return TextStyle(
      fontFamily: _customFontFamily,
      fontSize: Dimensions.fontSizeLarge,
      fontWeight: fontWeight,
      color: _whiteTextColor,
    );
  }

  // *** NEW: Define a custom TextStyle for the Option Name ***
  TextStyle _getOptionNameTextStyle() {
    return TextStyle(
      fontFamily: _customFontFamily,
      fontSize: Dimensions.fontSizeSmall,
      color: _whiteTextColor,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Change this to true/false based on your logic (e.g., from a controller)
    // For now, defaulting to 'popular'. You can make it dynamic later.
    final bool isRecentlyViewed = false;

    // Static list of options
    final List<Map<String, dynamic>> options = [
      {
        'name': 'Food',
        'image': Images.food,
        // Special route for Food
        'route': RouteHelper.getAllRestaurantRoute(
            isRecentlyViewed ? 'recently_viewed' : 'popular'),
      },
      {
        'name': 'Dine In',
        'image': Images.dinein,
        'route': RouteHelper.getDineInRestaurantScreen(),
      },
      {
        'name': 'Take Away',
        'image': Images.takefood,
        'route': RouteHelper.getSearchRoute(),
      },
      {
        'name': 'Delivery',
        'image': Images.delivery1,
        'route': RouteHelper.getSearchRoute(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: ResponsiveHelper.isMobile(context)
                ? Dimensions.paddingSizeSmall
                : Dimensions.paddingSizeOverLarge,
            left: Get.find<LocalizationController>().isLtr
                ? Dimensions.paddingSizeExtraSmall
                : 0,
            right: Get.find<LocalizationController>().isLtr
                ? 0
                : Dimensions.paddingSizeExtraSmall,
            bottom: ResponsiveHelper.isMobile(context)
                ? Dimensions.paddingSizeExtraSmall
                : Dimensions.paddingSizeOverLarge,
          ),
          child: ResponsiveHelper.isDesktop(context)
              ? Text(
            'Quick Options',
            style: _getTitleTextStyle(context, fontWeight: FontWeight.w600),
          )
              : Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeSmall,
                right: Dimensions.paddingSizeDefault),
            child: Text(
              'Quick Options',
              style: _getTitleTextStyle(context, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(
          height: ResponsiveHelper.isMobile(context) ? 120 : 190,
          child: ListView.builder(
            physics: ResponsiveHelper.isMobile(context)
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
            itemCount: options.length,
            itemBuilder: (context, index) {
              double size = ResponsiveHelper.isMobile(context) ? 80 : 110;

              // Image widget (same for all items)
              Widget displayItem = ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: Image.asset(
                  options[index]['image'],
                  width: size - 10,
                  height: size - 10,
                  fit: BoxFit.cover,
                ),
              );

              return Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeExtraSmall,
                    right: Dimensions.paddingSizeDefault),
                child: SizedBox(
                  width: size,
                  height: size + 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomInkWellWidget(
                        onTap: () => Get.toNamed(options[index]['route']),
                        radius: Dimensions.radiusDefault,
                        child: Container(
                          height: size,
                          width: size,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(
                                color: Theme.of(context).cardColor.withOpacity(0.5),
                                width: 1),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 1))
                            ],
                          ),
                          child: displayItem,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      SizedBox(
                        width: size,
                        child: Text(
                          options[index]['name'],
                          style: _getOptionNameTextStyle(),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraOverSmall),
      ],
    );
  }
}
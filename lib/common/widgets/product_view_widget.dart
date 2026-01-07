import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_shimmer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/restaurant_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/web_restaurant_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductViewWidget extends StatelessWidget {
  final List<Product?>? products;
  final List<Restaurant?>? restaurants;
  final bool isRestaurant;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inRestaurantPage;
  final bool showTheme1Restaurant;
  final bool? isWebRestaurant;
  final bool? fromFavorite;
  final bool? fromSearch;
  final bool showDiscount;
  final double? imageHeight;
  final double? imageWidth;
  const ProductViewWidget({super.key, required this.restaurants, required this.products, required this.isRestaurant, this.isScrollable = false,
    this.shimmerLength = 20, this.padding = const EdgeInsets.all(Dimensions.paddingSizeDefault), this.noDataText,
    this.isCampaign = false, this.inRestaurantPage = false, this.showTheme1Restaurant = false, this.isWebRestaurant = false, this.fromFavorite = false, this.fromSearch = false, this.showDiscount = true, this.imageHeight, this.imageWidth});

  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;
    if(isRestaurant) {
      isNull = restaurants == null;
      if(!isNull) {
        length = restaurants!.length;
      }
    }else {
      isNull = products == null;
      if(!isNull) {

        List<Product?>? productList = products;
        if (productList != null) {
          final restController = Get.find<RestaurantController>();
          productList = productList.where((product) {
            if(product!.restaurantLatitude != null && product.restaurantLongitude != null) {
              try {
                double distance = restController.getRestaurantDistance(LatLng(
                  double.parse(product.restaurantLatitude!),
                  double.parse(product.restaurantLongitude!),
                ));
                return distance <= AppConstants.restaurantActiveDistance;
              } catch (e) {
                return false;
              }
            } else {
              // If the product doesn't have lat/lng, try to find the restaurant
              // from the restaurant list and use its location.
              if (restController.restaurantModel != null && restController.restaurantModel!.restaurants != null) {
                final restaurant = restController.restaurantModel!.restaurants!.firstWhere((r) => r.id == product.restaurantId, orElse: () => Restaurant());
                if (restaurant.latitude != null && restaurant.longitude != null) {
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
              }
              // If the restaurant can't be found or doesn't have a location, hide the product.
              return false;
            }
          }).toList();
        }

        length = productList!.length;

      }
    }

    return Column(children: [

      !isNull ? length > 0 ? GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context) && !isWebRestaurant! ? Dimensions.paddingSizeLarge : isWebRestaurant! ? Dimensions.paddingSizeLarge : 0.01,
          mainAxisExtent: ResponsiveHelper.isDesktop(context) && !isWebRestaurant! ? (imageHeight != null ? (imageHeight! + 25) : 142) : isWebRestaurant! ? 280 : showTheme1Restaurant ? 200 : isRestaurant ? 150 : (imageHeight != null ? (imageHeight! + 25) : 120),
          crossAxisCount: ResponsiveHelper.isMobile(context) && !isWebRestaurant! ? 1 : isWebRestaurant! ? 4 : 3,
        ),
        physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: length,
        padding: padding,
        itemBuilder: (context, index) {
          return showTheme1Restaurant ? RestaurantWidget(restaurant: restaurants![index], index: index, inStore: inRestaurantPage)
          : isWebRestaurant! ? WebRestaurantWidget(restaurant: restaurants![index]) : ProductWidget(
            isRestaurant: isRestaurant, product: isRestaurant ? null : products![index],
            restaurant: isRestaurant ? restaurants![index] : null, index: index, length: length, isCampaign: isCampaign,
            inRestaurant: inRestaurantPage, showDiscount: showDiscount, imageHeight: imageHeight, imageWidth: imageWidth,
          );
        },
      ) : NoDataScreen(
        isEmptyRestaurant: isRestaurant ? true : false,
        isEmptyWishlist: fromFavorite! ? true : false,
        isEmptySearchFood: fromSearch! ? true : false,
        title: noDataText ?? (isRestaurant ? 'there_is_no_restaurant'.tr : 'there_is_no_food'.tr),
      ) : GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
          mainAxisExtent: ResponsiveHelper.isDesktop(context) && !isWebRestaurant! ? 142 : isWebRestaurant! ? 280 : showTheme1Restaurant ? 200 : 150,
          crossAxisCount: ResponsiveHelper.isMobile(context) && !isWebRestaurant! ? 1 : isWebRestaurant! ? 4 : 3,
        ),
        physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: shimmerLength,
        padding: padding,
        itemBuilder: (context, index) {
          return showTheme1Restaurant ? RestaurantShimmer(isEnable: isNull)
              : isWebRestaurant! ? const WebRestaurantShimmer() : ProductShimmer(isEnabled: isNull, isRestaurant: isRestaurant, hasDivider: index != shimmerLength-1);
        },
      ),

    ]);
  }
}

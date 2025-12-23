import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/dine_in/widgets/dine_in_restaurant_filter_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/dine_in/widgets/dine_in_restaurant_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DineInRestaurantScreen extends StatefulWidget {
  const DineInRestaurantScreen({super.key});

  @override
  State<DineInRestaurantScreen> createState() => _DineInRestaurantScreenState();
}

class _DineInRestaurantScreenState extends State<DineInRestaurantScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<DineInController>().initSetup(willUpdate: false);
    Get.find<DineInController>().getDineInRestaurantList(1, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWidget(
        title: 'restaurant_list'.tr,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)
              ],
            ),
            child: IconButton(
              onPressed: () {
                showCustomBottomSheet(child: const DineRestaurantFilterBottomSheet());
              },
              icon: Icon(Icons.tune_rounded, color: Theme.of(context).textTheme.bodyMedium!.color, size: 22),
            ),
          ),
        ],
      ),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      floatingActionButton: ResponsiveHelper.isDesktop(context)
          ? null
          : Align(
        alignment: ResponsiveHelper.isDesktop(context)
            ? Alignment.bottomRight
            : Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, bottom: 20),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.black,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            onPressed: () {
              Get.toNamed(RouteHelper.getMapViewRoute(fromDineInScreen: true));
            },
            label: Row(children: [
              CustomAssetImageWidget(Images.dineInMap, height: 20, width: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text('view_from_map'.tr,
                  style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault)),
            ]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: FooterViewWidget(
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: Dimensions.paddingSizeSmall),

                  // Desktop Header
                  ResponsiveHelper.isDesktop(context)
                      ? Container(
                    height: 64,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Row(children: [
                      Text(
                        'restaurant_list'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getMapViewRoute(fromDineInScreen: true)),
                        child: Container(
                          width: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            CustomAssetImageWidget(Images.dineInMap, height: 24, width: 24),
                            SizedBox(width: Dimensions.paddingSizeSmall),
                            Text('view_from_map'.tr, style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
                          ]),
                        ),
                      ),
                      SizedBox(width: Dimensions.paddingSizeSmall),
                      InkWell(
                        onTap: () {
                          Get.dialog(Dialog(child: const DineRestaurantFilterBottomSheet()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Theme.of(context).primaryColor),
                            color: Theme.of(context).cardColor,
                          ),
                          padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          child: Icon(Icons.filter_list_outlined, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ]),
                  )
                      : const SizedBox(),

                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

                  GetBuilder<DineInController>(builder: (dineInController) {
                    return dineInController.dineInModel != null
                        ? dineInController.dineInModel!.restaurants!.isNotEmpty
                        ? PaginatedListViewWidget(
                      scrollController: _scrollController,
                      totalSize: dineInController.dineInModel!.totalSize,
                      offset: dineInController.dineInModel!.offset,
                      onPaginate: (int? offset) async => await dineInController.getDineInRestaurantList(offset!, false),
                      productView: dineInRestaurant(dineInController.dineInModel!.restaurants!),
                    )
                        : Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: context.height * 0.3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CustomAssetImageWidget(Images.emptyRestaurant, height: 80, width: 80),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Text('there_is_no_restaurant'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                            ],
                          ),
                        ))
                        : DineInRestaurantShimmerWidget();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dineInRestaurant(List<Restaurant> restaurants) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: restaurants.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 3,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeLarge,
        // CHANGED: Reduced from 280 to 245 to remove excess bottom whitespace
        mainAxisExtent: 225,
      ),
      padding: ResponsiveHelper.isDesktop(context)
          ? EdgeInsets.zero
          : EdgeInsets.only(
          left: Dimensions.paddingSizeDefault,
          right: Dimensions.paddingSizeDefault,
          bottom: 100,
          top: 10),
      itemBuilder: (context, index) {
        Restaurant restaurant = restaurants[index];
        bool isAvailable = restaurant.open == 1 && restaurant.active!;
        String distance = Get.find<RestaurantController>()
            .getRestaurantDistance(
          LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!)),
        )
            .toStringAsFixed(1);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomInkWellWidget(
            onTap: () {
              if (restaurant.restaurantStatus == 1) {
                Get.toNamed(
                  RouteHelper.getRestaurantRoute(restaurant.id, fromDinIn: true),
                  arguments: RestaurantScreen(restaurant: restaurant, fromDineIn: true),
                );
              } else if (restaurant.restaurantStatus == 0) {
                showCustomSnackBar('restaurant_is_not_available'.tr);
              }
            },
            radius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TOP SECTION: IMAGE & BADGES ---
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: ColorFiltered(
                        colorFilter: isAvailable
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: CustomImageWidget(
                          image: restaurant.coverPhotoFullUrl ?? '',
                          height: 165, // Adjusted slightly to fit the new total height
                          width: double.infinity,
                          fit: BoxFit.cover,
                          isRestaurant: true,
                        ),
                      ),
                    ),

                    // Favourite Button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                        bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                        return Container(
                          height: 30, width: 30,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: CustomFavouriteWidget(
                              isWished: isWished,
                              isRestaurant: true,
                              restaurant: restaurant,
                              size: 18,
                            ),
                          ),
                        );
                      }),
                    ),

                    if (!isAvailable)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                restaurant.restaurantOpeningTime == 'closed'
                                    ? 'closed_now'.tr
                                    : 'opens_at'.tr + ' ' + DateConverter.convertRestaurantOpenTime(restaurant.restaurantOpeningTime!),
                                style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                              ),
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 12, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 4),
                            Text(distance + ' km', style: robotoBold.copyWith(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // --- BOTTOM SECTION: INFO ---
                Expanded( // Use Expanded to fill remaining space properly
                  child: Padding(
                    // CHANGED: Reduced padding to tighten the whitespace
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // Vertically center content
                      children: [
                        // Logo
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomImageWidget(
                              image: restaurant.logoFullUrl ?? '',
                              height: 36, width: 36, // Slightly smaller logo
                              fit: BoxFit.cover,
                              isRestaurant: true,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Text Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      restaurant.name ?? '',
                                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), // Slightly adjusted font size
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Rating Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          restaurant.avgRating!.toStringAsFixed(1),
                                          style: robotoBold.copyWith(color: Colors.white, fontSize: 10),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(Icons.star, color: Colors.white, size: 9),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4), // Reduced spacing

                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 12, color: Theme.of(context).disabledColor),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      restaurant.address ?? '',
                                      style: robotoRegular.copyWith(
                                        fontSize: 11, // Smaller font for address
                                        color: Theme.of(context).disabledColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
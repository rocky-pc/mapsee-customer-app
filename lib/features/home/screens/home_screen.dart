import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/cashback_dialog_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cashback_logo_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/dine_in_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/highlight_widget_view.dart';
import 'package:stackfood_multivendor/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/swiggy_header_view_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/screens/web_home_screen.dart';
import 'package:stackfood_multivendor/features/home/widgets/all_restaurant_filter_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/all_restaurants_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/best_review_item_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cuisine_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/location_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/new_on_stackfood_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/popular_foods_nearby_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/popular_restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/refer_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/screens/theme1_home_screen.dart';
import 'package:stackfood_multivendor/features/home/widgets/today_trends_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/what_on_your_mind_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/quick_options_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/balloon_animation_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/rush_hours_animation_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/heavy_traffic_animation_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:video_player/video_player.dart';
import '../widgets/enjoy_off_banner_view_widget.dart';
import '../widgets/location_animation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Future<void> loadData(bool reload) async {
    Get.find<HomeController>().getBannerList(reload);
    Get.find<CategoryController>().getCategoryList(reload, search: '');
    Get.find<CuisineController>().getCuisineList();
    Get.find<AdvertisementController>().getAdvertisementList();
    Get.find<DineInController>().getDineInRestaurantList(1, reload);
    if (Get.find<SplashController>().configModel!.popularRestaurant == 1) {
      Get.find<RestaurantController>()
          .getPopularRestaurantList(reload, 'all', false);
    }
    Get.find<CampaignController>().getItemCampaignList(reload);
    if (Get.find<SplashController>().configModel!.popularFood == 1) {
      Get.find<ProductController>().getPopularProductList(reload, 'all', false);
    }
    if (Get.find<SplashController>().configModel!.newRestaurant == 1) {
      Get.find<RestaurantController>()
          .getLatestRestaurantList(reload, 'all', false);
    }
    if (Get.find<SplashController>().configModel!.mostReviewedFoods == 1) {
      Get.find<ReviewController>().getReviewedProductList(reload, 'all', false);
    }
    Get.find<RestaurantController>().getRestaurantList(1, reload);
    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<ProfileController>().getUserInfo();
      Get.find<RestaurantController>()
          .getRecentlyViewedRestaurantList(reload, 'all', false);
      Get.find<RestaurantController>().getOrderAgainRestaurantList(reload);
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      Get.find<AddressController>().getAddressList();
      Get.find<HomeController>().getCashBackOfferList();
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ConfigModel? _configModel = Get.find<SplashController>().configModel;
  final TextEditingController _searchTextEditingController = TextEditingController();
  bool _isLogin = false;
  bool _landed = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<AuthController>().isLoggedIn();
    HomeScreen.loadData(false).then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();

      if ((Get.find<ProfileController>().userInfoModel?.isValidForDiscount ??
          false) &&
          Get.find<SplashController>().showReferBottomSheet) {
        Future.delayed(
            const Duration(milliseconds: 500), () => _showReferBottomSheet());
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800),
                  () => Get.find<HomeController>().changeFavVisibility());
        }
        if (Get.find<DashboardController>().showBottomNavBar) {
          Get.find<DashboardController>().showHideBottomNavBar(false);
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800),
                  () => Get.find<HomeController>().changeFavVisibility());
        }
        if (!Get.find<DashboardController>().showBottomNavBar) {
          Get.find<DashboardController>().showHideBottomNavBar(true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchTextEditingController.dispose();
    super.dispose();
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context)
        ? Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(Dimensions.radiusExtraLarge)),
        insetPadding: const EdgeInsets.all(22),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: const ReferBottomSheetWidget(),
      ),
      useSafeArea: false,
    ).then((_) =>
        Get.find<SplashController>().saveReferBottomSheetStatus(false))
        : showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: const ReferBottomSheetWidget(),
      ),
    ).then((_) =>
        Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      return GetBuilder<LocalizationController>(
          builder: (localizationController) {
            return Scaffold(
              appBar:
              ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
              endDrawer: const MenuDrawerWidget(),
              endDrawerEnableOpenDragGesture: false,
              // MODIFIED: Changed Scaffold background to the specific Primary Color
              backgroundColor: const Color(0xFFFD6723),

              body: Stack(
                children: [
                  // 1. BACKGROUND SCROLLABLE CONTENT
                  SafeArea(
                    child: RefreshIndicator(
                      onRefresh: () async => await HomeScreen.loadData(true),
                      child: ResponsiveHelper.isDesktop(context)
                          ? WebHomeScreen(scrollController: _scrollController)
                          : (Get.find<SplashController>().configModel!.theme == 2)
                          ? Theme1HomeScreen(scrollController: _scrollController)
                          : Column(
                        children: [
                          Expanded(
                            child: CustomScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [

                                // Header: Pass _landed status
                                SliverToBoxAdapter(
                                    child: SwiggyHeaderWidget(showIcon: _landed)),

                                // Sticky Search Bar
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: SwiggySliverDelegate(
                                    height: 66,
                                    child: SwiggySearchBarWidget(searchTextEditingController: _searchTextEditingController),
                                  ),
                                ),

                                // Quick Options Area
                                SliverToBoxAdapter(
                                  child: Container(
                                    color: const Color(0xFFF4F4F4),
                                    child: Container(
                                      height: 180,
                                      width: Dimensions.webMaxWidth,
                                      // MODIFIED: Added the 3-color fresh empathetic gradient here
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFD531F), // Main Primary
                                            Color(0xFFFF8847), // Fresh Secondary
                                            Color(0xFFFFB680), // Empathetic Light
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(30),
                                            bottomRight: Radius.circular(30)),
                                      ),
                                      child: Center(
                                        child: SizedBox(
                                          width: Dimensions.webMaxWidth,
                                          child: Stack(
                                            children: [
                                              GetBuilder<LocationController>(
                                                  builder:
                                                      (locationController) {
                                                    return locationController.weatherIconUrl ==
                                                        'https://mapsee.co.in/icons/festivel.png'
                                                        ? ClipRRect(
                                                        borderRadius: const BorderRadius.only(
                                                            bottomLeft: Radius.circular(30),
                                                            bottomRight: Radius.circular(30)),
                                                        child: BalloonAnimationWidget(
                                                          width: MediaQuery.of(context).size.width,
                                                          height: 180,
                                                          balloonDensity: 50,
                                                          balloonSpeed: 200,
                                                          minBalloonSize: 30,
                                                          maxBalloonSize: 60,
                                                        )
                                                    )
                                                        : const SizedBox.shrink();
                                                  }),
                                              GetBuilder<LocationController>(
                                                  builder:
                                                      (locationController) {
                                                    return locationController.weatherIconUrl ==
                                                        'https://mapsee.co.in/icons/traffic.png'
                                                        ? const HeavyTrafficAnimationWidget(
                                                      width: 260,
                                                      right: 10,
                                                      bottom: 137,
                                                    )
                                                        : const SizedBox.shrink();
                                                  }),
                                              GetBuilder<LocationController>(
                                                  builder:
                                                      (locationController) {
                                                    return locationController.weatherIconUrl ==
                                                        'https://mapsee.co.in/icons/rush-hours.png'
                                                        ? const RushHoursAnimationWidget(
                                                      width: 260,
                                                      right: 10,
                                                      bottom: 137,
                                                    )
                                                        : const SizedBox.shrink();
                                                  }),

                                              GetBuilder<LocationController>(
                                                  builder: (locationController) {
                                                    return locationController.weatherIconUrl == 'https://mapsee.co.in/icons/rain.png' &&
                                                        locationController.videoController != null &&
                                                        locationController.videoController!.value.isInitialized
                                                        ? Positioned.fill(
                                                      child: ClipRRect(
                                                        borderRadius: const BorderRadius.only(
                                                            bottomLeft: Radius.circular(30),
                                                            bottomRight: Radius.circular(30)),
                                                        child: FittedBox(
                                                          fit: BoxFit.cover,
                                                          child: SizedBox(
                                                            width: locationController.videoController!.value.size.width,
                                                            height: locationController.videoController!.value.size.height,
                                                            child: VideoPlayer(locationController.videoController!),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                        : const SizedBox.shrink();
                                                  }),

                                              const QuickOptionsViewWidget(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Content List
                                SliverToBoxAdapter(
                                  child: Container(
                                    color:
                                    Theme.of(context).colorScheme.surface,
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: Dimensions.paddingSizeSmall),

                                              Container(
                                                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                                  child: const BannerViewWidget()
                                              ),

                                              if (_configModel?.popularRestaurant == 1)
                                                const PopularRestaurantsViewWidget(),
                                              const WhatOnYourMindViewWidget(),
                                              const TodayTrendsViewWidget(),
                                              const LocationBannerViewWidget(),
                                              const HighlightWidgetView(),
                                              if (_configModel!.mostReviewedFoods == 1)
                                                const BestReviewItemViewWidget(isPopular: false),
                                              if (_configModel.dineInOrderOption!)
                                                const DineInWidget(),
                                              const CuisineViewWidget(),

                                              // Discount Logic (Restored)
                                              GetBuilder<RestaurantController>(
                                                  builder: (restController) {
                                                    List<Restaurant> restaurantsWithDiscount = [];

                                                    if (restController.popularRestaurantList != null) {
                                                      restaurantsWithDiscount.addAll(
                                                        restController.popularRestaurantList!.where((r) => r.discount != null),
                                                      );
                                                    }
                                                    if (restController.restaurantList != null) {
                                                      restaurantsWithDiscount.addAll(
                                                        restController.restaurantList!.where((r) => r.discount != null),
                                                      );
                                                    }

                                                    final seenIds = <int>{};
                                                    restaurantsWithDiscount.retainWhere((r) => seenIds.add(r.id!));

                                                    if (restaurantsWithDiscount.isEmpty) {
                                                      return const SizedBox.shrink();
                                                    }

                                                    return Column(
                                                      children: restaurantsWithDiscount.map((restaurant) {
                                                        final discount = restaurant.discount!;
                                                        return Container(
                                                          width: double.infinity,
                                                          margin: const EdgeInsets.symmetric(
                                                            vertical: Dimensions.paddingSizeSmall,
                                                            horizontal: Dimensions.paddingSizeLarge,
                                                          ),
                                                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                          decoration: BoxDecoration(
                                                            // MODIFIED: Use the specific primary color here as well
                                                            color: const Color(0xFFFD6723),
                                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                          ),
                                                          child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  discount.discountType == 'percent'
                                                                      ? '${discount.discount}% ${'off'.tr}'
                                                                      : '${PriceConverter.convertPrice(discount.discount)} ${'off'.tr}',
                                                                  style: robotoMedium.copyWith(
                                                                    fontSize: Dimensions.fontSizeLarge,
                                                                    color: Theme.of(context).cardColor,
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                const SizedBox(height: 4),
                                                                Text(
                                                                  discount.discountType == 'percent'
                                                                      ? '${'enjoy'.tr} ${discount.discount}% ${'off_on_all_categories'.tr}'
                                                                      : '${'enjoy'.tr} ${PriceConverter.convertPrice(discount.discount)} ${'off_on_all_categories'.tr}',
                                                                  style: robotoMedium.copyWith(
                                                                    fontSize: Dimensions.fontSizeSmall,
                                                                    color: Theme.of(context).cardColor,
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                const SizedBox(height: 8),
                                                                if (discount.minPurchase != 0 || discount.maxDiscount != 0)
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                                                    child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          if (discount.minPurchase != 0)
                                                                            Text(
                                                                              '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(discount.minPurchase)} ]  ',
                                                                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                                                                            ),
                                                                          if (discount.maxDiscount != 0)
                                                                            Text(
                                                                              '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(discount.maxDiscount)} ]',
                                                                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                                                                            ),
                                                                        ]),
                                                                  ),
                                                                Text(
                                                                  '[ ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(discount.startTime!)} - ${DateConverter.convertTimeToTime(discount.endTime!)} ]',
                                                                  style: robotoRegular.copyWith(
                                                                      fontSize: Dimensions.fontSizeExtraSmall,
                                                                      color: Theme.of(context).cardColor),
                                                                ),
                                                              ]),
                                                        );
                                                      }).toList(),
                                                    );
                                                  }),

                                              const ReferBannerViewWidget(),
                                              if (_isLogin)
                                                const PopularRestaurantsViewWidget(isRecentlyViewed: true),
                                              if (_configModel.popularFood == 1)
                                                const PopularFoodNearbyViewWidget(),
                                              if (_configModel.newRestaurant == 1)
                                                const NewOnStackFoodViewWidget(isLatest: true),
                                              const PromotionalBannerViewWidget(),
                                            ]),
                                      ),
                                    ),
                                  ),
                                ),

                                // Filter Header
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: SwiggySliverDelegate(
                                    height: 90,
                                    child: Container(
                                      color: Theme.of(context).cardColor,
                                      child: const AllRestaurantFilterWidget(),
                                    ),
                                  ),
                                ),

                                // Footer
                                SliverToBoxAdapter(
                                  child: Container(
                                    color: Theme.of(context).cardColor,
                                    child: Center(
                                      child: FooterViewWidget(
                                        child: Padding(
                                          padding: ResponsiveHelper.isDesktop(context)
                                              ? EdgeInsets.zero
                                              : const EdgeInsets.only(
                                              bottom: Dimensions.paddingSizeOverLarge),
                                          child: AllRestaurantsWidget(
                                              scrollController: _scrollController),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. REALISTIC FLYING PLANE (Foreground)
                  LocationAnimationWidget(onAnimationComplete: () {
                    setState(() {
                      _landed = true;
                    });
                  }),
                ],
              ),

              floatingActionButton: AuthHelper.isLoggedIn() &&
                  homeController.cashBackOfferList != null &&
                  homeController.cashBackOfferList!.isNotEmpty
                  ? homeController.showFavButton
                  ? Padding(
                padding: EdgeInsets.only(
                    bottom: ResponsiveHelper.isDesktop(context) ? 50 : 0,
                    right: ResponsiveHelper.isDesktop(context) ? 20 : 0),
                child: InkWell(
                    onTap: () => Get.dialog(const CashBackDialogWidget()),
                    child: const CashBackLogoWidget()),
              )
                  : null
                  : null,
            );
          });
    });
  }
}
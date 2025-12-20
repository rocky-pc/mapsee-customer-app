import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/cashback_dialog_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cashback_logo_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/dine_in_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/highlight_widget_view.dart';
import 'package:stackfood_multivendor/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/screens/web_home_screen.dart';
import 'package:stackfood_multivendor/features/home/widgets/all_restaurant_filter_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/all_restaurants_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/bad_weather_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/best_review_item_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cuisine_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/location_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/new_on_stackfood_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/order_again_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/popular_foods_nearby_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/popular_restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/refer_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/screens/theme1_home_screen.dart';
import 'package:stackfood_multivendor/features/home/widgets/today_trends_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/what_on_your_mind_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/quick_options_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/rain_animation_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/balloon_animation_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/rush_hours_animation_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/heavy_traffic_animation_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/common/widgets/customizable_space_bar_widget.dart';
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/enjoy_off_banner_view_widget.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ConfigModel? _configModel = Get.find<SplashController>().configModel;
  bool _isLogin = false;

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
      } else {
        if (Get.find<HomeController>().showFavButton) {
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800),
              () => Get.find<HomeController>().changeFavVisibility());
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  // --- START SWIGGY REDESIGN WIDGETS ---

  // Custom Swiggy-like Header/App Bar (Fixed Location Bar)
  Widget _buildSwiggyHeader(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: Dimensions.paddingSizeSmall,
          right: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color:
            Theme.of(context).primaryColor, // Changed to primaryColor (Orange)
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(
              Dimensions.radiusExtraLarge), // Applied Bottom Left Radius
          bottomRight: Radius.circular(
              Dimensions.radiusExtraLarge), // Applied Bottom Right Radius
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Location
          Expanded(
            child: InkWell(
              onTap: () =>
                  Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
              child: Padding(
                padding:
                    const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: GetBuilder<LocationController>(
                    builder: (locationController) {
                  // Reusing location logic
                  String addressText = AuthHelper.isLoggedIn() &&
                          AddressHelper.getAddressFromSharedPref() != null
                      ? AddressHelper.getAddressFromSharedPref()!.address!
                      : 'your_location'.tr;
                  String subText = AuthHelper.isLoggedIn() &&
                          AddressHelper.getAddressFromSharedPref() != null
                      ? AddressHelper.getAddressFromSharedPref()!
                          .addressType!
                          .tr
                      : 'your_sub_location'.tr;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Annamalai Nagar (Location Name)
                      Row(
                        children: [
                          Icon(CupertinoIcons.paperplane_fill,
                              size: 18, color: Theme.of(context).cardColor),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          Flexible(
                            child: Text(
                              AuthHelper.isLoggedIn() &&
                                      AddressHelper
                                              .getAddressFromSharedPref() !=
                                          null
                                  ? subText // Using addressType as main location name placeholder
                                  : 'your_location'.tr,
                              style: robotoMedium.copyWith(
                                  color: Theme.of(context).cardColor,
                                  fontSize: Dimensions
                                      .fontSizeLarge), // Text color changed to white
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down,
                              size: 20,
                              color: Theme.of(context)
                                  .cardColor), // Icon color changed to white
                        ],
                      ),
                      // Puducherry, India (Address detail)
                      Text(
                        addressText.tr,
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).cardColor.withOpacity(0.8),
                            fontSize: Dimensions
                                .fontSizeExtraSmall), // Text color changed to lighter white
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          // Bad Weather and Profile Icon (MODIFIED)
          Row(
            children: [
              // ADDED: Bad Weather Widget
              const BadWeatherWidget(),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              // Profile Icon
              InkWell(
                onTap: () => Get.toNamed(RouteHelper.getProfileRoute()),
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .cardColor, // Background changed to white
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person,
                      size: 20,
                      color: Theme.of(context)
                          .primaryColor), // Icon color changed to primaryColor (orange)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custom Swiggy-like Search Bar (Persistent Header)
  Widget _buildSwiggySearchBar(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      color: Theme.of(context)
          .primaryColor, // Changed to primaryColor (Orange) - needed for pinning
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall, vertical: 8),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: InkWell(
              onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .cardColor, // Keep inner search bar white
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 1))
                  ],
                ),
                child: Row(children: [
                  const Icon(CupertinoIcons.search,
                      size: 20, color: Colors.grey),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(
                      child: Text('Search for \'Sweets\''.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).hintColor))),

                  // ADDED: Separator Line
                  Container(
                    height: 30, // Adjust height as needed
                    width: 1.3,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeExtraSmall),
                  ),
                  // END ADDED: Separator Line

                  // Microphone Icon
                  Icon(Icons.mic_rounded,
                      size: 25,
                      color: Theme.of(context)
                          .disabledColor), // Kept Icons.mic_none as it is the closest standard icon
                ]),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          // Notification Icon (Replaced VEG Button)
          InkWell(
            onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .cardColor
                    .withOpacity(0.2), // Light background for contrast
                borderRadius: BorderRadius.circular(10),
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
              child: Center(
                child: Icon(
                  Icons.notifications_none,
                  size: 25,
                  color: Theme.of(context).cardColor, // Icon color white
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- END SWIGGY REDESIGN WIDGETS ---

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
          backgroundColor: Theme.of(context)
              .primaryColor, // <-- Status Bar/Notch Area is now Primary Color
          body: SafeArea(
            // Removed 'top: ResponsiveHelper.isDesktop(context)' to allow status bar/notch padding on mobile.
            child: RefreshIndicator(
              onRefresh: () async => await HomeScreen.loadData(true),
              child: ResponsiveHelper.isDesktop(context)
                  ? WebHomeScreen(scrollController: _scrollController)
                  : (Get.find<SplashController>().configModel!.theme == 2)
                      ? Theme1HomeScreen(scrollController: _scrollController)
                      : Column(
                          // Use Column for fixed header, then CustomScrollView
                          children: [
                            // 1. MAIN SCROLLABLE CONTENT AREA
                            Expanded(
                              child: CustomScrollView(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  // ADDED: Location Header (Now scrollable and has rounded corners)
                                  SliverToBoxAdapter(
                                      child: _buildSwiggyHeader(context)),

                                  // SEARCH BAR (Now persistent below fixed header)
                                  SliverPersistentHeader(
                                    pinned: true,
                                    delegate: SliverDelegate(
                                      height:
                                          66, // Matches the height of _buildSwiggySearchBar
                                      child: _buildSwiggySearchBar(context),
                                    ),
                                  ),

                                  // *** MODIFICATION START: EXTEND ORANGE BACKGROUND ***

                                  // ORANGE BACKGROUND FOR QUICK OPTIONS (BadWeatherWidget removed from here)
                                  SliverToBoxAdapter(
                                    child: Container(
                                      // === START MODIFICATION FOR BORDER RADIUS ===
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor, // Set Orange Background
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(
                                                Dimensions.radiusLarge),
                                            bottomRight: Radius.circular(
                                                Dimensions.radiusLarge)),
                                      ),
                                      // === END MODIFICATION FOR BORDER RADIUS ===
                                      child: Center(
                                        child: SizedBox(
                                          width: Dimensions.webMaxWidth,
                                          child: Stack(
                                            children: [
                                              // Rain Animation Layer (behind content)
                                              GetBuilder<LocationController>(
                                                  builder:
                                                      (locationController) {
                                                return locationController
                                                            .weatherIconUrl ==
                                                        'https://mapsee.co.in/icons/rain.png'
                                                    ? RainAnimationWidget(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 160,
                                                        rainDensity: 300,
                                                        rainAngle: 27,
                                                        rainSpeed: 900,
                                                        rainColor: Colors
                                                            .blueGrey.shade100,
                                                  thunder1XFactor: 0.2,   // 0.0 is far left, 1.0 is far right
                                                  thunder1YOffset: -90.0,  // pixels from top
                                                  thunder1Size: 320.0,    // pixel width/height

                                                  // EDIT THESE TO MOVE/RESIZE THUNDER 2
                                                  thunder2XFactor: 0.75,   // 0.0 is far left, 1.0 is far right
                                                  thunder2YOffset: -90.0,  // pixels from top
                                                  thunder2Size: 360.0,    // pixel width/height
                                                      )
                                                    : const SizedBox.shrink();
                                              }),
                                              // Balloon Animation Layer (festive animation)
                                              GetBuilder<LocationController>(
                                                  builder:
                                                      (locationController) {
                                                return locationController
                                                            .weatherIconUrl ==
                                                        'https://mapsee.co.in/icons/festivel.png'
                                                    ? BalloonAnimationWidget(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 160,
                                                        balloonDensity: 50,
                                                        balloonSpeed: 200,
                                                        minBalloonSize: 30,
                                                        maxBalloonSize: 60,
                                                      )
                                                    : const SizedBox.shrink();
                                              }),
                                              // Heavy Traffic Animation Layer
                                              GetBuilder<LocationController>(
                                                  builder:
                                                      (locationController) {
                                                return locationController
                                                            .weatherIconUrl ==
                                                        'https://mapsee.co.in/icons/traffic.png'
                                                    ? HeavyTrafficAnimationWidget(
                                                  width: 260, // Adjust width based on your header space
                                                  // top: 5,    // Move it down from the top
                                                  right: 10,  // Move it slightly away from the right edge
                                                  bottom: 120, // (Optional) set this if you want to align from bottom
                                                )
                                                    : const SizedBox.shrink();
                                              }),
                                              // Heavy Traffic Animation Layer
                                              GetBuilder<LocationController>(
                                                  builder:
                                                      (locationController) {
                                                    return locationController
                                                        .weatherIconUrl ==
                                                        'https://mapsee.co.in/icons/rush-hours.png'
                                                        ? RushHoursAnimationWidget(
                                                      width: 260, // Adjust width based on your header space
                                                      right: 10,  // Move it slightly away from the right edge
                                                      bottom: 120, // (Optional) set this if you want to align from bottom
                                                    )
                                                        : const SizedBox.shrink();
                                                  }),
                                              // Content Layer (on top)
                                              const QuickOptionsViewWidget(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // WHITE BACKGROUND FOR THE REST OF THE CONTENT
                                  SliverToBoxAdapter(
                                    // ADDED: Container to set the background color of the scrolling content to surface/white
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
                                                // Add a small space at the top of the white content area
                                                const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall),

                                                // 3. LIVE BANNER VIEW WIDGET (Requested to be used)
                                                Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        vertical: Dimensions
                                                            .paddingSizeSmall),
                                                    child:
                                                        const BannerViewWidget()),

                                                // 4. OTHER LIVE WIDGETS (What on your mind, trends, etc.)
                                                const WhatOnYourMindViewWidget(),
                                                const TodayTrendsViewWidget(),
                                                const LocationBannerViewWidget(),
                                                const HighlightWidgetView(),
                                                if (_isLogin)
                                                  const OrderAgainViewWidget(),
                                                if (_configModel!
                                                        .mostReviewedFoods ==
                                                    1)
                                                  const BestReviewItemViewWidget(
                                                      isPopular: false),
                                                if (_configModel
                                                    .dineInOrderOption!)
                                                  const DineInWidget(),
                                                const CuisineViewWidget(),

                                                // Popular Restaurants
                                                if (_configModel
                                                        .popularRestaurant ==
                                                    1)
                                                  const PopularRestaurantsViewWidget(),

                                                // Discount Banner (Kept original logic)
                                                GetBuilder<
                                                        RestaurantController>(
                                                    builder: (restController) {
                                                  List<Restaurant>
                                                      restaurantsWithDiscount =
                                                      [];

                                                  if (restController
                                                          .popularRestaurantList !=
                                                      null) {
                                                    restaurantsWithDiscount
                                                        .addAll(
                                                      restController
                                                          .popularRestaurantList!
                                                          .where((r) =>
                                                              r.discount !=
                                                              null),
                                                    );
                                                  }
                                                  if (restController
                                                          .restaurantList !=
                                                      null) {
                                                    restaurantsWithDiscount
                                                        .addAll(
                                                      restController
                                                          .restaurantList!
                                                          .where((r) =>
                                                              r.discount !=
                                                              null),
                                                    );
                                                  }

                                                  // Remove duplicates
                                                  final seenIds = <int>{};
                                                  restaurantsWithDiscount
                                                      .retainWhere((r) =>
                                                          seenIds.add(r.id!));

                                                  if (restaurantsWithDiscount
                                                      .isEmpty) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }

                                                  return Column(
                                                    children:
                                                        restaurantsWithDiscount
                                                            .map((restaurant) {
                                                      final discount =
                                                          restaurant.discount!;
                                                      return Container(
                                                        width: double.infinity,
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                          vertical: Dimensions
                                                              .paddingSizeSmall,
                                                          horizontal: Dimensions
                                                              .paddingSizeLarge,
                                                        ),
                                                        padding: const EdgeInsets
                                                            .all(Dimensions
                                                                .paddingSizeSmall),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          borderRadius: BorderRadius
                                                              .circular(Dimensions
                                                                  .radiusSmall),
                                                        ),
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                discount.discountType ==
                                                                        'percent'
                                                                    ? '${discount.discount}% ${'off'.tr}'
                                                                    : '${PriceConverter.convertPrice(discount.discount)} ${'off'.tr}',
                                                                style:
                                                                    robotoMedium
                                                                        .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeLarge,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .cardColor,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                discount.discountType ==
                                                                        'percent'
                                                                    ? '${'enjoy'.tr} ${discount.discount}% ${'off_on_all_categories'.tr}'
                                                                    : '${'enjoy'.tr} ${PriceConverter.convertPrice(discount.discount)} ${'off_on_all_categories'.tr}',
                                                                style:
                                                                    robotoMedium
                                                                        .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeSmall,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .cardColor,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              if (discount.minPurchase !=
                                                                      0 ||
                                                                  discount.maxDiscount !=
                                                                      0)
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          2),
                                                                  child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        if (discount.minPurchase !=
                                                                            0)
                                                                          Text(
                                                                            '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(discount.minPurchase)} ]  ',
                                                                            style:
                                                                                robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                                                                          ),
                                                                        if (discount.maxDiscount !=
                                                                            0)
                                                                          Text(
                                                                            '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(discount.maxDiscount)} ]',
                                                                            style:
                                                                                robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                                                                          ),
                                                                      ]),
                                                                ),
                                                              Text(
                                                                '[ ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(discount.startTime!)} - ${DateConverter.convertTimeToTime(discount.endTime!)} ]',
                                                                style: robotoRegular.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeExtraSmall,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .cardColor),
                                                              ),
                                                            ]),
                                                      );
                                                    }).toList(),
                                                  );
                                                }),

                                                const ReferBannerViewWidget(),
                                                if (_isLogin)
                                                  const PopularRestaurantsViewWidget(
                                                      isRecentlyViewed: true),
                                                if (_configModel.popularFood ==
                                                    1)
                                                  const PopularFoodNearbyViewWidget(),
                                                if (_configModel
                                                        .newRestaurant ==
                                                    1)
                                                  const NewOnStackFoodViewWidget(
                                                      isLatest: true),
                                                const PromotionalBannerViewWidget(),
                                              ]),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // *** MODIFICATION END ***

                                  // Filter & Restaurant List
                                  SliverPersistentHeader(
                                    pinned: true,
                                    delegate: SliverDelegate(
                                      height: 90,
                                      child: Container(
                                        // <--- FIX: Ensure filter background is white to prevent orange line
                                        color: Theme.of(context).cardColor,
                                        child:
                                            const AllRestaurantFilterWidget(),
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Container(
                                      // Set white background for the All Restaurants List
                                      color: Theme.of(context).cardColor,
                                      child: Center(
                                        child: FooterViewWidget(
                                          child: Padding(
                                            padding: ResponsiveHelper.isDesktop(
                                                    context)
                                                ? EdgeInsets.zero
                                                : const EdgeInsets.only(
                                                    bottom: Dimensions
                                                        .paddingSizeOverLarge),
                                            child: AllRestaurantsWidget(
                                                scrollController:
                                                    _scrollController),
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

class SliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

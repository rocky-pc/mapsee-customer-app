import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cart_product_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cart_suggested_item_view_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/checkout_button_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/pricing_view_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_constrained_box.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  final bool fromReorder;
  final bool fromDineIn;
  const CartScreen({super.key, required this.fromNav, this.fromReorder = false, this.fromDineIn = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();
  final GlobalKey _widgetKey = GlobalKey();
  double _height = 0;

  @override
  void initState() {
    super.initState();
    initCall();
  }

  Future<void> initCall() async {
    _initialBottomSheetShowHide();
    Get.find<RestaurantController>().makeEmptyRestaurant(willUpdate: false);
    Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
    Get.find<CheckoutController>().setInstruction(-1, willUpdate: false);
    await Get.find<CartController>().getCartDataOnline();
    if(Get.find<CartController>().cartList.isNotEmpty){
      await Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: Get.find<CartController>().cartList[0].product!.restaurantId, name: null), fromCart: true);
      Get.find<CartController>().calculationCart();
      if(Get.find<CartController>().addCutlery){
        Get.find<CartController>().updateCutlery(isUpdate: false);
      }
      if(Get.find<CartController>().needExtraPackage){
        Get.find<CartController>().toggleExtraPackage(willUpdate: false);
      }
      Get.find<RestaurantController>().getCartRestaurantSuggestedItemList(Get.find<CartController>().cartList[0].product!.restaurantId);
      showReferAndEarnSnackBar();
    }
  }

  void _initialBottomSheetShowHide() {
    Future.delayed(const Duration(milliseconds: 600), () {
      key.currentState?.expand();
    }).then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        key.currentState?.contract();
      });
    });
  }

  void _getExpandedBottomSheetHeight() {
    if (_widgetKey.currentContext != null) {
      final RenderBox renderBox = _widgetKey.currentContext!.findRenderObject() as RenderBox;
      setState(() { _height = renderBox.size.height; });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    const Color orangePrimary = Colors.orangeAccent;
    final Color orangeShadow = Colors.orange.withOpacity(0.15);
    final Color orangeBorder = Colors.orange.withOpacity(0.2);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBarWidget(title: 'my_cart'.tr, isBackButtonExist: (isDesktop || !widget.fromNav)),
      endDrawer: const MenuDrawerWidget(),
      body: GetBuilder<RestaurantController>(builder: (restaurantController) {
        return GetBuilder<CartController>(builder: (cartController) {
          bool isRestaurantOpen = true;
          if(restaurantController.restaurant != null) {
            isRestaurantOpen = restaurantController.isRestaurantOpenNow(restaurantController.restaurant!.active!, restaurantController.restaurant!.schedules);
          }
          bool suggestionEmpty = (restaurantController.suggestedItems != null && restaurantController.suggestedItems!.isEmpty);
          double distance = Get.find<RestaurantController>().getRestaurantDistance(
            LatLng(double.parse(restaurantController.restaurant?.latitude ?? '0'), double.parse(restaurantController.restaurant?.longitude ?? '0')),
          );

          return (cartController.isLoading && widget.fromReorder) ? const Center(child: CircularProgressIndicator(color: orangePrimary))
              : cartController.cartList.isNotEmpty ? Column(
            children: [
              Expanded(
                child: ExpandableBottomSheet(
                  key: key,
                  persistentHeader: isDesktop ? const SizedBox() : _buildDragHandle(context),
                  background: Column(
                    children: [
                      WebScreenTitleWidget(title: 'my_cart'.tr),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: isDesktop ? const EdgeInsets.only(top: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
                          child: FooterViewWidget(
                            child: Center(
                              child: SizedBox(
                                width: Dimensions.webMaxWidth,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Expanded(
                                      flex: 6,
                                      child: Column(children: [
                                        // Restaurant Card with Orange Shadow
                                        restaurantController.restaurant != null ? Container(
                                          margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                            border: Border.all(color: orangeBorder),
                                            boxShadow: [BoxShadow(color: orangeShadow, blurRadius: 15, offset: const Offset(0, 8))],
                                          ),
                                          child: Row(children: [
                                            _buildRestaurantLogo(restaurantController),
                                            const SizedBox(width: Dimensions.paddingSizeDefault),
                                            Expanded(child: _buildRestaurantInfo(restaurantController, distance, orangePrimary)),
                                            _buildRatingTag(restaurantController, orangePrimary),
                                          ]),
                                        ) : _buildShimmer(context),

                                        // Cart Items Container
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                                          ),
                                          child: Column(children: [
                                            _buildRestaurantStatusBanner(isRestaurantOpen, restaurantController, isDesktop, orangePrimary),

                                            ListView.builder(
                                              physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                              itemCount: cartController.cartList.length,
                                              itemBuilder: (context, index) => CartProductWidget(
                                                cart: cartController.cartList[index], cartIndex: index,
                                                addOns: cartController.addOnsList[index], isAvailable: cartController.availableList[index],
                                                isRestaurantOpen: isRestaurantOpen,
                                              ),
                                            ),

                                            _buildAddMoreItemsButton(isRestaurantOpen, cartController, orangePrimary),
                                          ]),
                                        ),

                                        if(!isDesktop) CartSuggestedItemViewWidget(cartList: cartController.cartList),
                                        if(!isDesktop) PricingViewWidget(cartController: cartController, isRestaurantOpen: isRestaurantOpen, fromDineIn: widget.fromDineIn),
                                      ]),
                                    ),
                                    if(isDesktop) SizedBox(width: Dimensions.paddingSizeLarge),
                                    if(isDesktop) Expanded(flex: 4, child: PricingViewWidget(cartController: cartController, isRestaurantOpen: isRestaurantOpen, fromDineIn: widget.fromDineIn)),
                                  ]),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: _height),
                    ],
                  ),
                  onIsExtendedCallback: () => _getExpandedBottomSheetHeight(),
                  expandableContent: isDesktop ? const SizedBox() : _buildExpandablePricing(context, cartController),
                ),
              ),
              if(!isDesktop) CheckoutButtonWidget(cartController: cartController, availableList: cartController.availableList, isRestaurantOpen: isRestaurantOpen, fromDineIn: widget.fromDineIn),
            ],
          ) : NoDataScreen(isEmptyCart: true, title: 'you_have_not_add_to_cart_yet'.tr);
        });
      }),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.3), borderRadius: BorderRadius.circular(10)))),
    );
  }

  Widget _buildRestaurantLogo(RestaurantController restaurantController) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.orange, Colors.orangeAccent])),
      child: ClipOval(child: CustomImageWidget(image: restaurantController.restaurant?.logoFullUrl ?? '', height: 55, width: 55)),
    );
  }

  Widget _buildRestaurantInfo(RestaurantController restaurantController, double distance, Color orange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(restaurantController.restaurant?.name ?? '', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      const SizedBox(height: 4),
      Row(children: [
        Icon(Icons.location_on, color: orange, size: 14),
        const SizedBox(width: 4),
        Text('${distance.toStringAsFixed(1)} km', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey)),
        const SizedBox(width: 8),
        Icon(Icons.timer_outlined, color: orange, size: 14),
        const SizedBox(width: 4),
        Text(restaurantController.restaurant!.deliveryTime!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.grey)),
      ]),
    ]);
  }

  Widget _buildRatingTag(RestaurantController restaurantController, Color orange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: orange.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      child: Row(children: [
        Icon(Icons.star, size: 14, color: orange),
        const SizedBox(width: 4),
        Text(restaurantController.restaurant!.avgRating!.toStringAsFixed(1), style: robotoBold.copyWith(color: orange)),
      ]),
    );
  }

  Widget _buildRestaurantStatusBanner(bool isOpen, RestaurantController restCtrl, bool isDesktop, Color orange) {
    if (isOpen || restCtrl.restaurant == null) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge))),
      child: Text(
        '${'restaurant_is_closed_now'.tr} ${restCtrl.restaurant!.restaurantOpeningTime == 'closed' ? 'tomorrow'.tr : DateConverter.timeStringToTime(restCtrl.restaurant!.restaurantOpeningTime!)}',
        textAlign: TextAlign.center, style: robotoMedium.copyWith(color: Colors.redAccent, fontSize: Dimensions.fontSizeSmall),
      ),
    );
  }

  Widget _buildAddMoreItemsButton(bool isOpen, CartController cartCtrl, Color orange) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: TextButton.icon(
        onPressed: () => Get.toNamed(RouteHelper.getRestaurantRoute(cartCtrl.cartList[0].product!.restaurantId)),
        icon: Icon(Icons.add_circle_outline, color: orange),
        label: Text('add_more_items'.tr, style: robotoBold.copyWith(color: orange)),
      ),
    );
  }

  Widget _buildExpandablePricing(BuildContext context, CartController cartCtrl) {
    return Container(
      key: _widgetKey,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: Column(children: [
        _priceRow('item_price'.tr, PriceConverter.convertPrice(cartCtrl.itemPrice)),
        if(cartCtrl.variationPrice > 0) _priceRow('variations'.tr, '(+) ${PriceConverter.convertPrice(cartCtrl.variationPrice)}'),
        if(cartCtrl.addOns > 0) _priceRow('addons'.tr, '(+) ${PriceConverter.convertPrice(cartCtrl.addOns)}'),
        if(cartCtrl.itemDiscountPrice > 0) _priceRow('discount'.tr, '(-) ${PriceConverter.convertPrice(cartCtrl.itemDiscountPrice)}', isDiscount: true),
      ]),
    );
  }

  Widget _priceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: robotoRegular.copyWith(color: Colors.grey[600])),
        Text(value, style: robotoMedium.copyWith(color: isDiscount ? Colors.green : Colors.black)),
      ]),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer(child: Container(height: 80, margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12))));
  }

  Future<void> showReferAndEarnSnackBar() async {
    if(Get.find<ProfileController>().userInfoModel != null && Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      showCustomSnackBar('your_referral_discount_added_on_your_first_order'.tr, isError: false);
    }
  }
}
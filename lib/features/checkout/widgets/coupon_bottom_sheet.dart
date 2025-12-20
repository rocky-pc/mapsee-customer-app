import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/coupon/domain/models/customer_coupon_model.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/coupon/widgets/coupon_card_widget.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CouponBottomSheet extends StatefulWidget {
  final CheckoutController checkoutController;
  final double price;
  final double discount;
  final double addOns;
  final double deliveryCharge;
  final double charge;
  final double total;

  const CouponBottomSheet({
    super.key,
    required this.checkoutController,
    required this.price,
    required this.discount,
    required this.addOns,
    required this.deliveryCharge,
    required this.total,
    required this.charge,
  });

  @override
  State<CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  List<Coupon>? _availableCouponList;
  List<Coupon>? _unavailableCouponList;
  List<JustTheController>? _availableToolTipControllerList;
  List<JustTheController>? _unavailableToolTipControllerList;

  late double totalPrice;

  @override
  void initState() {
    super.initState();
    totalPrice = widget.total;

    // Filter available coupons
    if (Get.find<CouponController>().customerCouponModel?.available != null &&
        Get.find<CouponController>().customerCouponModel!.available!.isNotEmpty) {
      _availableCouponList = [];
      _availableToolTipControllerList = [];
      for (var coupon in Get.find<CouponController>().customerCouponModel!.available!) {
        if (widget.deliveryCharge == 0 && coupon.couponType != 'free_delivery') {
          _availableCouponList!.add(coupon);
          _availableToolTipControllerList!.add(JustTheController());
        } else if (widget.deliveryCharge != 0) {
          _availableCouponList!.add(coupon);
          _availableToolTipControllerList!.add(JustTheController());
        }
      }
    }

    // Filter unavailable coupons
    if (Get.find<CouponController>().customerCouponModel?.unavailable != null &&
        Get.find<CouponController>().customerCouponModel!.unavailable!.isNotEmpty) {
      _unavailableCouponList = [];
      _unavailableToolTipControllerList = [];
      for (var coupon in Get.find<CouponController>().customerCouponModel!.unavailable!) {
        if (widget.deliveryCharge == 0 && coupon.couponType != 'free_delivery') {
          _unavailableCouponList!.add(coupon);
          _unavailableToolTipControllerList!.add(JustTheController());
        } else if (widget.deliveryCharge != 0) {
          _unavailableCouponList!.add(coupon);
          _unavailableToolTipControllerList!.add(JustTheController());
        }
      }
    }
  }

  @override
  void dispose() {
    for (var toolTip in _availableToolTipControllerList ?? []) toolTip.dispose();
    for (var toolTip in _unavailableToolTipControllerList ?? []) toolTip.dispose();
    super.dispose();
  }

  // Instant centered success popup with tick icon
  void _showCenteredSuccessPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "CouponSuccess",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Text(
                        'Coupon applied successfully'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: context.height * 0.7,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context)
            ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: GetBuilder<CouponController>(builder: (couponController) {
        return Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 30),
                !ResponsiveHelper.isDesktop(context)
                    ? Container(
                  height: 4,
                  width: 35,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
                )
                    : const SizedBox(),
                IconButton(onPressed: () => Get.back(), icon: Icon(Icons.clear, color: Theme.of(context).disabledColor)),
              ],
            ),

            // Promo Code Field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
              ),
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        controller: widget.checkoutController.couponController,
                        style: robotoRegular.copyWith(height: ResponsiveHelper.isMobile(context) ? null : 2),
                        decoration: InputDecoration(
                          hintText: 'enter_promo_code'.tr,
                          hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                          isDense: true,
                          filled: true,
                          enabled: couponController.discount == 0,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                              right: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.local_offer_outlined, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      String couponCode = widget.checkoutController.couponController.text.trim();

                      if (couponController.discount! < 1 && !couponController.freeDelivery) {
                        if (couponCode.isEmpty) {
                          showCustomSnackBar('enter_a_coupon_code'.tr);
                          return;
                        }

                        if (couponController.isLoading) return;

                        // Instant feedback: Show success popup immediately
                        _showCenteredSuccessPopup();

                        // Then apply coupon in background
                        couponController
                            .applyCoupon(
                          couponCode,
                          (widget.price - widget.discount) + widget.addOns,
                          widget.deliveryCharge,
                          widget.charge,
                          totalPrice,
                          Get.find<RestaurantController>().restaurant!.id,
                        )
                            .then((discount) {
                          // Update UI based on actual result
                          if (discount != null && discount > 0) {
                            if (widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1) {
                              totalPrice = totalPrice - discount;
                              widget.checkoutController.checkBalanceStatus(totalPrice);
                            }
                          }
                          // If failed, you can show error here if needed
                          // (existing error handling via controller already covers it)
                        });
                      } else {
                        // Remove coupon
                        totalPrice = totalPrice + couponController.discount!;
                        couponController.removeCouponData(true);
                        widget.checkoutController.couponController.clear();
                        if (widget.checkoutController.isPartialPay || widget.checkoutController.paymentMethodIndex == 1) {
                          widget.checkoutController.checkBalanceStatus(totalPrice);
                        }
                      }
                    },
                    child: Container(
                      height: 45,
                      width: (couponController.discount! <= 0 && !couponController.freeDelivery) ? 100 : 50,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        color: (couponController.discount! <= 0 && !couponController.freeDelivery)
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: (couponController.discount! <= 0 && !couponController.freeDelivery)
                          ? couponController.isLoading
                          ? const SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                          : Text('apply'.tr, style: robotoMedium.copyWith(color: Colors.white))
                          : Icon(Icons.clear, color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),

            // Available Coupons List
            Expanded(
              child: _availableCouponList != null && _availableCouponList!.isNotEmpty
                  ? SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeDefault,
                        bottom: Dimensions.paddingSizeSmall,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('available_promo_for_this_order'.tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                      ),
                    ),
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: Dimensions.paddingSizeSmall,
                        crossAxisSpacing: Dimensions.paddingSizeSmall,
                        childAspectRatio: 3,
                      ),
                      itemCount: _availableCouponList!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            final code = _availableCouponList![index].code;
                            if (code == null) return;

                            widget.checkoutController.couponController.text = code;

                            if (couponController.discount! < 1 && !couponController.freeDelivery) {
                              if (couponController.isLoading) return;

                              // Instant success feedback
                              _showCenteredSuccessPopup();

                              // Apply in background
                              couponController
                                  .applyCoupon(
                                code,
                                (widget.price - widget.discount) + widget.addOns,
                                widget.deliveryCharge,
                                widget.charge,
                                totalPrice,
                                Get.find<RestaurantController>().restaurant!.id,
                                hideBottomSheet: true,
                              )
                                  .then((discount) {
                                if (discount != null && discount > 0) {
                                  widget.checkoutController.couponController.text =
                                  '$code (${couponController.freeDelivery ? 'free_delivery'.tr : PriceConverter.convertPrice(couponController.discount)})';

                                  if (widget.checkoutController.isPartialPay ||
                                      widget.checkoutController.paymentMethodIndex == 1) {
                                    widget.checkoutController.checkBalanceStatus(totalPrice, discount: discount);
                                  }
                                }
                              });
                            }
                          },
                          child: CouponCardWidget(
                            toolTipController: _availableToolTipControllerList,
                            couponList: _availableCouponList,
                            index: index,
                            onCopyClick: () {
                              if (_availableCouponList![index].code != null) {
                                widget.checkoutController.couponController.text = _availableCouponList![index].code!;
                              }
                            },
                          ),
                        );
                      },
                    ),

                    // Unavailable coupons (unchanged)
                    if (_unavailableCouponList != null && _unavailableCouponList!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('unavailable_promo'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                        ),
                      ),
                      GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: Dimensions.paddingSizeSmall,
                          crossAxisSpacing: Dimensions.paddingSizeSmall,
                          childAspectRatio: 3,
                        ),
                        itemCount: _unavailableCouponList!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        itemBuilder: (context, index) {
                          return CouponCardWidget(
                            unavailable: true,
                            toolTipController: _unavailableToolTipControllerList,
                            couponList: _unavailableCouponList,
                            index: index,
                            onCopyClick: () {},
                          );
                        },
                      ),
                    ],
                  ],
                ),
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Images.noCoupon, height: 70),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text('no_promo_available'.tr, style: robotoMedium),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      '${'please_add_manually_or_collect_promo_from'.tr} ${'your_business_name'.tr}',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
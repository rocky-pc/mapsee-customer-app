import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/widgets/checkout_button_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cutlary_view_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/extra_packaging_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/not_available_product_view_widget.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_instruction_view.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PricingViewWidget extends StatelessWidget {
  final CartController cartController;
  final bool isRestaurantOpen;
  final bool fromDineIn;
  const PricingViewWidget({super.key, required this.cartController, required this.isRestaurantOpen, this.fromDineIn = false});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    // Consistent Vibrant Theme Palette
    final Color orangeShadow = Colors.orange.withOpacity(0.15);
    final Color orangeBorder = Colors.orange.withOpacity(0.2);

    return Container(
      margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: orangeBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: orangeShadow,
            blurRadius: 20,
            offset: const Offset(0, 10), // High-definition vibrant shadow
          ),
        ],
      ),
      child: GetBuilder<RestaurantController>(builder: (restaurantController) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Desktop Header
          if (isDesktop) Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
            child: Text('order_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black87)),
          ),

          // Collapsible/Instruction Widgets (Clean integration)
          Column(children: [
            if (!fromDineIn) ExtraPackagingWidget(cartController: cartController),
            if (!fromDineIn) CutleryViewWidget(restaurantController: restaurantController, cartController: cartController),
            if (!isDesktop) NotAvailableProductViewWidget(cartController: cartController),
            const DeliveryInstructionView(),
          ]),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Pricing Rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ]),
            ]),
          ),

          if (isDesktop) Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: CheckoutButtonWidget(
              cartController: cartController,
              availableList: cartController.availableList,
              isRestaurantOpen: isRestaurantOpen,
              fromDineIn: fromDineIn,
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ]);
      }),
    );
  }
}
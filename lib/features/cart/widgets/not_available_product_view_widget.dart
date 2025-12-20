import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/widgets/not_available_bottom_sheet.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotAvailableProductViewWidget extends StatelessWidget {
  final CartController cartController;
  const NotAvailableProductViewWidget({super.key, required this.cartController});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    // Consistent Theme Palette
    const Color orangePrimary = Colors.orangeAccent;
    final Color orangeShadow = Colors.orange.withOpacity(0.15); // Vibrant shadow
    final Color orangeBorder = Colors.orange.withOpacity(0.2);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Reverted to CardColor for cleanliness
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: orangeBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: orangeShadow,
            blurRadius: 15,
            offset: const Offset(0, 8), // Matching the vibrant shadow from the CartScreen
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (isDesktop) {
                Get.dialog(const Dialog(child: NotAvailableBottomSheet()));
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (con) => const NotAvailableBottomSheet(),
                );
              }
            },
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: orangePrimary, size: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      'if_any_product_is_not_available'.tr,
                      style: robotoMedium.copyWith(color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: orangePrimary, size: 22),
                ],
              ),
            ),
          ),

          // Selection Indicator (Visible Result)
          if (cartController.notAvailableIndex != -1)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05), // Subtle tint for selection
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusLarge)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Text(
                      cartController.notAvailableList[cartController.notAvailableIndex].tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cartController.setAvailableIndex(-1),
                    child: Icon(Icons.cancel, size: 20, color: Colors.grey.withOpacity(0.6)),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
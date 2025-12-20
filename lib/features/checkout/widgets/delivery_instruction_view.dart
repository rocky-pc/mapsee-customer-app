import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_instruction_bottom_sheet.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryInstructionView extends StatefulWidget {
  const DeliveryInstructionView({super.key});

  @override
  State<DeliveryInstructionView> createState() => _DeliveryInstructionViewState();
}

class _DeliveryInstructionViewState extends State<DeliveryInstructionView> {
  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    // Consistent Vibrant Theme Palette
    const Color orangePrimary = Colors.orangeAccent;
    final Color orangeShadow = Colors.orange.withOpacity(0.15); // Vibrant glow
    final Color orangeBorder = Colors.orange.withOpacity(0.2);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Pure clean background
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: orangeBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: orangeShadow,
            blurRadius: 15,
            offset: const Offset(0, 8), // Matching the vibrant shadow theme
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (isDesktop) {
                Get.dialog(const Dialog(child: DeliveryInstructionBottomSheet()));
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (con) => const DeliveryInstructionBottomSheet(),
                );
              }
            },
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  // Action Icon
                  Icon(Icons.assignment_outlined, color: orangePrimary, size: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Text(
                      'add_more_delivery_instruction'.tr,
                      style: robotoMedium.copyWith(color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const Icon(Icons.add_circle_outline, color: orangePrimary, size: 22),
                ],
              ),
            ),
          ),

          // Active Selection View
          GetBuilder<CheckoutController>(
              builder: (checkoutController) {
                return checkoutController.selectedInstruction != -1 ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05), // Subtle selection tint
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusLarge)),
                    border: Border(top: BorderSide(color: orangeBorder, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_rounded, color: Colors.orange, size: 16),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Text(
                          AppConstants.deliveryInstructionList[checkoutController.selectedInstruction].tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () => checkoutController.setInstruction(-1),
                        child: Icon(Icons.remove_circle, size: 20, color: Colors.red.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ) : const SizedBox();
              }
          ),
        ],
      ),
    );
  }
}

    // return Container(
    //   decoration: BoxDecoration(
    //     color: Theme.of(context).cardColor,
    //     borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
    //     boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
    //   ),
    //   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
    //   margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
    //   child: GetBuilder<CheckoutController>(
    //     builder: (checkoutController) {
    //       return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    //
    //         Theme(
    //           data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    //           child: ExpansionTile(
    //             key: widget.key,
    //             controller: controller,
    //             title: Text('add_more_delivery_instruction'.tr, style: robotoMedium),
    //             trailing: Icon(checkoutController.isExpanded ? Icons.remove : Icons.add, size: 18),
    //             tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
    //             onExpansionChanged: (value) => checkoutController.expandedUpdate(value),
    //
    //             children: [
    //
    //               ResponsiveHelper.isDesktop(context) ? GridView.builder(
    //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //                   crossAxisSpacing: Dimensions.paddingSizeSmall,
    //                   mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
    //                   childAspectRatio: 3.5,
    //                   crossAxisCount:  2,
    //                 ),
    //                 physics: const NeverScrollableScrollPhysics(),
    //                 shrinkWrap: true,
    //                 itemCount: AppConstants.deliveryInstructionList.length,
    //                 padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
    //                 itemBuilder: (context, index) {
    //                   bool isSelected = checkoutController.selectedInstruction == index;
    //                   return InkWell(
    //                     onTap: () {
    //                       checkoutController.setInstruction(index);
    //                     },
    //                     child: Container(
    //                       padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
    //                       decoration: BoxDecoration(
    //                         color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.grey[200],
    //                         borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
    //                         border: Border.all(color: isSelected ?  Theme.of(context).primaryColor : Colors.transparent),
    //                       ),
    //                       child: Row(
    //                         children: [
    //                           Icon(Icons.ac_unit, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, size: 18),
    //                           const SizedBox(width: Dimensions.paddingSizeSmall),
    //                           Expanded(
    //                             child: Text(
    //                               AppConstants.deliveryInstructionList[index].tr,
    //                               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   );
    //                 },
    //               ) : ListView.builder(
    //                   shrinkWrap: true,
    //                   physics: const NeverScrollableScrollPhysics(),
    //                   itemCount: AppConstants.deliveryInstructionList.length,
    //                   itemBuilder: (context, index){
    //                     bool isSelected = checkoutController.selectedInstruction == index;
    //                     return InkWell(
    //                       onTap: () {
    //                         checkoutController.setInstruction(index);
    //                         if(controller.isExpanded) {
    //                           controller.collapse();
    //                         }
    //                       },
    //                       child: Container(
    //                         decoration: BoxDecoration(
    //                           color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.5) : Colors.grey[200],
    //                           borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
    //                           // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
    //                         ),
    //                         padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
    //                         margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
    //                         child: Row(children: [
    //                           Icon(Icons.ac_unit, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, size: 18),
    //                           const SizedBox(width: Dimensions.paddingSizeSmall),
    //
    //                           Expanded(
    //                             child: Text(
    //                               AppConstants.deliveryInstructionList[index].tr,
    //                               style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
    //                             ),
    //                           ),
    //                         ]),
    //
    //                       ),
    //                     );
    //                   }),
    //             ],
    //           ),
    //         ),
    //
    //         checkoutController.selectedInstruction != -1 && !ResponsiveHelper.isDesktop(context) ? Padding(
    //           padding:  EdgeInsets.symmetric(vertical: checkoutController.isExpanded ? Dimensions.paddingSizeSmall : 0),
    //           child: Row(children: [
    //             Text(
    //               AppConstants.deliveryInstructionList[checkoutController.selectedInstruction].tr,
    //               style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
    //             ),
    //
    //             InkWell(
    //               onTap: ()=> checkoutController.setInstruction(-1),
    //               child: const Icon(Icons.clear, size: 16),
    //             ),
    //           ])
    //         ) : const SizedBox(),
    //         SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),
    //
    //       ]);
    //     }
    //   ),
    // );
//   }
// }

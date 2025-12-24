import 'package:stackfood_multivendor/common/enums/order_status.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/order/screens/order_details_screen.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RunningOrderViewWidget extends StatelessWidget {
  final List<OrderModel> reversOrder;
  final Function() onMoreClick;
  const RunningOrderViewWidget({super.key, required this.reversOrder, required this.onMoreClick});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      return Container(
        // Makes it look like a floating popup
        margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          // 4-side Border Radius
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wraps content tightly
            children: [
              ListView.builder(
                itemCount: reversOrder.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  bool isFirstOrder = index == 0;

                  String? orderStatus = reversOrder[index].orderStatus ?? '';
                  int status = 0;

                  if (orderStatus == OrderStatus.pending.name) {
                    status = 1;
                  } else if (orderStatus == OrderStatus.accepted.name ||
                      orderStatus == OrderStatus.processing.name ||
                      orderStatus == OrderStatus.confirmed.name) {
                    status = 2;
                  } else if (orderStatus == OrderStatus.handover.name ||
                      orderStatus == OrderStatus.picked_up.name) {
                    status = 3;
                  }

                  return InkWell(
                    onTap: () async {
                      await Get.toNamed(
                        RouteHelper.getOrderDetailsRoute(reversOrder[index].id),
                        arguments: OrderDetailsScreen(
                          orderId: reversOrder[index].id,
                          orderModel: reversOrder[index],
                        ),
                      );
                      if (orderController.showBottomSheet) {
                        orderController.showRunningOrders();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: isFirstOrder
                          ? null
                          : BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Status Image/GIF
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            height: 60,
                            width: 60,
                            child: Image.asset(
                              status == 2
                                  ? (orderStatus == OrderStatus.confirmed.name ||
                                  orderStatus == OrderStatus.accepted.name)
                                  ? Images.processingGif
                                  : Images.cookingGif
                                  : status == 3
                                  ? (orderStatus == OrderStatus.handover.name
                                  ? Images.handoverGif
                                  : Images.onTheWayGif)
                                  : Images.pendingGif,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          // 2. Order Details & Trackers
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${'your_order_is'.tr} ',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        reversOrder[index].orderStatus!.tr,
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${'order'.tr} #${reversOrder[index].id}',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),

                                // Track View (Only for first item)
                                if (isFirstOrder) ...[
                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                  Row(children: [
                                    Expanded(child: trackView(context, status: status >= 1)),
                                    const SizedBox(width: 4),
                                    Expanded(child: trackView(context, status: status >= 2)),
                                    const SizedBox(width: 4),
                                    Expanded(child: trackView(context, status: status >= 3)),
                                    const SizedBox(width: 4),
                                    Expanded(child: trackView(context, status: status >= 4)),
                                  ]),
                                ]
                              ],
                            ),
                          ),

                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          // 3. Action Button (Arrow or Count)
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor, // Solid Primary Color
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: isFirstOrder && reversOrder.length > 1
                                ? InkWell(
                              onTap: onMoreClick,
                              child: Center(
                                child: Text(
                                  '+${reversOrder.length - 1}',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                              ),
                            )
                                : Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: status
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
    );
  }
}
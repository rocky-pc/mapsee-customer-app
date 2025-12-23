import 'package:carousel_slider/carousel_slider.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CouponViewWidget extends StatelessWidget {
  final double scrollingRate;
  const CouponViewWidget({super.key, required this.scrollingRate});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    // Theme Colors
    const Color orangeLight = Color(0xFFFFB74D);
    const Color orangeMain = Color(0xFFF57C00);

    return GetBuilder<CouponController>(
      builder: (couponController) {
        return couponController.couponList != null && couponController.couponList!.isNotEmpty
            ? Opacity(
          // Fades out the widget as the user scrolls up (scrollingRate increases)
          opacity: (1 - scrollingRate).clamp(0.0, 1.0),
          child: Column(
            children: [
              SizedBox(
                // Dynamic Height: Shrinks from ~85 down to ~65 based on scroll
                height: isDesktop ? 120 : (85 - (scrollingRate * 20)).clamp(0.0, 85.0),
                width: double.infinity,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    disableCenter: true,
                    viewportFraction: 0.95,
                    autoPlayInterval: const Duration(seconds: 7),
                    onPageChanged: (index, reason) {
                      couponController.setCurrentIndex(index, true);
                    },
                  ),
                  itemCount: couponController.couponList!.length,
                  itemBuilder: (context, index, _) {
                    return Container(
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        gradient: const LinearGradient(
                          colors: [orangeLight, orangeMain],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: orangeMain.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown, // Ensures content scales if height shrinks
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 90,
                          child: Row(
                            children: [
                              // --- 1. Left Side: Icon ---
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  height: 60, width: 60,
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Image.asset(
                                    Images.restaurantCoupon,
                                    // color: Colors.white,
                                  ),
                                ),
                              ),

                              // --- 2. Middle: Details ---
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      couponController.couponList![index].title ?? '',
                                      style: robotoBold.copyWith(fontSize: 16, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${'min_purchase'.tr}: ${PriceConverter.convertPrice(couponController.couponList![index].minPurchase)}',
                                      style: robotoRegular.copyWith(fontSize: 13, color: Colors.white.withValues(alpha: 1)),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      '${'valid_until'.tr} ${DateConverter.stringToReadableString(couponController.couponList![index].expireDate!)}',
                                      style: robotoRegular.copyWith(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),

                              // --- 3. Dotted Line ---
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: CustomPaint(
                                  size: const Size(1, double.infinity),
                                  painter: DashedLinePainter(),
                                ),
                              ),

                              // --- 4. Right Side: Copy Button ---
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: couponController.couponList![index].code!));
                                  showCustomSnackBar('coupon_code_copied'.tr, isError: false);
                                },
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.copy_rounded, color: Colors.white, size: 22),
                                      const SizedBox(height: 3),
                                      Text("USE CODE", style: robotoBold.copyWith(fontSize: 12, color: Colors.white)),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          couponController.couponList![index].code!,
                                          style: robotoBlack.copyWith(color: orangeMain, fontSize: 10),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Indicator Dots
              const SizedBox(height: 5),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: couponController.couponList!.map((bnr) {
              //     int index = couponController.couponList!.indexOf(bnr);
              //     return TabPageSelectorIndicator(
              //       backgroundColor: index == couponController.currentIndex
              //           ? orangeMain
              //           : orangeLight.withValues(alpha: 0.4),
              //       borderColor: Colors.transparent,
              //       size: index == couponController.currentIndex ? 7 : 5,
              //     );
              //   }).toList(),
              // ),
            ],
          ),
        )
            : const SizedBox();
      },
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
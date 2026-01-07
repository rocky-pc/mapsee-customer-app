import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/home/widgets/bad_weather_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/snowfall_animation_widget.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class SwiggyHeaderWidget extends StatelessWidget {
  final bool showIcon; // Controls if the static icon is visible
  const SwiggyHeaderWidget({super.key, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      decoration: BoxDecoration(
        color: Color(0xFFFD531F),
        borderRadius: const BorderRadius.only(
          // bottomLeft: Radius.circular(Dimensions.radiusExtraLarge),
          // bottomRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: Stack(
        children: [

          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                // bottomLeft: Radius.circular(Dimensions.radiusExtraLarge),
                // bottomRight: Radius.circular(Dimensions.radiusExtraLarge),
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxHeight.isFinite && constraints.maxHeight > 0) {
                  return IgnorePointer(
                    ignoring: true,
                    child: SnowfallAnimationWidget(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: Dimensions.paddingSizeSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                    child: Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      child: GetBuilder<LocationController>(builder: (locationController) {
                        String fullAddress = AuthHelper.isLoggedIn() &&
                            AddressHelper.getAddressFromSharedPref() != null
                            ? AddressHelper.getAddressFromSharedPref()!.address!
                            : 'your_location'.tr;

                        List<String> addressParts = fullAddress.split(',');
                        String displayTitle = addressParts.isNotEmpty ? addressParts[0].trim() : 'Unknown';
                        if (addressParts.length >= 2) {
                          displayTitle = addressParts[1].trim();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: showIcon ? 1.0 : 0.0,
                                  child: Icon(
                                      CupertinoIcons.location_fill,
                                      size: 18,
                                      color: Theme.of(context).cardColor
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Flexible(
                                  child: Text(
                                    displayTitle,
                                    style: robotoMedium.copyWith(
                                        color: Theme.of(context).cardColor,
                                        fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down,
                                    size: 20, color: Theme.of(context).cardColor),
                              ],
                            ),
                            Text(
                              fullAddress,
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).cardColor.withOpacity(0.8),
                                  fontSize: Dimensions.fontSizeExtraSmall),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const BadWeatherWidget(),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getProfileRoute()),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_sharp,
                            size: 25, color: Color(0xFFFD531F)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SwiggySearchBarWidget extends StatelessWidget {
  final TextEditingController searchTextEditingController;
  const SwiggySearchBarWidget({super.key, required this.searchTextEditingController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      color: Color(0xFFFD531F),
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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
                    child: ClipRect(
                      child: const RollingSearchText(),
                    ),
                  ),

                  Container(
                    height: 20,
                    width: 1.3,
                    color: Colors.grey.shade400,
                    margin: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeExtraSmall),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Get.toNamed(RouteHelper.getSearchRoute(), arguments: 'voice');
                    },
                    icon: Icon(
                      Icons.mic_rounded,
                      size: 26,
                      color: Color(0xFFFD531F),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          InkWell(
            onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.2),
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
                  color: Theme.of(context).cardColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RollingSearchText extends StatefulWidget {
  const RollingSearchText({super.key});

  @override
  State<RollingSearchText> createState() => _RollingSearchTextState();
}

class _RollingSearchTextState extends State<RollingSearchText> {
  int _index = 0;
  late Timer _timer;

  final List<String> _suggestions = [
    'Sweets',
    'Burgers',
    'Pizza',
    'Cakes',
    'Gravy'
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _suggestions.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${'Search for'.tr} ',
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).hintColor,
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: const Offset(0.0, 0.0),
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Text(
              '\'${_suggestions[_index]}\''.tr,
              key: ValueKey(_suggestions[_index]),
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).hintColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class SwiggySliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  SwiggySliverDelegate({required this.child, this.height = 50});

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

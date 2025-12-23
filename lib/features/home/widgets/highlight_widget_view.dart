import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/models/advertisement_model.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:video_player/video_player.dart';

class HighlightWidgetView extends StatefulWidget {
  const HighlightWidgetView({super.key});

  @override
  State<HighlightWidgetView> createState() => _HighlightWidgetViewState();
}

class _HighlightWidgetViewState extends State<HighlightWidgetView> {
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      return advertisementController.advertisementList != null && advertisementController.advertisementList!.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.only(
          top: Dimensions.paddingSizeDefault,
          bottom: Dimensions.paddingSizeDefault,
        ),
        child: Stack(
          children: [
            // --- 1. Background (Height Reduced) ---
            SizedBox(
              width: context.width,
              // Reduced height significantly (was 360)
              height: ResponsiveHelper.isMobile(context) ? 280 : 350,
              child: CustomAssetImageWidget(
                Images.highlightBg,
                width: context.width,
                fit: BoxFit.cover,
              ),
            ),

            // --- 2. Foreground Content ---
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'highlights_for_you'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge + 2,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'see_our_most_popular_restaurant_and_foods'.tr,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ],
                      ),
                      const CustomAssetImageWidget(
                        Images.highlightIcon,
                        height: 45, // Slightly smaller icon
                        width: 45,
                      ),
                    ],
                  ),
                ),

                CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: advertisementController.advertisementList!.length,
                  options: CarouselOptions(
                    enableInfiniteScroll: advertisementController.advertisementList!.length > 2,
                    autoPlay: advertisementController.autoPlay,
                    enlargeCenterPage: true,
                    // Reduced Height (was 260)
                    height: 190,
                    viewportFraction: 0.92,
                    disableCenter: true,
                    onPageChanged: (index, reason) {
                      advertisementController.setCurrentIndex(index, true);
                      if (advertisementController.advertisementList?[index].addType == "video_promotion") {
                        advertisementController.updateAutoPlayStatus(status: false);
                      } else {
                        advertisementController.updateAutoPlayStatus(status: true);
                      }
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return advertisementController.advertisementList?[index].addType == 'video_promotion'
                        ? HighlightVideoWidget(
                      advertisement: advertisementController.advertisementList![index],
                    )
                        : HighlightRestaurantWidget(
                      advertisement: advertisementController.advertisementList![index],
                    );
                  },
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),
                // const AdvertisementIndicator(),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ],
            ),
          ],
        ),
      )
          : advertisementController.advertisementList == null
          ? const AdvertisementShimmer()
          : const SizedBox();
    });
  }
}

class HighlightRestaurantWidget extends StatelessWidget {
  final AdvertisementModel advertisement;
  const HighlightRestaurantWidget({super.key, required this.advertisement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            RouteHelper.getRestaurantRoute(advertisement.restaurantId),
            arguments: RestaurantScreen(restaurant: Restaurant(id: advertisement.restaurantId)),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              CustomImageWidget(
                image: advertisement.coverImageFullUrl ?? '',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                      stops: const [0.3, 0.6, 1],
                    ),
                  ),
                ),
              ),

              // Top Section: Profile + Fav
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: CustomImageWidget(
                          image: advertisement.profileImageFullUrl ?? '',
                          height: 32, // Smaller profile pic
                          width: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(5),
                      child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                        bool isWished = favouriteController.wishRestIdList.contains(advertisement.restaurantId);
                        return CustomFavouriteWidget(
                          isWished: isWished,
                          isRestaurant: true,
                          restaurantId: advertisement.restaurantId,
                          size: 18,
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Bottom Section: Text Left + Rating Right
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text Column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10), // Space between text and rating
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              advertisement.title ?? '',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              advertisement.description ?? '',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Rating Pill (Bottom Right)
                    if (advertisement.isRatingActive == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              '${advertisement.averageRating?.toStringAsFixed(1)}',
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HighlightVideoWidget extends StatefulWidget {
  final AdvertisementModel advertisement;
  const HighlightVideoWidget({super.key, required this.advertisement});

  @override
  State<HighlightVideoWidget> createState() => _HighlightVideoWidgetState();
}

class _HighlightVideoWidgetState extends State<HighlightVideoWidget> {
  late VideoPlayerController videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.duration == videoPlayerController.value.position) {
        if (GetPlatform.isWeb) {
          Future.delayed(const Duration(seconds: 4), () {
            Get.find<AdvertisementController>().updateAutoPlayStatus(status: true, shouldUpdate: true);
          });
        } else {
          Get.find<AdvertisementController>().updateAutoPlayStatus(status: true, shouldUpdate: true);
        }
      }
    });
  }

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
      widget.advertisement.videoAttachmentFullUrl ?? "",
    ));
    await Future.wait([videoPlayerController.initialize()]);
    _createChewieController();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() {});
    });
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      aspectRatio: videoPlayerController.value.aspectRatio,
      showControls: false,
      looping: true,
    );
    _chewieController?.setVolume(0);
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Center(
                child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : const CircularProgressIndicator(color: Colors.white),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                      stops: const [0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "PROMO",
                              style: robotoBold.copyWith(fontSize: 9, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.advertisement.title ?? '',
                            style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w700, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Get.toNamed(
                          RouteHelper.getRestaurantRoute(widget.advertisement.restaurantId),
                          arguments: RestaurantScreen(restaurant: Restaurant(id: widget.advertisement.restaurantId)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class AdvertisementIndicator extends StatelessWidget {
  const AdvertisementIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      if (advertisementController.advertisementList == null || advertisementController.advertisementList!.isEmpty) {
        return const SizedBox();
      }
      return Align(
        alignment: Alignment.center,
        child: AnimatedSmoothIndicator(
          activeIndex: advertisementController.currentIndex,
          count: advertisementController.advertisementList!.length,
          effect: ExpandingDotsEffect(
            dotHeight: 3,
            dotWidth: 5,
            spacing: 5,
            activeDotColor: Theme.of(context).primaryColor,
            dotColor: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            expansionFactor: 3,
          ),
        ),
      );
    });
  }
}

class AdvertisementShimmer extends StatelessWidget {
  const AdvertisementShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.05),
        ),
        margin: EdgeInsets.only(
          top: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge * 3.5 : 0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Container(
                height: 20,
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).shadowColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Container(
                height: 15,
                width: 250,
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).shadowColor,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault * 2),
              SizedBox(
                height: 190, // Updated Shimmer height to match new design
                child: ListView.builder(
                  itemCount: 3,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (context, index) {
                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context).shadowColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
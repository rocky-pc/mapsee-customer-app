import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_info_section_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_screen_shimmer_widget.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/bottom_cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/veg_filter_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant? restaurant;
  final String slug;
  final bool fromDineIn;
  const RestaurantScreen({super.key, required this.restaurant, this.slug = '', this.fromDineIn = false});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDataCall();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initDataCall() async {
    if(Get.find<RestaurantController>().isSearching) {
      Get.find<RestaurantController>().changeSearchStatus(isUpdate: false);
    }
    await Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: widget.restaurant!.id), slug: widget.slug);
    if (Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true, search: '');
    }
    Get.find<CouponController>().getRestaurantCouponList(
        restaurantId: widget.restaurant!.id ?? Get.find<RestaurantController>().restaurant!.id!);
    Get.find<RestaurantController>().getRestaurantRecommendedItemList(
        widget.restaurant!.id ?? Get.find<RestaurantController>().restaurant!.id!, false);
    Get.find<RestaurantController>().getRestaurantProductList(
        widget.restaurant!.id ?? Get.find<RestaurantController>().restaurant!.id!, 1, 'all', false);
  }

  // Photo Frame Decoration - same as WhatOnYourMindViewWidget
  BoxDecoration _photoFrameDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(100),
      boxShadow: [
        BoxShadow(
          color: Colors.deepOrange.withOpacity(0.5),
          blurRadius: 10,
          offset: const Offset(0, 1),
          spreadRadius: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: isDesktop ? WebMenuBar(fromDineIn: widget.fromDineIn) : null,
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return GetBuilder<CouponController>(builder: (couponController) {
          return GetBuilder<CategoryController>(builder: (categoryController) {
            Restaurant? restaurant;
            if (restController.restaurant != null &&
                restController.restaurant!.name != null &&
                categoryController.categoryList != null) {
              restaurant = restController.restaurant;
            }
            restController.setCategoryList();
            bool hasCoupon = couponController.couponList != null && couponController.couponList!.isNotEmpty;

            return (restController.restaurant != null &&
                restController.restaurant!.name != null &&
                categoryController.categoryList != null)
                ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              slivers: [
                RestaurantInfoSectionWidget(
                    restaurant: restaurant!, restController: restController, hasCoupon: hasCoupon),

                // Discount + Announcement + Recommended (unchanged)
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      width: Dimensions.webMaxWidth,
                      color: Theme.of(context).cardColor,
                      child: Column(children: [
                        // ... Discount Banner, Announcement, Recommended Items (unchanged - omitted for brevity)
                        // Keep your original code here
                      ]),
                    ),
                  ),
                ),

                // Category Tabs - "All" = Text Only, Others = Image + Text
                if (restController.categoryList!.isNotEmpty)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverDelegate(
                      height: 160,
                      child: Container(
                        color: Theme.of(context).cardColor,
                        child: Column(children: [
                          // Search + Filter Row
                          Padding(
                            padding: const EdgeInsets.only(
                                left: Dimensions.paddingSizeDefault,
                                right: Dimensions.paddingSizeDefault,
                                top: Dimensions.paddingSizeSmall),
                            child: Row(children: [
                              Text('all_food_items'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                              const Expanded(child: SizedBox()),
                              if (isDesktop)
                                Container(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  height: 35,
                                  width: 320,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Theme.of(context).cardColor,
                                    border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      hintText: 'search_for_your_food'.tr,
                                      hintStyle: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).disabledColor),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          borderSide: BorderSide.none),
                                      filled: true,
                                      fillColor: Theme.of(context).cardColor,
                                      isDense: true,
                                      prefixIcon: InkWell(
                                        onTap: () {
                                          if (!restController.isSearching) {
                                            Get.find<RestaurantController>().getRestaurantSearchProductList(
                                              _searchController.text.trim(),
                                              restController.restaurant!.id.toString(),
                                              1,
                                              restController.type,
                                            );
                                          } else {
                                            _searchController.clear();
                                            restController.initSearchData();
                                            restController.changeSearchStatus();
                                          }
                                        },
                                        child: Icon(
                                            restController.isSearching ? Icons.clear : CupertinoIcons.search,
                                            color: Theme.of(context).primaryColor.withOpacity(0.5)),
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      if (value.isNotEmpty) {
                                        restController.getRestaurantSearchProductList(
                                          value.trim(),
                                          restController.restaurant!.id.toString(),
                                          1,
                                          restController.type,
                                        );
                                      }
                                    },
                                  ),
                                )
                              else
                                InkWell(
                                  onTap: () async {
                                    await Get.toNamed(RouteHelper.getSearchRestaurantProductRoute(restaurant!.id));
                                    if (restController.isSearching) restController.changeSearchStatus();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    ),
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall - 2),
                                    child: Image.asset(Images.search,
                                        height: 18, width: 18, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              if (restController.type.isNotEmpty)
                                VegFilterWidget(
                                  type: restController.type,
                                  iconColor: Theme.of(context).primaryColor,
                                  onSelected: (String type) {
                                    restController.getRestaurantProductList(restController.restaurant!.id, 1, type, true);
                                  },
                                ),
                            ]),
                          ),
                          const Divider(thickness: 0.2, height: 10),

                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                              physics: const BouncingScrollPhysics(),
                              itemCount: restController.categoryList!.length,
                              itemBuilder: (context, index) {
                                final category = restController.categoryList![index];
                                final bool isSelected = index == restController.categoryIndex;
                                const double imageSize = 30; // Consistent height reference

                                // 1. "ALL" CATEGORY REDESIGN
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // This InkWell now only wraps the "Text Box" area
                                        InkWell(
                                          onTap: () => restController.setCategoryIndex(index),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          child: Container(
                                            height: imageSize, // Match the height of the other categories' images
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                              border: Border.all(
                                                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                category.name!,
                                                style: robotoMedium.copyWith(
                                                  fontSize: Dimensions.fontSizeSmall,
                                                  color: isSelected
                                                      ? Theme.of(context).primaryColor
                                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Empty space at bottom to maintain alignment with other category labels
                                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                        const SizedBox(height: 10), // Placeholder for the missing label height
                                      ],
                                    ),
                                  );
                                }

                                // 2. OTHER CATEGORIES
                                return InkWell(
                                  onTap: () => restController.setCategoryIndex(index),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: Dimensions.paddingSizeDefault,
                                      top: 3,
                                      bottom: 3,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          // padding: const EdgeInsets.all(4),
                                          decoration: isSelected
                                              ? _photoFrameDecoration(context)
                                              : BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(100),
                                            child: CustomImageWidget(
                                              image: category.imageFullUrl ?? '',
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                        SizedBox(
                                          width: imageSize + 30,
                                          child: Text(
                                            category.name!,
                                            style: robotoMedium.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: isSelected
                                                  ? Theme.of(context).primaryColor
                                                  : Theme.of(context).textTheme.bodyLarge?.color,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),

                // Product List (unchanged)
                SliverToBoxAdapter(
                  child: FooterViewWidget(
                    child: Center(
                      child: Container(
                        width: Dimensions.webMaxWidth,
                        child: PaginatedListViewWidget(
                          scrollController: scrollController,
                          onPaginate: (int? offset) {
                            if (restController.isSearching) {
                              restController.getRestaurantSearchProductList(
                                restController.searchText,
                                restController.restaurant!.id.toString(),
                                offset!,
                                restController.type,
                              );
                            } else {
                              restController.getRestaurantProductList(
                                  restController.restaurant!.id, offset!, restController.type, false);
                            }
                          },
                          totalSize: restController.isSearching
                              ? restController.restaurantSearchProductModel?.totalSize
                              : restController.restaurantProducts != null
                              ? restController.foodPageSize
                              : null,
                          offset: restController.isSearching
                              ? restController.restaurantSearchProductModel?.offset
                              : restController.restaurantProducts != null
                              ? restController.foodPageOffset
                              : null,
                          productView: ProductViewWidget(
                            isRestaurant: false,
                            restaurants: null,
                            products: restController.isSearching
                                ? restController.restaurantSearchProductModel?.products
                                : restController.categoryList!.isNotEmpty
                                ? restController.restaurantProducts
                                : null,
                            inRestaurantPage: true,
                            showDiscount: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
                : const RestaurantScreenShimmerWidget();
          });
        });
      }),

      bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
        return cartController.cartList.isNotEmpty && !isDesktop
            ? BottomCartWidget(
          restaurantId: cartController.cartList[0].product!.restaurantId!,
          fromDineIn: widget.fromDineIn,
        )
            : const SizedBox();
      }),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
class AllRestaurantsWidget extends StatelessWidget {
  final ScrollController scrollController;
  const AllRestaurantsWidget({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurantController) {

      List<Restaurant>? restaurantList = restaurantController.restaurantModel?.restaurants;

      if (restaurantList != null) {
        final restController = Get.find<RestaurantController>();
        restaurantList = restaurantList.where((restaurant) {
          if(restaurant.latitude != null && restaurant.longitude != null) {
            try {
              double distance = restController.getRestaurantDistance(LatLng(
                double.parse(restaurant.latitude!),
                double.parse(restaurant.longitude!),
              ));
              return distance <= AppConstants.restaurantActiveDistance;
            } catch (e) {
              return false;
            }
          }
          return false;
        }).toList();
      }

      return PaginatedListViewWidget(
        scrollController: scrollController,
        totalSize: restaurantList?.length,
        offset: restaurantController.restaurantModel?.offset,
        onPaginate: (int? offset) async => await restaurantController.getRestaurantList(offset!, false),
        productView: RestaurantsViewWidget(restaurants: restaurantList),
      );
    });
  }
}

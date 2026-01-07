import 'dart:convert';

import 'package:stackfood_multivendor/api/local_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:stackfood_multivendor/features/restaurant/domain/repositories/restaurant_repository_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantRepository implements RestaurantRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  RestaurantRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<RecommendedProductModel?> getRestaurantRecommendedItemList(int? restaurantId) async {
    RecommendedProductModel? recommendedProductModel;
    Response response = await apiClient.getData('${AppConstants.restaurantRecommendedItemUri}?restaurant_id=$restaurantId&offset=1&limit=50');
    if (response.statusCode == 200) {
      recommendedProductModel = RecommendedProductModel.fromJson(response.body);
    }
    return recommendedProductModel;
  }

  @override
  Future<List<Product>?> getCartRestaurantSuggestedItemList(int? restaurantID) async {
    List<Product>? suggestedItems;
    Response response = await apiClient.getData('${AppConstants.cartRestaurantSuggestedItemsUri}?restaurant_id=$restaurantID');
    if (response.statusCode == 200) {
      suggestedItems =  [];
      response.body.forEach((product) {
        suggestedItems!.add(Product.fromJson(product));
      });
    }
    return suggestedItems;
  }

  @override
  Future<ProductModel?> getRestaurantProductList(int? restaurantID, int offset, int? categoryID, String type) async {
    ProductModel? productModel;
    Response response = await apiClient.getData(
      '${AppConstants.restaurantProductUri}?restaurant_id=$restaurantID&category_id=$categoryID&offset=$offset&limit=12&type=$type',
    );
    if (response.statusCode == 200) {
      productModel = ProductModel.fromJson(response.body);
    }
    return productModel;
  }

  @override
  Future<ProductModel?> getRestaurantSearchProductList(String searchText, String? storeID, int offset, String type) async {
    ProductModel? restaurantSearchProductModel;
    Response response = await apiClient.getData(
      '${AppConstants.searchUri}products/search?restaurant_id=$storeID&name=$searchText&offset=$offset&limit=10&type=$type',
    );
    if (response.statusCode == 200) {
      restaurantSearchProductModel = ProductModel.fromJson(response.body);
    }
    return restaurantSearchProductModel;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Restaurant?> get(String? id, {String slug = '', String? languageCode}) async {
    return await _getRestaurantDetails(id!, slug, languageCode);
  }

  Future<Restaurant?> _getRestaurantDetails(String restaurantID, String slug, String? languageCode) async {
    Restaurant? restaurant;
    Map<String, String>? header;
    if(slug.isNotEmpty){
      header = apiClient.updateHeader(
        sharedPreferences.getString(AppConstants.token), [],
        languageCode, '', '', setHeader: false,
      );
    }
    Response response = await apiClient.getData('${AppConstants.restaurantDetailsUri}${slug.isNotEmpty ? slug : restaurantID}', headers: header);
    if (response.statusCode == 200) {
      restaurant = Restaurant.fromJson(response.body);
    }
    return restaurant;
  }

  @override
  Future<RestaurantModel?> getList({int? offset, String? filterBy, int? topRated, int? discount, int? veg, int? nonVeg, bool fromMap = false, double? pinLat, double? pinLng, int? radius, DataSourceEnum? source}) async {
    RestaurantModel? restaurantModel;
    // Include pin coordinates and radius in cache key when available to avoid serving stale cached results for different pin locations
    String cacheId = AppConstants.restaurantUri + ((fromMap && pinLat != null && pinLng != null) ? '_pin_${pinLat.toStringAsFixed(6)}_${pinLng.toStringAsFixed(6)}_${(radius ?? 12000)}' : '');
    switch(source!) {
      case DataSourceEnum.client:
        String uri = '${AppConstants.restaurantUri}/all?offset=$offset&limit=${fromMap ? 20 : 12}&filter_data=$filterBy&top_rated=$topRated&discount=$discount&veg=$veg&non_veg=$nonVeg';
        Map<String, String>? headers;
        if(fromMap) {
          uri = uri + '&pin=1';
          try {
            // Prefer provided pin coordinates, fallback to saved address
            if(pinLat != null && pinLng != null) {
              headers = Map<String, String>.from(apiClient.getHeader());
              headers['pin_lat'] = pinLat.toString();
              headers['pin_lng'] = pinLng.toString();
              headers['radius'] = (radius ?? 12000).toString();
            } else {
              final address = AddressHelper.getAddressFromSharedPref();
              if(address != null) {
                headers = Map<String, String>.from(apiClient.getHeader());
                headers['pin_lat'] = address.latitude ?? '';
                headers['pin_lng'] = address.longitude ?? '';
                headers['radius'] = (radius ?? 12000).toString();
              }
            }
          } catch (_) {}
        }

        Response response = await apiClient.getData(uri, headers: headers);
        if(response.statusCode == 200){
          restaurantModel = RestaurantModel.fromJson(response.body);
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), headers ?? apiClient.getHeader());
        }
        break;
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          restaurantModel = RestaurantModel.fromJson(jsonDecode(cacheResponseData));
        }
        break;
    }
    return restaurantModel;
  }

  @override
  Future<List<Restaurant>?> getRestaurantList({String? type, bool isRecentlyViewed = false, bool isOrderAgain = false, bool isPopular = false, bool isLatest = false, DataSourceEnum? source, double? pinLat, double? pinLng, int? radius}) async {
    if(isRecentlyViewed) {
      return _getRecentlyViewedRestaurantList(type!, source: source);
    } else if(isOrderAgain) {
      return _getOrderAgainRestaurantList(source: source);
    } else if(isPopular) {
      return _getPopularRestaurantList(type!, source: source, pinLat: pinLat, pinLng: pinLng, radius: radius);
    } else if(isLatest) {
      return _getLatestRestaurantList(type!, source: source, pinLat: pinLat, pinLng: pinLng, radius: radius);
    }
    return null;
  }

  Future<List<Restaurant>?> _getLatestRestaurantList(String type, {DataSourceEnum? source, double? pinLat, double? pinLng, int? radius}) async {
    List<Restaurant>? latestRestaurantList;
    String cacheId = AppConstants.latestRestaurantUri + ((pinLat != null && pinLng != null) ? '_pin_${pinLat.toStringAsFixed(6)}_${pinLng.toStringAsFixed(6)}_${(radius ?? 12000)}' : '');
    switch(source!) {
      case DataSourceEnum.client:
        String uri = '${AppConstants.latestRestaurantUri}?type=$type';
        Map<String, String>? headers;
        if(pinLat != null && pinLng != null) {
          uri = uri + '&pin=1';
          headers = Map<String, String>.from(apiClient.getHeader());
          headers['pin_lat'] = pinLat.toString();
          headers['pin_lng'] = pinLng.toString();
          headers['radius'] = (radius ?? 12000).toString();
        }
        Response response = await apiClient.getData(uri, headers: headers);
        if(response.statusCode == 200){
          latestRestaurantList = [];
          response.body.forEach((restaurant) {
            latestRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), headers ?? apiClient.getHeader());
        }
        break;
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          latestRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            latestRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
        break;
    }
    return latestRestaurantList;
  }

  Future<List<Restaurant>?> _getPopularRestaurantList(String type, {DataSourceEnum? source, double? pinLat, double? pinLng, int? radius}) async {
    List<Restaurant>? popularRestaurantList;
    String cacheId = AppConstants.popularRestaurantUri + ((pinLat != null && pinLng != null) ? '_pin_${pinLat.toStringAsFixed(6)}_${pinLng.toStringAsFixed(6)}_${(radius ?? 12000)}' : '');
    switch(source!) {
      case DataSourceEnum.client:
        String uri = '${AppConstants.popularRestaurantUri}?type=$type';
        Map<String, String>? headers;
        if(pinLat != null && pinLng != null) {
          uri = uri + '&pin=1';
          headers = Map<String, String>.from(apiClient.getHeader());
          headers['pin_lat'] = pinLat.toString();
          headers['pin_lng'] = pinLng.toString();
          headers['radius'] = (radius ?? 12000).toString();
        }
        Response response = await apiClient.getData(uri, headers: headers);
        if(response.statusCode == 200){
          popularRestaurantList = [];
          response.body.forEach((restaurant) {
            popularRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), headers ?? apiClient.getHeader());
        }
        break;
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          popularRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            popularRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
        break;
    }

    return popularRestaurantList;
  }

  Future<List<Restaurant>?> _getRecentlyViewedRestaurantList(String type, {DataSourceEnum? source}) async {
    List<Restaurant>? recentlyViewedRestaurantList;
    String cacheId = AppConstants.recentlyViewedRestaurantUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData('${AppConstants.recentlyViewedRestaurantUri}?type=$type');
        if(response.statusCode == 200){
          recentlyViewedRestaurantList = [];
          response.body.forEach((restaurant) {
            recentlyViewedRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          recentlyViewedRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            recentlyViewedRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }
    return recentlyViewedRestaurantList;
  }

  Future<List<Restaurant>?> _getOrderAgainRestaurantList({DataSourceEnum? source}) async {
    List<Restaurant>? orderAgainRestaurantList;
    String cacheId = AppConstants.orderAgainUri;

    switch(source!){
      case DataSourceEnum.client:
        Response response = await apiClient.getData(AppConstants.orderAgainUri);
        if(response.statusCode == 200){
          orderAgainRestaurantList = [];
          response.body.forEach((restaurant) {
            orderAgainRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
          LocalClient.organize(DataSourceEnum.client, cacheId, jsonEncode(response.body), apiClient.getHeader());
        }
      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(DataSourceEnum.local, cacheId, null, null);
        if(cacheResponseData != null) {
          orderAgainRestaurantList = [];
          jsonDecode(cacheResponseData).forEach((restaurant) {
            orderAgainRestaurantList!.add(Restaurant.fromJson(restaurant));
          });
        }
    }
    return orderAgainRestaurantList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }


}
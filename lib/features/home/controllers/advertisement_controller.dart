import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/home/domain/models/advertisement_model.dart';
import 'package:stackfood_multivendor/features/home/domain/services/advertisement_service_interface.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

class AdvertisementController extends GetxController implements GetxService {
  final AdvertisementServiceInterface advertisementServiceInterface;
  AdvertisementController({required this.advertisementServiceInterface});

  List<AdvertisementModel>? _advertisementList;
  List<AdvertisementModel>? get advertisementList => _advertisementList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Duration autoPlayDuration = const Duration(seconds: 7);

  bool autoPlay = true;

  Future<void> getAdvertisementList({DataSourceEnum dataSource = DataSourceEnum.local, bool fromRecall = false}) async {
    if(!fromRecall) {
      _advertisementList = null;
    }
    List<AdvertisementModel>? advertisementList;
    if(dataSource == DataSourceEnum.local) {
      advertisementList = await advertisementServiceInterface.getAdvertisementList(source: DataSourceEnum.local);
      _prepareAdvertisement(advertisementList);
      getAdvertisementList(dataSource: DataSourceEnum.client, fromRecall: true);
    } else {
      advertisementList = await advertisementServiceInterface.getAdvertisementList(source: DataSourceEnum.client);
      _prepareAdvertisement(advertisementList);
    }
  }

  void _prepareAdvertisement(List<AdvertisementModel>? advertisementList) {
    if (advertisementList != null) {
      _advertisementList = [];
      final restController = Get.find<RestaurantController>();
      for (var advertisement in advertisementList) {
        if(advertisement.restaurantLatitude != null && advertisement.restaurantLongitude != null) {
          try {
            double distance = restController.getRestaurantDistance(LatLng(
              double.parse(advertisement.restaurantLatitude!),
              double.parse(advertisement.restaurantLongitude!),
            ));
            if (distance <= AppConstants.restaurantActiveDistance) {
              _advertisementList!.add(advertisement);
            }
          } catch (e) {
            //ignore
          }
        }
      }
    }
    update();
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if(notify) {
      update();
    }
  }

  void updateAutoPlayStatus({bool shouldUpdate = false, bool status = false}){
    autoPlay = status;
    if(shouldUpdate){
      update();
    }
  }

}

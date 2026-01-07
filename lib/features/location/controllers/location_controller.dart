import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/location/domain/models/prediction_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/location/domain/services/location_service_interface.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:video_player/video_player.dart';

class LocationController extends GetxController implements GetxService {
  final LocationServiceInterface locationServiceInterface;

  LocationController({required this.locationServiceInterface});

  VideoPlayerController? _videoController;
  VideoPlayerController? get videoController => _videoController;

  bool _isVideoInitialized = false;
  bool get isVideoInitialized => _isVideoInitialized;

  Position _position = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
  Position get position => _position;

  Position _pickPosition = Position(longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
  Position get pickPosition => _pickPosition;

  bool _loading = false;
  bool get loading => _loading;

  String? _address = '';
  String? get address => _address;

  String? _pickAddress = '';
  String? get pickAddress => _pickAddress;

  int _addressTypeIndex = 0;
  int get addressTypeIndex => _addressTypeIndex;

  final List<String?> _addressTypeList = ['home', 'office', 'others'];
  List<String?> get addressTypeList => _addressTypeList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _inZone = false;
  bool get inZone => _inZone;

  int _zoneID = 0;
  int get zoneID => _zoneID;

  bool _buttonDisabled = true;
  bool get buttonDisabled => _buttonDisabled;

  GoogleMapController? _mapController;
  GoogleMapController? get mapController => _mapController;

  List<PredictionModel> _predictionList = [];
  List<PredictionModel> get predictionList => _predictionList;

  bool _updateAddressData = true;
  bool _changeAddress = true;

  bool _isCameraMoving = false;
  bool get isCameraMoving => _isCameraMoving;

  String? _weatherIconUrl;
  String? get weatherIconUrl => _weatherIconUrl;

  int _choosePreferredZoneId(ZoneResponseModel responseModel) {
    for (final z in responseModel.zoneData) {
      if (z.id != null &&
          z.increasedDeliveryFeeStatus == 1 &&
          (z.increaseDeliveryFeeMessage?.isNotEmpty ?? false)) {
        return z.id!;
      }
    }
    return responseModel.zoneIds.isNotEmpty ? responseModel.zoneIds[0] : 0;
  }

  String? _sanitizeIconUrl(String? url) {
    if (url == null) return null;
    String cleaned = url.trim();
    if (cleaned.endsWith(',')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    if (cleaned.contains('traffic.png')) {
      return 'https://mapsee.co.in/icons/traffic.png';
    }
    if (cleaned.contains('rush-hours.png')) {
      return 'https://mapsee.co.in/icons/rush-hours.png';
    }
    if (cleaned.contains('rain.png')) {
      return 'https://mapsee.co.in/icons/rain.png';
    }
    return cleaned;
  }

  @override
  void onInit() {
    super.onInit();
    _loadInitialWeather();
    _initializeVideo();
  }

  @override
  void onClose() {
    _videoController?.dispose();
    super.onClose();
  }

  void _loadInitialWeather() {
    AddressModel? address = AddressHelper.getAddressFromSharedPref();
    if (address != null && address.zoneData != null) {
      final zoneData = address.zoneData!.firstWhereOrNull(
            (data) =>
        data.id == address.zoneId &&
            data.increasedDeliveryFeeStatus == 1 &&
            data.increaseDeliveryFeeMessage?.isNotEmpty == true,
      );
      _weatherIconUrl = _sanitizeIconUrl(zoneData?.icon);
    }
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset('assets/image/video.mp4')
      ..initialize().then((_) {
        _videoController?.setLooping(true);
        _videoController?.setVolume(0);
        _isVideoInitialized = true;
        if(_weatherIconUrl == 'https://mapsee.co.in/icons/rain.png') {
          _videoController?.play();
        }
        update();
      });
  }

  void updateCameraMovingStatus(bool status) {
    _isCameraMoving = status;
    update();
  }

  Future<AddressModel> getCurrentLocation(bool fromAddress, {GoogleMapController? mapController, LatLng? defaultLatLng, bool notify = true, bool showSnackBar = false}) async {
    _loading = true;
    if (notify) {
      update();
    }
    AddressModel addressModel;
    Position myPosition = await locationServiceInterface.getPosition(
      defaultLatLng,
      LatLng(
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
      ),
    );
    fromAddress ? _position = myPosition : _pickPosition = myPosition;

    locationServiceInterface.handleMapAnimation(mapController, myPosition);
    String addressFromGeocode = await getAddressFromGeocode(LatLng(myPosition.latitude, myPosition.longitude));
    fromAddress ? _address = addressFromGeocode : _pickAddress = addressFromGeocode;
    ZoneResponseModel responseModel = await getZone(myPosition.latitude.toString(), myPosition.longitude.toString(), true, showSnackBar: showSnackBar);
    _buttonDisabled = !responseModel.isSuccess;
    final selectedZoneId = _choosePreferredZoneId(responseModel);
    _zoneID = selectedZoneId;
    addressModel = AddressModel(
      latitude: myPosition.latitude.toString(),
      longitude: myPosition.longitude.toString(),
      addressType: 'others',
      zoneId: responseModel.isSuccess ? selectedZoneId : 0,
      zoneIds: responseModel.zoneIds,
      address: addressFromGeocode,
      zoneData: responseModel.zoneData,
    );
    _loading = false;
    update();
    return addressModel;
  }

  Future<ZoneResponseModel> getZone(String? lat, String? long, bool markerLoad, {bool updateInAddress = false, bool showSnackBar = false}) async {
    if (markerLoad) {
      _loading = true;
    } else {
      _isLoading = true;
    }
    if (!updateInAddress) {
      Future.delayed(const Duration(seconds: 10), () {
        update();
      });
    }
    ZoneResponseModel responseModel = await locationServiceInterface.getZone(lat, long);
    _inZone = responseModel.isSuccess;
    _zoneID = _choosePreferredZoneId(responseModel);

    if (updateInAddress && responseModel.isSuccess) {
      AddressModel? address = AddressHelper.getAddressFromSharedPref();
      if(address != null) {
        address.zoneData = responseModel.zoneData;
        address.zoneId = _zoneID;
        try {
          if (address.zoneUpdateAt != null) {
            final keysToRemove = <String>[];
            for (final entry in address.zoneUpdateAt!.entries) {
              final zoneIdStr = entry.key;
              final zoneId = int.tryParse(zoneIdStr);
              final zoneDataItem = responseModel.zoneData.firstWhereOrNull((z) => z.id == zoneId);
              if (zoneDataItem == null || zoneDataItem.increasedDeliveryFeeStatus != 1) {
                keysToRemove.add(zoneIdStr);
              }
            }
            for (final k in keysToRemove) {
              address.zoneUpdateAt!.remove(k);
            }
          }
        } catch (_) {}

        try {
          for (final z in responseModel.zoneData) {
            if (z.increasedDeliveryFeeStatus == 1 && z.updatedAt != null) {
              address.zoneUpdateAt ??= {};
              final key = z.id.toString();
              final existing = address.zoneUpdateAt![key];
              if (existing == null || existing < z.updatedAt!) {
                address.zoneUpdateAt![key] = z.updatedAt!;
              }
            }
          }
        } catch (_) {}
        AddressHelper.saveAddressInSharedPref(address);
      }
    }

    if (responseModel.isSuccess) {
      final zoneData = responseModel.zoneData.firstWhereOrNull(
            (data) =>
        data.id == _zoneID &&
            data.increasedDeliveryFeeStatus == 1 &&
            data.increaseDeliveryFeeMessage?.isNotEmpty == true,
      );
      _weatherIconUrl = _sanitizeIconUrl(zoneData?.icon);

      if(_weatherIconUrl == 'https://mapsee.co.in/icons/rain.png') {
        if(_isVideoInitialized) {
          _videoController?.play();
        }
      } else {
        _videoController?.pause();
      }
    } else {
      _weatherIconUrl = null;
      _videoController?.pause();
    }

    if (markerLoad) {
      _loading = false;
    } else {
      _isLoading = false;
    }
    update();
    return responseModel;
  }

  void makeLoadingOff() {
    _isLoading = false;
  }

  void updatePosition(CameraPosition? position, bool fromAddress) async {
    if (_updateAddressData) {
      _loading = true;
      update();
      if (fromAddress) {
        _position = Position(latitude: position!.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(), heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1, altitudeAccuracy: 1, headingAccuracy: 1);
      } else {
        _pickPosition = Position(latitude: position!.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(), heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1, altitudeAccuracy: 1, headingAccuracy: 1);
      }
      ZoneResponseModel responseModel = await getZone(position.target.latitude.toString(), position.target.longitude.toString(), true);
      _buttonDisabled = !responseModel.isSuccess;
      if (_changeAddress) {
        String addressFromGeocode = await getAddressFromGeocode(LatLng(position.target.latitude, position.target.longitude));
        fromAddress ? _address = addressFromGeocode : _pickAddress = addressFromGeocode;
      } else {
        _changeAddress = true;
      }
      _loading = false;
      update();
    } else {
      _updateAddressData = true;
    }
  }

  void setAddressTypeIndex(int index, {bool notify = true}) {
    _addressTypeIndex = index;
    if (notify) {
      update();
    }
  }

  void saveAddressAndNavigate(AddressModel address, bool fromSignUp, String? route, bool canRoute, bool isDesktop) {
    _prepareZoneData(address, fromSignUp, route, canRoute, isDesktop);
  }

  void _prepareZoneData(AddressModel address, bool fromSignUp, String? route, bool canRoute, bool isDesktop) {
    getZone(address.latitude, address.longitude, false).then((response) async {
      if (response.isSuccess) {
        Get.find<CartController>().getCartDataOnline();
        address.zoneId = response.zoneIds[0];
        address.zoneIds = [];
        address.zoneIds!.addAll(response.zoneIds);
        address.zoneData = [];
        address.zoneData!.addAll(response.zoneData);
        autoNavigate(address, fromSignUp, route, canRoute, isDesktop);
      } else {
        Get.back();
        showCustomSnackBar(response.message);
        if (route == 'splash') {
          Get.toNamed(RouteHelper.getPickMapRoute(route, false));
        }
      }
    });
  }

  void autoNavigate(AddressModel? address, bool fromSignUp, String? route, bool canRoute, bool isDesktop) async {
    locationServiceInterface.handleTopicSubscription(AddressHelper.getAddressFromSharedPref(), address);
    await AddressHelper.saveAddressInSharedPref(address!);
    if (AuthHelper.isLoggedIn() && !AuthHelper.isGuestLoggedIn()) {
      await Get.find<FavouriteController>().getFavouriteList();
      updateZone();
    }
    if (route == 'splash' && Get.isDialogOpen!) {
      Get.back();
    }
    HomeScreen.loadData(true);
    Get.find<CheckoutController>().clearPrevData();
    locationServiceInterface.handleRoute(fromSignUp, route, canRoute);
  }

  Future<Position> setLocation(String placeID, String? address, GoogleMapController? mapController) async {
    _loading = true;
    update();
    LatLng latLng = await locationServiceInterface.getLatLng(placeID);
    _pickPosition = Position(latitude: latLng.latitude, longitude: latLng.longitude, timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
    _pickAddress = address;
    _changeAddress = false;
    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 16)));
    }
    _loading = false;
    update();
    return _pickPosition;
  }

  void disableButton() {
    _buttonDisabled = true;
    _inZone = true;
    update();
  }

  void addAddressData() {
    _position = _pickPosition;
    _address = _pickAddress;
    _updateAddressData = false;
    update();
  }

  void updateAddress(AddressModel address) {
    _position = Position(latitude: double.parse(address.latitude!), longitude: double.parse(address.longitude!), timestamp: DateTime.now(), altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, floor: 1, accuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1);
    _address = address.address;
    _addressTypeIndex = _addressTypeList.indexOf(address.addressType);
  }

  void setPickData() {
    _pickPosition = _position;
    _pickAddress = _address;
  }

  void setMapController(GoogleMapController mapController) {
    _mapController = mapController;
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    return await locationServiceInterface.getAddressFromGeocode(latLng);
  }

  Future<List<PredictionModel>> searchLocation(String text) async {
    _predictionList = [];
    if (text.isNotEmpty) {
      _predictionList = await locationServiceInterface.searchLocation(text);
    }
    return _predictionList;
  }

  void setPlaceMark(String address) {
    _address = address;
  }

  void checkPermission(Function onTap) {
    locationServiceInterface.checkLocationPermission(onTap);
  }

  Future<void> updateZone() async {
    final savedAddress = AddressHelper.getAddressFromSharedPref();
    if (savedAddress != null) {
      await getZone(savedAddress.latitude, savedAddress.longitude, false, updateInAddress: true);
    } else {
      await locationServiceInterface.updateZone();
    }
  }
}

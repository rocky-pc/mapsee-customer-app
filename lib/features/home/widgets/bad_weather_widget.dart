import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';

class BadWeatherWidget extends StatefulWidget {
  const BadWeatherWidget({super.key});

  @override
  State<BadWeatherWidget> createState() => _BadWeatherWidgetState();
}

class _BadWeatherWidgetState extends State<BadWeatherWidget> {
  late LocationController _locationController;
  bool _isLoading = false;
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _locationController = Get.find<LocationController>();
    _checkAndFetchLocationIfNeeded();

    // Set up periodic refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _refreshWeatherData();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _refreshWeatherData() async {
    final address = AddressHelper.getAddressFromSharedPref();
    if (address != null &&
        address.latitude != null &&
        address.longitude != null) {
      try {
        await _locationController.getZone(
          address.latitude,
          address.longitude,
          false,
          updateInAddress: true,
        );
      } catch (e) {
        // Silently handle refresh errors
      }
    }
  }

  Future<void> _checkAndFetchLocationIfNeeded() async {
    final address = AddressHelper.getAddressFromSharedPref();
    if (address == null && !_isLoading) {
      setState(() => _isLoading = true);
      try {
        // Automatically get current location if no address is saved
        final currentAddress =
            await _locationController.getCurrentLocation(true);
        // The getCurrentLocation method will automatically save the address
        // and update the zone data, so we don't need to do anything else here

        // Force update the weather icon by calling getZone with updateInAddress = true
        if (currentAddress.latitude != null &&
            currentAddress.longitude != null) {
          await _locationController.getZone(
            currentAddress.latitude,
            currentAddress.longitude,
            false,
            updateInAddress: true,
          );
        }
      } catch (e) {
        // If location fetching fails, just continue without showing the widget
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(
      builder: (locationController) {
        final address = AddressHelper.getAddressFromSharedPref();

        // Show loading indicator while fetching location
        if (_isLoading || (address == null && locationController.loading)) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              color: Theme.of(context).cardColor.withOpacity(0.25),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_searching,
                  size: 18,
                  color: Theme.of(context).cardColor,
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  'Getting location...'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ],
            ),
          );
        }

        if (address == null) return const SizedBox();

        final zoneData = address.zoneData?.firstWhereOrNull(
          (data) =>
              data.id == address.zoneId &&
              data.increasedDeliveryFeeStatus == 1 &&
              data.increaseDeliveryFeeMessage?.isNotEmpty == true,
        );

        if (zoneData == null) return const SizedBox();

        final zoneUpdated = address.zoneUpdateAt != null &&
            address.zoneUpdateAt!.containsKey(address.zoneId.toString());
        if (!zoneUpdated) return const SizedBox();

        String? message = zoneData.increaseDeliveryFeeMessage;
        String? iconUrl = locationController.weatherIconUrl;

        return (message != null && message.isNotEmpty)
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  color: Theme.of(context).cardColor.withOpacity(0.25),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (iconUrl != null && iconUrl.isNotEmpty) ...[
                      Image.network(
                        iconUrl,
                        height: 25,
                        width: 25,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.cloud_off,
                            size: 18,
                            color: Theme.of(context).cardColor,
                          );
                        },
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    ],
                    Flexible(
                      child: Text(
                        message,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).cardColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox();
      },
    );
  }
}

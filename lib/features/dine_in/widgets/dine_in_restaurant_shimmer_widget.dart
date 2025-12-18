import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/features/home/widgets/restaurants_view_widget.dart'; // Adjust path if needed
import 'package:stackfood_multivendor/util/dimensions.dart';

class DineInRestaurantShimmerWidget extends StatelessWidget {
  const DineInRestaurantShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          child: SizedBox(
            height: 260, // Increased slightly to match taller trendy cards
            child: const WebRestaurantShimmer(),
          ),
        );
      },
    );
  }
}
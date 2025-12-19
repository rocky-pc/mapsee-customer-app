import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';

class AnimatedMapIconMinimised extends StatefulWidget {
  const AnimatedMapIconMinimised({super.key});

  @override
  State<AnimatedMapIconMinimised> createState() => _AnimatedMapIconMinimisedState();
}

class _AnimatedMapIconMinimisedState extends State<AnimatedMapIconMinimised> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Dimensions.pickMapIconSize,
        height: Dimensions.pickMapIconSize,
        child: Image.asset(
          Images.pickicon, // Your custom pin icon
          fit: BoxFit.contain,
          // Optional: add a subtle shadow to match previous style
          // You can remove this if not needed
          colorBlendMode: BlendMode.multiply,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';

class AnimatedMapIconExtended extends StatefulWidget {
  const AnimatedMapIconExtended({super.key});

  @override
  State<AnimatedMapIconExtended> createState() => _AnimatedMapIconExtendedState();
}

class _AnimatedMapIconExtendedState extends State<AnimatedMapIconExtended> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Dimensions.pickMapIconSize,
        height: Dimensions.pickMapIconSize,
        child: Image.asset(
          Images.pickicon, // Using the same custom pin icon as in the minimised version
          fit: BoxFit.contain,
          // Optional: tint the icon with error color if needed
          // color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
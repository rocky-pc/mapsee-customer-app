import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isBorder;
  final bool isShadow;
  final Color? borderColor;
  final Color? backgroundColor;

  const CustomCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.padding,
    this.isBorder = true,
    this.isShadow = true,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // Removed default double.infinity to allow card to wrap content if needed
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16.0), // Defaults to 16 if not provided (from V2)
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? Dimensions.radiusDefault),

        // Border Logic: Checks isBorder flag. Uses specific colors for Dark/Light mode if no custom color is provided.
        border: isBorder
            ? Border.all(
          color: borderColor ?? (Get.isDarkMode ? const Color(0xff171515) : const Color(0xffF2F2F2)),
          width: 1,
        )
            : null,

        // Shadow Logic: Checks isShadow flag. Uses opacity compatible with both snippets.
        boxShadow: isShadow
            ? [
          BoxShadow(
            color: Get.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          )
        ]
            : null,
      ),
      child: child,
    );
  }
}
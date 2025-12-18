import 'package:stackfood_multivendor/theme/light_theme.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';

class RestaurantsFilterButtonWidget extends StatelessWidget {
  const RestaurantsFilterButtonWidget({super.key, required this.isSelected, this.onTap, required this.buttonText});

  final bool isSelected;
  final void Function()? onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).cardColor : Theme.of(context).cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.3) : deepBlack.withValues(alpha: 0.9)),
        ),
        child: Center(child: Text(buttonText, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w700,
          color: isSelected ? Theme.of(context).primaryColor : deepBlack,
        ))),
      ),
    );
  }
}

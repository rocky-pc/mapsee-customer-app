import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return GetBuilder<CartController>(builder: (cartController) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            // CHANGED: Reduced vertical padding from 10 to 6 to decrease total height
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home', primaryColor),
                _buildNavItem(1, Icons.favorite_rounded, 'Wishlist', primaryColor),
                _buildCartNavItem(2, Icons.shopping_cart_rounded, 'Cart', cartController.cartList.length, primaryColor),
                _buildNavItem(3, Icons.receipt_long_rounded, 'Orders', primaryColor),
                _buildNavItem(4, Icons.menu_rounded, 'Menu', primaryColor),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color primaryColor) {
    final bool isSelected = index == selectedIndex;
    final Color itemColor = isSelected ? primaryColor : Colors.grey.shade500;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: itemColor,
                // CHANGED: Reduced icon size (was 28/26 -> now 24/22)
                size: isSelected ? 24 : 22,
              ),
              // CHANGED: Reduced spacing (was 4 -> now 2)
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartNavItem(int index, IconData icon, String label, int cartCount, Color primaryColor) {
    final bool isSelected = index == selectedIndex;
    final Color itemColor = isSelected ? primaryColor : Colors.grey.shade500;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: itemColor,
                    // CHANGED: Reduced cart icon size (was 26/24 -> now 22/20)
                    size: isSelected ? 24 : 22,
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: -8,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red : Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Center(
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // CHANGED: Reduced spacing (was 3 -> now 2)
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
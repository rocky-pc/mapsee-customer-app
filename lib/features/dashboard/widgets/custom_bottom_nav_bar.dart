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
    final Color lightOrange = Theme.of(context).secondaryHeaderColor;
    final Color darkOrange = Theme.of(context).primaryColor;

    return GetBuilder<CartController>(builder: (cartController) {
      return Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: lightOrange,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: darkOrange.withOpacity(0.9),
              spreadRadius: 1,
              blurRadius: 0.2,
              // offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Home', lightOrange, darkOrange),
            _buildNavItem(1, Icons.favorite_outline, 'Wishlist', lightOrange, darkOrange),
            _buildCartNavItem(2, Icons.shopping_cart_outlined, 'My Cart', lightOrange, darkOrange, cartController.cartList.length),
            _buildNavItem(3, Icons.receipt_outlined, 'Orders', lightOrange, darkOrange),
            _buildNavItem(4, Icons.menu, 'Menu', lightOrange, darkOrange),
          ],
        ),
      );
    });
  }

  Widget  _buildNavItem(int index, IconData icon, String label, Color bgColor, Color activeColor) {
    final bool isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: 25,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartNavItem(int index, IconData icon, String label, Color bgColor, Color activeColor, int cartCount) {
    final bool isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                  size: 28,
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

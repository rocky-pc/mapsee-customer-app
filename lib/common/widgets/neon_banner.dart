import 'package:flutter/material.dart';

class NeonBanner extends StatelessWidget {
  final Widget child;
  final Color neonColor;
  final double blurRadius; // Reduced for a sharper line
  final double spreadRadius; // Set to a negative value to pull the shadow in, or 0.0
  final BorderRadiusGeometry borderRadius;
  final Color? backgroundColor;

  const NeonBanner({
    Key? key,
    required this.child,
    this.neonColor = Colors.lightBlueAccent, // Default neon color
    this.blurRadius = 60.0, // 👈 KEY CHANGE: Drastically reduced for a line effect
    this.spreadRadius = -2.0, // Can be slightly negative (-1.0 to -3.0) for a thinner line
    this.borderRadius = const BorderRadius.all(Radius.circular(15.0)),
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For a line border, it's often best to set the backgroundColor to null
    // so the Container's main color is the glow, and the child's widget
    // provides the inner background.
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: [
          // 💡 Main Line Glow: Small blur and zero/negative spread for a sharp edge.
          BoxShadow(
            color: neonColor,
            blurRadius: blurRadius, // e.g., 3.0
            spreadRadius: spreadRadius, // e.g., 0.0 or -2.0
            offset: const Offset(0, 0),
          ),
          // 💡 Inner White/Light Color (Simulates the light source pipe)
          // This adds a very bright center to the line.
          BoxShadow(
            color: Colors.white.withOpacity(1), // Very bright, centralized color
            blurRadius: blurRadius / 3, // Very small blur to keep it sharp
            spreadRadius: spreadRadius,
            offset: const Offset(0, 0),
          ),
          // 💡 Outer, Softer Glow (Optional: Adds a slight haze)
          BoxShadow(
            color: neonColor.withOpacity(0.8),
            blurRadius: blurRadius * 2, // Slightly more blur
            spreadRadius: 0.0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}
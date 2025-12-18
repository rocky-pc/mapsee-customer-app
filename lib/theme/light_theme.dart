import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';

// Add this line at the top with your other constants
const Color deepBlack = Color(0xFF121212);   // <-- choose your favorite
// New Core Color Constant for better readability
const Color coreOrange = Color(0xFFFD6723);

ThemeData light = ThemeData(
  fontFamily: AppConstants.fontFamily,

  // PRIMARY COLOR
  primaryColor: coreOrange,

  // SECONDARY HEADER COLOR (often a lighter/translucent primary color)
  secondaryHeaderColor: coreOrange.withOpacity(0.607), // 0x9B is approx 60.7% opacity

  disabledColor: const Color(0xFF9B9B9B),
  brightness: Brightness.light,
  hintColor: const Color(0xFF5E6472),
  cardColor: Colors.white,
  shadowColor: Colors.black.withOpacity(0.03),
  scaffoldBackgroundColor: Colors.white,        // optional

  // TEXT BUTTON THEME
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: coreOrange)),

  // COLOR SCHEME
  colorScheme: const ColorScheme.light(
    primary: coreOrange,
    tertiary: Color(0xFFE65100), // Kept this as is, as it's a deep orange tertiary
    tertiaryContainer: Color(0xFFFFE0B2), // Kept this as is, as it's a light tertiary container
    secondary: coreOrange, // Using primary color for secondary as per original code
  ).copyWith(surface: const Color(0xFFF5F6F8)).copyWith(error: const Color(0xFFD32F2F)),

  // You can now use deepBlack wherever you need a true deep black
  // Example:
  // appBarTheme: AppBarTheme(backgroundColor: deepBlack),

  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(500))),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.white,
    height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(color: const Color(0xFFBABFC4).withOpacity(0.25), thickness: 0.5),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
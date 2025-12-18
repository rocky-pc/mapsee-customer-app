import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:flutter/material.dart';

// New Core Color Constant for better readability
const Color coreOrange = Color(0xFFFD6723);

ThemeData dark = ThemeData(
  fontFamily: AppConstants.fontFamily,

  // PRIMARY COLOR
  primaryColor: coreOrange,

  // SECONDARY HEADER COLOR (often a lighter/translucent primary color)
  secondaryHeaderColor: coreOrange.withOpacity(0.607), // 0x9B is approx 60.7% opacity

  disabledColor: const Color(0xFF9B9B9B),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF5E6472),
  cardColor: const Color(0xFF141313),
  shadowColor: Colors.white.withOpacity(0.03),

  // TEXT BUTTON THEME
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: coreOrange)),

  // COLOR SCHEME
  colorScheme: const ColorScheme.dark(
      primary: coreOrange,
      tertiary: Color(0xFFE65100), // Kept this deep orange for contrast/accent
      tertiaryContainer: Color(0xFFFFE0B2), // Kept this light container color
      secondary: coreOrange
  ).copyWith(surface: const Color(0xFF272727)).copyWith(error: const Color(0xFFD32F2F)),

  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF29292D), surfaceTintColor: Color(0xFF29292D)),
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.black, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: DividerThemeData(color: const Color(0xFFBABFC4).withOpacity(0.25), thickness: 0.5),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
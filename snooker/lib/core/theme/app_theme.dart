import 'package:flutter/cupertino.dart';

/// iOS-native theme configuration
class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = CupertinoColors.systemBlue;
  static const Color lightBackground = CupertinoColors.white;
  static const Color lightSurface = CupertinoColors.systemGroupedBackground;
  static const Color lightText = CupertinoColors.black;
  static const Color lightSecondaryText = CupertinoColors.systemGrey;
  
  // Dark Theme Colors
  static const Color darkPrimary = CupertinoColors.systemBlue;
  static const Color darkBackground = CupertinoColors.black;
  static const Color darkSurface = CupertinoColors.systemGrey6;
  static const Color darkText = CupertinoColors.white;
  static const Color darkSecondaryText = CupertinoColors.systemGrey;
  
  // Ball Colors
  static const Color yellowBall = Color(0xFFFFD700);
  static const Color greenBall = Color(0xFF228B22);
  static const Color brownBall = Color(0xFF8B4513);
  static const Color blueBall = Color(0xFF0000FF);
  static const Color pinkBall = Color(0xFFFF69B4);
  static const Color blackBall = Color(0xFF000000);
  static const Color redBall = Color(0xFFDC143C);
  
  // Light Theme Data
  static CupertinoThemeData lightTheme = const CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    barBackgroundColor: lightSurface,
    textTheme: CupertinoTextThemeData(
      primaryColor: lightText,
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        color: lightText,
      ),
    ),
  );
  
  // Dark Theme Data
  static CupertinoThemeData darkTheme = const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    barBackgroundColor: darkSurface,
    textTheme: CupertinoTextThemeData(
      primaryColor: darkText,
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        color: darkText,
      ),
    ),
  );
}

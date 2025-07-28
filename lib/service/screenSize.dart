import 'package:flutter/material.dart';

class ScreenSizeConfig {
  final double screenWidth;
  final double screenHeight;

  ScreenSizeConfig(BuildContext context)
      : screenWidth = MediaQuery.of(context).size.width,
        screenHeight = MediaQuery.of(context).size.height;

  bool get isMobile => screenWidth <= 600;
  bool get isTablet => screenWidth > 600 && screenWidth <= 900;
  bool get isDesktop => screenWidth > 900;
  bool get isIphone8 => screenWidth < 380 && screenHeight < 670;

  double getAppBarHeight() {
    double appBarHeight = screenHeight * (isMobile ? 0.15 : isTablet ? 0.10 : 0.15);
    if (isIphone8) {
      appBarHeight = screenHeight * 0.25; // Example adjustment
    }
    return appBarHeight;
  }

  double getHeaderFontSize() {
    double headerFontSize = isMobile ? 12 : isTablet ? 14 : 16;
    if (isIphone8) {
      headerFontSize = 13;
    }
    return headerFontSize;
  }

  double getBodyFontSize() {
    double bodyFontSize = isMobile ? 10 : isTablet ? 12 : 14;
    if (isIphone8) {
      bodyFontSize = 11;
    }
    return bodyFontSize;
  }

  double getIconSize() {
    double iconSize = isMobile ? 24 : isTablet ? 28 : 25;
    if (isIphone8) {
      iconSize = 26;
    }
    return iconSize;
  }

  double getFooterIconSize() {
    double iconSize = isMobile ? 24 : isTablet ? 28 : 25;
    if (isIphone8) {
      iconSize = 26;
    }
    return iconSize;
  }

  double getLogoHeight() {
    double logoHeight = isMobile ? 60 : isTablet ? 70 : 80;
    if (isIphone8) {
      logoHeight = 65;
    }
    return logoHeight;
  }

  double getBottomMenuHeight() {
    double bottomMenuHeight = screenHeight * 0.08;
    if (isIphone8) {
      bottomMenuHeight = screenHeight * 0.09;
    }
    return bottomMenuHeight;
  }
}
import 'package:flutter/material.dart';
import 'package:pdf_tool/core/constants/app_dimensions.dart';

/// Helper class for responsive design across different screen sizes
class ResponsiveHelper {
  ResponsiveHelper._(); // Private constructor

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppDimensions.mobileBreakpoint &&
        width < AppDimensions.desktopBreakpoint;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppDimensions.desktopBreakpoint;
  }

  /// Get responsive value based on screen size
  /// Returns mobile value for mobile screens, tablet for tablets, desktop for desktop
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Get card width based on screen size
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isDesktop(context)) {
      return (screenWidth - (AppDimensions.horizontalPaddingDesktop * 2) - 
          (AppDimensions.gridSpacing * 3)) / 4;
    } else if (isTablet(context)) {
      return (screenWidth - (AppDimensions.horizontalPaddingTablet * 2) - 
          (AppDimensions.gridSpacing * 2)) / 3;
    } else {
      return (screenWidth - (AppDimensions.horizontalPaddingMobile * 2) - 
          AppDimensions.gridSpacing) / 2;
    }
  }

  /// Get grid cross axis count based on screen size
  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) {
      return AppDimensions.gridCrossAxisCountDesktop;
    } else if (isTablet(context)) {
      return AppDimensions.gridCrossAxisCountTablet;
    } else {
      return AppDimensions.gridCrossAxisCountMobile;
    }
  }

  /// Get horizontal padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return AppDimensions.horizontalPaddingDesktop;
    } else if (isTablet(context)) {
      return AppDimensions.horizontalPaddingTablet;
    } else {
      return AppDimensions.horizontalPaddingMobile;
    }
  }

  /// Get vertical padding based on screen size
  static double getVerticalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return AppDimensions.verticalPaddingDesktop;
    } else if (isTablet(context)) {
      return AppDimensions.verticalPaddingTablet;
    } else {
      return AppDimensions.verticalPaddingMobile;
    }
  }

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = getScreenWidth(context);
    
    if (screenWidth >= AppDimensions.desktopBreakpoint) {
      return baseFontSize * 1.1;
    } else if (screenWidth >= AppDimensions.tabletBreakpoint) {
      return baseFontSize * 1.05;
    } else {
      return baseFontSize;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    final screenWidth = getScreenWidth(context);
    
    if (screenWidth >= AppDimensions.desktopBreakpoint) {
      return baseIconSize * 1.2;
    } else if (screenWidth >= AppDimensions.tabletBreakpoint) {
      return baseIconSize * 1.1;
    } else {
      return baseIconSize;
    }
  }

  /// Get max content width (for centering content on large screens)
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    return screenWidth > AppDimensions.maxContentWidth
        ? AppDimensions.maxContentWidth
        : screenWidth;
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isDesktop(context)) {
      return baseSpacing * 1.5;
    } else if (isTablet(context)) {
      return baseSpacing * 1.25;
    } else {
      return baseSpacing;
    }
  }

  /// Check if screen is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if screen is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get device pixel ratio
  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Get text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1);
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    if (isDesktop(context)) {
      return baseRadius * 1.2;
    } else if (isTablet(context)) {
      return baseRadius * 1.1;
    } else {
      return baseRadius;
    }
  }

  /// Get responsive elevation
  static double getResponsiveElevation(BuildContext context, double baseElevation) {
    if (isDesktop(context)) {
      return baseElevation * 1.5;
    } else if (isTablet(context)) {
      return baseElevation * 1.25;
    } else {
      return baseElevation;
    }
  }

  /// Get number of columns for grid layout
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 2,
    int tabletColumns = 3,
    int desktopColumns = 4,
  }) {
    if (isDesktop(context)) {
      return desktopColumns;
    } else if (isTablet(context)) {
      return tabletColumns;
    } else {
      return mobileColumns;
    }
  }

  /// Get aspect ratio for cards
  static double getCardAspectRatio(BuildContext context) {
    if (isDesktop(context)) {
      return 1.4;
    } else if (isTablet(context)) {
      return 1.3;
    } else {
      return 1.2;
    }
  }
}

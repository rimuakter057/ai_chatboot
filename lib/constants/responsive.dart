import 'package:flutter/widgets.dart';

/// Screen width breakpoints used across the app.
///
/// - Mobile:  width < [tabletBreakpoint]
/// - Tablet:  [tabletBreakpoint] <= width < [desktopBreakpoint]
/// - Desktop: width >= [desktopBreakpoint]
class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;
}

/// Convenience extension on [BuildContext] for querying the current device
/// class and deriving responsive values without repeating MediaQuery calls.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  bool get isMobile => screenWidth < Responsive.tabletBreakpoint;

  bool get isTablet =>
      screenWidth >= Responsive.tabletBreakpoint &&
      screenWidth < Responsive.desktopBreakpoint;

  bool get isDesktop => screenWidth >= Responsive.desktopBreakpoint;

  /// Max width for the centered chat container.
  /// Mobile takes the full width; tablet and desktop cap the content width
  /// so lines of text stay readable on wide screens.
  double get chatContainerMaxWidth {
    if (isDesktop) return 900;
    if (isTablet) return 700;
    return double.infinity;
  }

  /// Max width fraction for a single chat bubble relative to the chat
  /// container width (75% on mobile, 60% on tablet/desktop).
  double get bubbleMaxWidthFraction => isMobile ? 0.75 : 0.60;

  /// Horizontal page padding that scales with screen size.
  double get pagePadding {
    if (isDesktop) return 32;
    if (isTablet) return 24;
    return 16;
  }

  /// Base font scale multiplier for larger screens, if extra emphasis is
  /// needed beyond the fixed [AppTextStyles] sizes.
  double get fontScale {
    if (isDesktop) return 1.05;
    if (isTablet) return 1.0;
    return 1.0;
  }
}

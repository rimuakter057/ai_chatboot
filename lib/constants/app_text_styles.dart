import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized typography presets built on top of Google Fonts' Inter
/// typeface. Use these presets instead of building [TextStyle]s inline so
/// the app's type scale stays consistent.
class AppTextStyles {
  AppTextStyles._();

  /// Large heading style, used for screen titles and the bot name in the
  /// app bar.
  static TextStyle get heading => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  /// Standard body text style.
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  /// Small caption style used for timestamps and helper text.
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
      );

  /// Style used specifically for text inside chat bubbles.
  static TextStyle get chatMessage => GoogleFonts.inter(
        fontSize: 15.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  /// Style used for suggested prompt chip labels.
  static TextStyle get chip => GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );
}

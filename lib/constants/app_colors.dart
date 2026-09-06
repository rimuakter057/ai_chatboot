import 'package:flutter/material.dart';

/// Centralized color palette for the AI Chatbot UI.
///
/// All colors used across the app should be referenced from here so the
/// theme can be adjusted from a single location.
class AppColors {
  AppColors._();

  /// Deep black used as the main app/screen background.
  static const Color background = Color(0xFF0A0A0A);

  /// Slightly lighter black used for bot bubbles, input fill, and cards.
  static const Color surface = Color(0xFF1A1A1A);

  /// Bright cyan accent used for buttons, active states, and user bubbles.
  static const Color accent = Color(0xFF00E5FF);

  /// Primary text color (high emphasis).
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text color (medium/low emphasis), used for timestamps,
  /// hints, and captions.
  static const Color textSecondary = Color(0xFFB0B0B0);

  /// Divider and border color used across cards, inputs, and separators.
  static const Color border = Color(0xFF2A2A2A);

  /// Text color used on top of the accent color (user bubbles, buttons).
  static const Color onAccent = Color(0xFF00171A);

  /// Used for failed message states and destructive actions.
  static const Color error = Color(0xFFFF5252);
}

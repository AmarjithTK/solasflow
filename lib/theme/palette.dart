import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Access the app's color tokens based on current brightness.
///
/// Usage: `final c = context.appColors;`
extension AppColorAccess on BuildContext {
  ColorTokens get appColors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.light
        ? AppColors.light
        : AppColors.dark;
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle tiroHeadline(double size, {FontWeight weight = FontWeight.bold}) {
    return GoogleFonts.tiroBangla(
      fontSize: size,
      fontWeight: weight,
      color: AppColors.primary,
      height: 1.2,
    );
  }

  static TextStyle siliguriBody(double size, {Color? color, FontWeight weight = FontWeight.normal}) {
    return GoogleFonts.hindSiliguri(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.onSurface,
      height: 1.5,
    );
  }

  static TextStyle monoLabel(double size, {Color? color, double letterSpacing = 1.2}) {
    return GoogleFonts.ibmPlexMono(
      fontSize: size,
      fontWeight: FontWeight.w500,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.outline,
    );
  }
}

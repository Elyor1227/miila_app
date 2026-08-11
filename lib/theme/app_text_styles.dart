import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Miila — Poppins asosidagi tipografiya
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base(double size, FontWeight weight, {Color? color, double? height}) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      height: height,
    );
  }

  // Sarlavhalar
  static TextStyle h1 = _base(28, FontWeight.w700);
  static TextStyle h2 = _base(24, FontWeight.w700);
  static TextStyle h3 = _base(20, FontWeight.w600);
  static TextStyle h4 = _base(18, FontWeight.w600);

  // Matn
  static TextStyle bodyLarge = _base(16, FontWeight.w400, height: 1.4);
  static TextStyle body = _base(14, FontWeight.w400, color: AppColors.muted, height: 1.4);
  static TextStyle bodyMedium = _base(14, FontWeight.w500);
  static TextStyle caption = _base(12, FontWeight.w400, color: AppColors.muted);
  static TextStyle label = _base(12, FontWeight.w600, color: AppColors.muted);

  // Tugmalar
  static TextStyle button = _base(16, FontWeight.w600, color: AppColors.white);

  // Logotip (kursiv uslub)
  static TextStyle logo = GoogleFonts.dancingScript(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.pink,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sarlavhalar uchun "Sora" (geometrik, zamonaviy), matn uchun "Plus Jakarta Sans".
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.sora(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
        height: 1.2,
      );

  static TextStyle get h1 => GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
        height: 1.25,
      );

  static TextStyle get h2 => GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.charcoal,
      );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.charcoal,
        height: 1.4,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.charcoal,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get small => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );

  static TextStyle get button => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle get price => GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
      );
}

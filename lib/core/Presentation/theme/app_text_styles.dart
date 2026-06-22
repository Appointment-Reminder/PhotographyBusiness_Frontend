import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static final heading = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static final body = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  static final muted = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
  );

  static final mono = GoogleFonts.jetBrainsMono(
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  // Sized variants — extend as Figma specifies
  static final heading24 = heading.copyWith(fontSize: 24);
  static final heading18 = heading.copyWith(fontSize: 18);
  static final heading16 = heading.copyWith(fontSize: 16);

  static final body14 = body.copyWith(fontSize: 14);
  static final body16 = body.copyWith(fontSize: 16);

  static final muted12 = muted.copyWith(fontSize: 12);
  static final muted14 = muted.copyWith(fontSize: 14);

  static final mono12 = mono.copyWith(fontSize: 12);
}
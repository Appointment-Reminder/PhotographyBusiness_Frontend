import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Base families ───────────────────────────────────────────
  static final _inter        = GoogleFonts.inter();
  static final _jetbrainsMono = GoogleFonts.jetBrainsMono();

  // ─── Inter — headings & UI ───────────────────────────────────
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

  // ─── JetBrains Mono — prices, labels, tokens ─────────────────
  static final mono = GoogleFonts.jetBrainsMono(
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  static final monoMuted = GoogleFonts.jetBrainsMono(
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
  );

  // ─── Sized variants ───────────────────────────────────────────
  static final heading24 = heading.copyWith(fontSize: 24);
  static final heading18 = heading.copyWith(fontSize: 18);
  static final heading16 = heading.copyWith(fontSize: 16);

  static final body16 = body.copyWith(fontSize: 16);
  static final body14 = body.copyWith(fontSize: 14);

  static final muted14 = muted.copyWith(fontSize: 14);
  static final muted12 = muted.copyWith(fontSize: 12);

  static final mono12     = mono.copyWith(fontSize: 12);
  static final mono11     = mono.copyWith(fontSize: 11);
  static final mono10     = mono.copyWith(fontSize: 10);
  static final monoMuted12 = monoMuted.copyWith(fontSize: 12);
  static final monoMuted11 = monoMuted.copyWith(fontSize: 11);
  static final monoMuted10 = monoMuted.copyWith(fontSize: 10);
}
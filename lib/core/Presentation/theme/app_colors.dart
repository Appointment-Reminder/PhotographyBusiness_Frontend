import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //Base
  static const mainBg = Color(0xFFF9FAFB);

  // Sidebar / Shell
  static const sidebarBg   = Color(0xFFF4F4F5);
  static const active      = Color(0xFFFFFFFF);

  //NavBar
  static const blackText = Color(0xFF111318);
  static const greyText = Color(0xFF71717b);
  static const navBarBg =  Color(0xFFF4F4F5);
  static const hoveredButtonBg = Color(0xFFE4E4E7);
  static const selectedButtonBg = Color(0xFFFFFFFF);

  //TopNavBar
  static const TNB_selectedButtonBg = Color(0xFF18181B);  // primaryText
  static const TNB_hoveredButtonBg  = Color(0xBAE4E4E7);  // mainBg
  static const TNB_blackText        = Color(0xFF111318);   // active (text on dark bg)
  static const TNB_whiteText        = Color(0xFFFFFFFF);   // active (text on dark bg)
  static const TNB_greyText         = Color(0xFF71717A);   // mutedText
  static const TNB_selectedHoveredButtonBg = Color(0xFF3F3F46);

  // Text
  static const primaryText = Color(0xFF18181B);
  static const mutedText   = Color(0xFF71717A);

  // Border
  static const border      = Color(0xFFD4D4D8);
}
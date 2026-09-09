import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle heading1(Color color) => GoogleFonts.manrope(
        fontSize: 28, fontWeight: FontWeight.w700, color: color, height: 1.2,
      );

  static TextStyle heading2(Color color) => GoogleFonts.manrope(
        fontSize: 22, fontWeight: FontWeight.w700, color: color, height: 1.25,
      );

  static TextStyle cardTitle(Color color) => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w600, color: color,
      );

  static TextStyle body(Color color) => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: color,
      );

  static TextStyle bodySmall(Color color) => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: color,
      );

  static TextStyle metricLarge(Color color) => GoogleFonts.manrope(
        fontSize: 34, fontWeight: FontWeight.w800, color: color, height: 1.1,
      );
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ThemeFlavor { coffee, matcha }

class BruchaColors {
  static ThemeFlavor activeFlavor = ThemeFlavor.coffee;

  static Color get ink => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFF1C1108) 
      : const Color(0xFF152A12); // Deep forest matcha
  
  static Color get ink2 => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFF3B2510) 
      : const Color(0xFF284823);
  
  static Color get ink3 => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFF6B4226) 
      : const Color(0xFF4E7747);
  
  static Color get parch => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFFF7F0E4) 
      : const Color(0xFFF2F7F0); // Pale matcha cream
  
  static Color get parch2 => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFFEDE0CB) 
      : const Color(0xFFE3ECD8);
  
  static Color get parch3 => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFFE2D0B4) 
      : const Color(0xFFD3E0C5);
  
  static Color get cream => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFFFAF5EC) 
      : const Color(0xFFFAFDF9); // Fresh milk
  
  static Color get gold => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFFC8943A) 
      : const Color(0xFF5A8E4C); // Matcha Green
  
  static Color get gold2 => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFFE8B86D) 
      : const Color(0xFF86B978); // Bright Matcha Milk
  
  static Color get gold3 => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFFF5D89A) 
      : const Color(0xFFB4E0A5); // Pale Matcha
      
  static const rust       = Color(0xFF8B3A1A);
  static const greenVeg   = Color(0xFF4A7C3F);
  static const greenVegBg = Color(0xFFE8F5E2);

  // Dark palette
  static Color get dkBg => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFF0E0905) 
      : const Color(0xFF091208);
  
  static Color get dkSurface => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFF1A1008) 
      : const Color(0xFF122310);
  
  static Color get dkCard => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFF231508) 
      : const Color(0xFF1B3118);
  
  static Color get dkBorder => activeFlavor == ThemeFlavor.coffee 
      ? const Color(0xFF3A2510) 
      : const Color(0xFF284823);
}

class BruchaTheme {
  static ThemeData get light => _build(false);
  static ThemeData get dark  => _build(true);

  static ThemeData _build(bool isDark) => ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: isDark ? BruchaColors.dkBg    : BruchaColors.parch,
    colorScheme: isDark
        ? ColorScheme.dark(
            primary:     BruchaColors.gold,
            secondary:   BruchaColors.gold2,
            surface:     BruchaColors.dkSurface,
            onPrimary:   BruchaColors.ink,
            onSecondary: BruchaColors.ink,
          )
        : ColorScheme.light(
            primary:     BruchaColors.gold,
            secondary:   BruchaColors.ink,
            surface:     BruchaColors.cream,
            onPrimary:   BruchaColors.ink,
            onSecondary: BruchaColors.gold2,
          ),
    textTheme: GoogleFonts.jostTextTheme().copyWith(
      displayLarge: GoogleFonts.cormorantGaramond(fontSize: 40, fontWeight: FontWeight.w300, letterSpacing: 1.5),
      displayMedium: GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.jost(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.jost(fontSize: 14),
      bodyMedium: GoogleFonts.jost(fontSize: 12),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: BruchaColors.ink,
      elevation: 0,
      titleTextStyle: GoogleFonts.cormorantGaramond(fontSize: 26, fontWeight: FontWeight.w300, color: BruchaColors.gold2, letterSpacing: 2),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? BruchaColors.dkCard : BruchaColors.parch,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: BruchaColors.parch3)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? BruchaColors.dkBorder : BruchaColors.parch3)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: BruchaColors.gold)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
  );
}

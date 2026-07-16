import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  // A calm, operational identity intentionally distinct from the patient app.
  static const Color lavenderPrimary = Color(0xFF72558D);
  static const Color lavenderDark = Color(0xFF3D2B4F);
  static const Color lavenderLight = Color(0xFFA98BC4);
  static const Color lavenderPale = Color(0xFFEDE4F2);
  static const Color beige = Color(0xFFF7F0E6);
  static const Color beigeDark = Color(0xFFE8D8C2);
  static const Color ink = Color(0xFF2D2433);
  static const Color mutedInk = Color(0xFF706878);

  // Kept as aliases while screens transition to the new design tokens.
  static const Color navyPrimary = lavenderPrimary;
  static const Color navyDark = lavenderDark;
  static const Color navyLight = lavenderLight;
  static const Color navyPale = lavenderPale;
  static const Color slatePrimary = Color(0xFF9A7C5D);
  static const Color slateDark = Color(0xFF705A45);
  static const Color slateLight = Color(0xFFCDBCA8);
  static const Color slatePale = beigeDark;
  static const Color textDark = ink;
  static const Color textMedium = mutedInk;
  static const Color textLight = Color(0xFF968C9B);
  
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: navyPrimary,
        secondary: slatePrimary,
        surface: Colors.white,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: beige,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: lavenderPale.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyPrimary,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: navyPrimary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: slatePale),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: slatePale),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: navyPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(
          color: textLight,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: textMedium,
          fontSize: 14,
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.3,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.2,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textDark,
          letterSpacing: -0.1,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
          letterSpacing: 0.1,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textMedium,
          letterSpacing: 0.2,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
          letterSpacing: 0,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
          letterSpacing: 0.1,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textMedium,
          letterSpacing: 0.2,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
          letterSpacing: 0.3,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textMedium,
          letterSpacing: 0.4,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textLight,
          letterSpacing: 0.5,
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: slatePale,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: navyPrimary,
        unselectedItemColor: slateLight,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

class AdminColors {
  static const navyPrimary = AdminTheme.navyPrimary;
  static const navyDark = AdminTheme.navyDark;
  static const navyLight = AdminTheme.navyLight;
  static const navyPale = AdminTheme.navyPale;
  static const slatePrimary = AdminTheme.slatePrimary;
  static const slateDark = AdminTheme.slateDark;
  static const slateLight = AdminTheme.slateLight;
  static const slatePale = AdminTheme.slatePale;
  static const textDark = AdminTheme.textDark;
  static const textMedium = AdminTheme.textMedium;
  static const textLight = AdminTheme.textLight;
  static const success = AdminTheme.success;
  static const error = AdminTheme.error;
  static const warning = AdminTheme.warning;
  static const info = AdminTheme.info;
}

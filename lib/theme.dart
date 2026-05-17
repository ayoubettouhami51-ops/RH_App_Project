import 'package:flutter/material.dart';

class OcpTheme {
  // PointageXpert Analytics Colors
  static const Color bg = Color(0xFF0A0F1E);
  static const Color surface = Color(0xFF111827);
  static const Color card = Color(0xFF1A2235);
  static const Color border = Color(0xFF1E2D45);
  
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentDim = Color(0x3300D4FF); // 20% opacity
  static const Color accentGreen = Color(0xFF00FF9C);
  static const Color accentOrange = Color(0xFFFF8C42);
  static const Color accentRed = Color(0xFFFF4560);
  static const Color accentPurple = Color(0xFF7B61FF);
  
  static const Color text = Color(0xFFE8F0FE);
  static const Color textMuted = Color(0xFF6B7A99);
  static const Color textDim = Color(0xFF3D4F6E);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.dark(
      primary: accent,
      secondary: accentPurple,
      surface: surface,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: text,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: text),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 28),
      headlineMedium: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 22),
      headlineSmall: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 18),
      bodyLarge: TextStyle(color: text, fontSize: 16),
      bodyMedium: TextStyle(color: textMuted, fontSize: 14),
      bodySmall: TextStyle(color: textDim, fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      hintStyle: const TextStyle(color: textMuted),
      labelStyle: const TextStyle(color: text),
      prefixIconColor: accent,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: accent,
      unselectedItemColor: textDim,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Gradient for primary buttons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient for background
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF060A14), Color(0xFF0A0F1E), Color(0xFF080D1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration cardDecoration() => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: border, width: 1),
  );

  // Signature widget
  static Widget signature() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      'Ayoub Ettouhami',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: accent.withOpacity(0.5),
        fontSize: 14,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
      ),
    ),
  );
}

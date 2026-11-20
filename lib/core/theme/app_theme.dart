import 'package:flutter/material.dart';

class WijiBumiColors {
  // Sistem Warna (UI Design Specification: Monochromatic Organic Plant Shop - Enhanced Contrast & Bright Glass)
  static const Color bgPrimary = Color(0xFF243626);       // Latar belakang utama (lebih gelap, deep matte forest green)
  static const Color surfaceDark = Color(0xFF18261A);     // Tombol notifikasi, search bar, tombol chevron >, bottom nav bar
  static const Color surfaceGlass = Color(0x66FFFFFF);    // Permukaan kartu kaca dipercerah (luminous frosted white-mint glass)
  static const Color glassBorder = Color(0x59FFFFFF);     // Garis tepi kaca dipertegas (35% white rim)
  static const Color textWhite = Color(0xFFFFFFFF);       // Heading besar, tab aktif, ikon nav aktif
  static const Color textMutedLight = Color(0xFFC7DBC9);  // Sapaan Hello!, nama user, tab pasif, deskripsi promo
  static const Color textPlaceholder = Color(0xFF9CB89E); // Placeholder search... dan ikon panah >
  static const Color textCardDark = Color(0xFF09170C);    // Teks nama produk & harga di dalam kartu (high contrast obsidian forest)
  static const Color iconNavInactive = Color(0xFF7E9881); // Ikon nav tidak aktif pada Bottom Navigation Bar
  static const Color shadowObject = Color(0x73040C05);    // Bayangan kontak alas pot

  // Backward compatibility & semantic aliases
  static const Color lightMint = Color(0xFFE8F5E9);       // Tint sekunder
  static const Color softSage = Color(0xFFA5D6A7);        // Border sekunder
  static const Color freshLeaf = Color(0xFF66BB6A);       // Accent hijau
  static const Color deepForest = Color(0xFF18261A);      // Surface dark
  static const Color pureGlassWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);     // Teks kontras putih di background utama
  static const Color textSecondary = Color(0xFFC7DBC9);   // Body text muted light
  static const Color textMuted = Color(0xFF9CB89E);       // Caption & placeholder
  static const Color backgroundCanvas = Color(0xFF243626); // Deep matte forest green background

  // Semantik & Status
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color success = Color(0xFF43A047);
  static const Color starGold = Color(0xFFFFB300);
}

class DynamicGlassDecoration {
  // Glass Card Luminous Frosted (Efek kaca dipercerah & berkilau)
  static BoxDecoration glassCard({double radius = 30}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.52),
          const Color(0xFFD8EADA).withOpacity(0.36),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(0.42),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.24),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.12),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  // Tier 1: Floating Glass Bar / Dark Surface Bar
  static BoxDecoration glassBar({
    double radius = 16,
    bool fullTopRadius = true,
    bool fullBottomRadius = true,
  }) {
    return BoxDecoration(
      color: WijiBumiColors.surfaceDark,
      borderRadius: BorderRadius.vertical(
        top: fullTopRadius ? Radius.circular(radius) : Radius.zero,
        bottom: fullBottomRadius ? Radius.circular(radius) : Radius.zero,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.14),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Tier 2: Clean Translucent Card (Dipercerah agar kontras tajam)
  static BoxDecoration cleanCard({double radius = 24}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.48),
          const Color(0xFFD8EADA).withOpacity(0.32),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(0.38),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.20),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // Tier 3: Accent Pill
  static BoxDecoration accentPill({double radius = 12, Color? fillColor, Color? borderColor}) {
    return BoxDecoration(
      color: fillColor ?? WijiBumiColors.surfaceDark,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.20),
        width: 1.0,
      ),
    );
  }

  // Surface Dark Container (Search bar, buttons, notif)
  static BoxDecoration surfaceDark({double radius = 16}) {
    return BoxDecoration(
      color: WijiBumiColors.surfaceDark,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(0.12),
        width: 1.0,
      ),
    );
  }

  // Input Field Glass
  static InputDecoration inputDecoration({
    required String hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: const TextStyle(
        color: WijiBumiColors.textPlaceholder,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: WijiBumiColors.textMutedLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: WijiBumiColors.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: WijiBumiColors.textWhite,
          width: 1.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: WijiBumiColors.error,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: WijiBumiColors.error,
          width: 1.5,
        ),
      ),
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: WijiBumiColors.bgPrimary,
        primary: WijiBumiColors.surfaceDark,
        secondary: WijiBumiColors.textMutedLight,
        surface: WijiBumiColors.surfaceDark,
        background: WijiBumiColors.bgPrimary,
        error: WijiBumiColors.error,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: WijiBumiColors.bgPrimary,
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: WijiBumiColors.textWhite),
        titleTextStyle: TextStyle(
          color: WijiBumiColors.textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: WijiBumiColors.textWhite,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          height: 1.15,
        ),
        headlineMedium: TextStyle(
          color: WijiBumiColors.textWhite,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        titleMedium: TextStyle(
          color: WijiBumiColors.textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: WijiBumiColors.textWhite,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: WijiBumiColors.textMutedLight,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.3,
        ),
        bodySmall: TextStyle(
          color: WijiBumiColors.textPlaceholder,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WijiBumiColors.surfaceDark,
          foregroundColor: WijiBumiColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

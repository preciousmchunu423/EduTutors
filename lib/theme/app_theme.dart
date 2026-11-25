import 'package:flutter/material.dart';

/// EduTutors design system: deep plum navigation, vibrant violet accents,
/// soft lavender surfaces and warm, accessible status colours.
class AppColors {
  AppColors._();

  static const Color purple = Color(0xFF5B2BCB);
  static const Color blue = purple; // Backwards-compatible name used by screens.
  static const Color navy = Color(0xFF21164D);
  static const Color plum = Color(0xFF211747);
  static const Color purpleDark = Color(0xFF35147D);
  static const Color purpleSoft = Color(0xFFF0EBFF);
  static const Color blueSoft = purpleSoft;
  static const Color purpleLine = Color(0xFFE2DAFF);
  static const Color blueLine = purpleLine;
  static const Color yellow = Color(0xFFFFC857);
  static const Color yellowSoft = Color(0xFFFFF5DF);
  static const Color white = Colors.white;
  static const Color textMuted = Color(0xFF77718F);
  static const Color border = Color(0xFFE9E5F4);
  static const Color canvas = Color(0xFFF8F7FC);
  static const Color green = Color(0xFF15966A);
  static const Color greenSoft = Color(0xFFE7F7F0);
}

class AppDecor {
  AppDecor._();

  static BoxDecoration card({
    Color color = AppColors.white,
    bool outlined = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: outlined ? Border.all(color: AppColors.border) : null,
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D28165D),
          blurRadius: 20,
          offset: Offset(0, 7),
        ),
      ],
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.purple,
      onPrimary: AppColors.white,
      secondary: AppColors.yellow,
      onSecondary: AppColors.navy,
      surface: AppColors.white,
      onSurface: AppColors.navy,
      error: Color(0xFFB42345),
      onError: AppColors.white,
      surfaceTint: Colors.transparent,
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.canvas,
      canvasColor: AppColors.canvas,
      dividerColor: AppColors.border,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: AppColors.navy,
        displayColor: AppColors.navy,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.purple),
        titleTextStyle: TextStyle(
          color: AppColors.navy,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: AppColors.white,
          minimumSize: const Size(64, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.purple,
          minimumSize: const Size(64, 46),
          side: const BorderSide(color: AppColors.purpleLine),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.purple,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFBFAFE),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIconColor: AppColors.purple,
        border: inputBorder(AppColors.border),
        enabledBorder: inputBorder(AppColors.border),
        focusedBorder: inputBorder(AppColors.purple, 1.7),
        errorBorder: inputBorder(const Color(0xFFB42345)),
        focusedErrorBorder: inputBorder(const Color(0xFFB42345), 1.7),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.purpleSoft,
        selectedColor: AppColors.purple,
        side: const BorderSide(color: AppColors.purpleLine),
        labelStyle: const TextStyle(
          color: AppColors.purpleDark,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(color: AppColors.white),
        checkmarkColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.plum,
        contentTextStyle: const TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.purple,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.purpleSoft,
        elevation: 8,
        shadowColor: const Color(0x1A28165D),
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.purple
                : AppColors.textMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.purple
                : AppColors.textMuted,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.purple,
        linearTrackColor: AppColors.purpleSoft,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.purple
              : Colors.transparent,
        ),
        side: const BorderSide(color: AppColors.textMuted),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(AppColors.purple),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.purple
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.purpleSoft
              : const Color(0xFFE9E5F4),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.navy,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class C {
  C._();

  // Surfaces
  static const bg = Color(0xFFF6F6FD);
  static const card = Color(0xFFFFFFFF); // تمت الإضافة للكروت وشريط التنقل
  static const surfaceSoft = Color(0xFFF8FAFC);
  static const lavender = Color(0xFFEFEFF9);
  static const indigoTint = Color(0xFFEEF2FF);
  static const border = Color(0xFFE5E7EB);
  static const cardBorder = Color(0xFFF0F0F5);
  static const inputBorder = Color(0xFFD1D5DB);
  static const track = Color(0xFFE5E7EB);

  // Text
  static const text = Color(0xFF131B2E);
  static const ink = text;
  static const sub = Color(0xFF6B7280);
  static const subDark = Color(0xFF4B5563);
  static const hint = Color(0xFF9CA3AF);

  // Brand / accents
  static const green = Color(0xFF138A3E);
  static const greenActive = Color(
    0xFF066E3E,
  ); // تمت الإضافة لأزرار التبويبات النشطة
  static const greenTint = Color(0xFFEAF8EE);
  static const greenCircleBg = Color(0xFFE8F5EE);
  static const brand = Color(0xFF03662A);
  static const greenBadge = Color(0xFFC7F9D0);
  static const greenLight = Color(0xFF7FFC97);
  static const neon = Color(0xFF22E066);
  static const orange = Color(0xFFF59E0B);
  static const amberDark = Color(0xFFB45309);
  static const amberTint = Color(0xFFFFF1DC);
  static const amberSurface = Color(0xFFFFFBEB);
  static const amberBorder = Color(0xFFFCD34D);
  static const orangeTint = Color(0xFFFEF3DC);
  static const red = Color(0xFFE5484D);
  static const redAlertBorder = Color(0xFFFCA5A5);
  static const redAlertSurface = Color(0xFFFFF7F7);
  static const redTint = Color(0xFFFDECEC);
  static const blue = Color(0xFF3B82F6);
  static const blueTint = Color(0xFFE8F0FE);
  static const navy = Color(0xFF1E2A3A);

  static const redDark = Color(0xFFB71C1C);
  static const redStrong = Color(0xFFC62828);
  static const redSoft = Color(0xFFFFF5F5);
  static const redBorder = Color(0xFFF5C2C2);
  static const orangeDark = Color(0xFFC2410C);
  static const orangeBar = Color(0xFFF97316);
  static const orangeLightBar = Color(0xFFF5B895);
  static const blueDark = Color(0xFF1D4ED8);
  static const blueBar = Color(0xFF0284C7);
  static const greenDeep = Color(0xFF166534);
  static const greenBorder = Color(0xFFC7E6D1);
}

TextStyle ts(
  double size, {
  FontWeight w = FontWeight.w500,
  Color color = C.text,
  double? ls,
  double? height,
}) => TextStyle(
  fontSize: size,
  fontWeight: w,
  color: color,
  letterSpacing: ls,
  height: height,
);

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: C.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.green,
      primary: C.green,
      error: C.red,
      surface: C.bg,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: C.text,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(backgroundColor: C.green),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: C.green,
        foregroundColor: Colors.white,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? C.green : null,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? C.green : C.border,
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: C.green,
      thumbColor: C.green,
      inactiveTrackColor: C.track,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic color tokens. Use `context.appColors.card` etc. to read them.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color scaffold;
  final Color card;
  final Color cardAlt;
  final Color primary;
  final Color primaryLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDim;
  final Color border;
  final Color success;
  final Color warning;
  final Color danger;

  const AppColors({
    required this.scaffold,
    required this.card,
    required this.cardAlt,
    required this.primary,
    required this.primaryLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDim,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
  });

  static const dark = AppColors(
    scaffold: Color(0xFF0F172A),
    card: Color(0xFF1E293B),
    cardAlt: Color(0xFF334155),
    primary: Color(0xFF6366F1),
    primaryLight: Color(0xFF818CF8),
    textPrimary: Colors.white,
    textSecondary: Colors.white70,
    textMuted: Colors.white54,
    textDim: Colors.white38,
    border: Color(0xFF334155),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
  );

  static const light = AppColors(
    scaffold: Color(0xFFF8FAFC),
    card: Colors.white,
    cardAlt: Color(0xFFF1F5F9),
    primary: Color(0xFF6366F1),
    primaryLight: Color(0xFF4F46E5),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF334155),
    textMuted: Color(0xFF64748B),
    textDim: Color(0xFF94A3B8),
    border: Color(0xFFE2E8F0),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
  );

  @override
  AppColors copyWith({
    Color? scaffold,
    Color? card,
    Color? cardAlt,
    Color? primary,
    Color? primaryLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDim,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppColors(
      scaffold: scaffold ?? this.scaffold,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDim: textDim ?? this.textDim,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>() ?? AppColors.dark;
}

ThemeData _buildTheme(AppColors c, Brightness brightness) {
  final base = brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
  return base.copyWith(
    brightness: brightness,
    scaffoldBackgroundColor: c.scaffold,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
    ).copyWith(
      primary: c.primary,
      surface: c.card,
      onSurface: c.textPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: c.textPrimary,
      displayColor: c.textPrimary,
    ),
    iconTheme: IconThemeData(color: c.textSecondary),
    cardTheme: base.cardTheme.copyWith(
      color: c.card,
    ),
    dialogTheme: base.dialogTheme.copyWith(
      backgroundColor: c.card,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: c.textMuted),
      floatingLabelStyle: TextStyle(color: c.primaryLight),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.border)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.primaryLight)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: c.textPrimary,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.card,
      indicatorColor: c.primary.withOpacity(0.25),
      labelTextStyle: WidgetStateProperty.all(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.textPrimary),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: c.primaryLight);
        }
        return IconThemeData(color: c.textSecondary);
      }),
    ),
    useMaterial3: true,
    extensions: [c],
  );
}

ThemeData get darkAppTheme => _buildTheme(AppColors.dark, Brightness.dark);
ThemeData get lightAppTheme => _buildTheme(AppColors.light, Brightness.light);

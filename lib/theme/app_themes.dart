/*
 *     Copyright (C) 2026 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musify/services/settings_manager.dart';
import 'package:musify/theme/dynamic_color_compat.dart';

ThemeMode themeMode = getThemeMode(themeModeSetting);
Brightness brightness = getBrightnessFromThemeMode(themeMode);

PageTransitionsBuilder transitionsBuilder = predictiveBack.value
    ? const PredictiveBackPageTransitionsBuilder()
    : const CupertinoPageTransitionsBuilder();

Brightness getBrightnessFromThemeMode(ThemeMode themeMode) {
  final themeBrightnessMapping = {
    ThemeMode.light: Brightness.light,
    ThemeMode.dark: Brightness.dark,
    ThemeMode.system:
        SchedulerBinding.instance.platformDispatcher.platformBrightness,
  };

  return themeBrightnessMapping[themeMode] ?? Brightness.dark;
}

ThemeMode getThemeMode(int themeModeIndex) {
  const themeModes = ThemeMode.values;
  if (themeModeIndex >= 0 && themeModeIndex < themeModes.length) {
    return themeModes[themeModeIndex];
  }
  return ThemeMode.system;
}

ColorScheme getAppColorScheme(
  ColorScheme? lightColorScheme,
  ColorScheme? darkColorScheme,
) {
  if (useSystemColor.value &&
      lightColorScheme != null &&
      darkColorScheme != null) {
    // Temporary fix until this will be fixed: https://github.com/material-foundation/flutter-packages/issues/582

    (lightColorScheme, darkColorScheme) = tempGenerateDynamicColourSchemes(
      lightColorScheme,
      darkColorScheme,
    );
  }

  final selectedScheme = (brightness == Brightness.light)
      ? lightColorScheme
      : darkColorScheme;

  if (useSystemColor.value && selectedScheme != null) {
    return selectedScheme;
  } else {
    return ColorScheme.fromSeed(
      seedColor: primaryColorSetting,
      brightness: brightness,
    ).harmonized();
  }
}

ThemeData getAppTheme(ColorScheme colorScheme) {
  final base = colorScheme.brightness == Brightness.light
      ? ThemeData.light()
      : ThemeData.dark();

  final isLight = colorScheme.brightness == Brightness.light;
  final isPureBlack =
      colorScheme.brightness == Brightness.dark && usePureBlackColor.value;

  // Pure black theme colors
  const pureBlack = Color(0xFF000000);
  const pureBlackElevated = Color(0xFF0A0A0A);
  const pureBlackContainer = Color(0xFF121212);
  const pureBlackContainerHigh = Color(0xFF1A1A1A);

  // Redesign: fundo escuro profundo consistente (estilo Spotify), mesmo
  // fora do modo "pure black" — mantém a opção pure black como ainda mais escura.
  const spotifyBg = Color(0xFF121212);
  const spotifyElevated = Color(0xFF181818);
  const spotifyContainerHigh = Color(0xFF282828);

  final bgColor = isLight
      ? colorScheme.surface
      : (isPureBlack ? pureBlack : spotifyBg);

  final cardBgColor = isLight
      ? colorScheme.surfaceContainerLow
      : (isPureBlack ? pureBlackElevated : spotifyElevated);

  // modified color scheme for dark redesign (aplica também fora do pure black)
  // onSurface/onSurfaceVariant forçados para branco/cinza claro no escuro,
  // pra não herdar tons pastel do dynamic color e ficar ilegível.
  final effectiveColorScheme = isLight
      ? colorScheme
      : colorScheme.copyWith(
          surface: isPureBlack ? pureBlack : spotifyBg,
          surfaceContainerLowest: isPureBlack ? pureBlack : spotifyBg,
          surfaceContainerLow: isPureBlack ? pureBlackElevated : spotifyElevated,
          surfaceContainer: isPureBlack ? pureBlackContainer : spotifyElevated,
          surfaceContainerHigh: isPureBlack
              ? pureBlackContainerHigh
              : spotifyContainerHigh,
          surfaceContainerHighest: isPureBlack
              ? pureBlackContainerHigh
              : spotifyContainerHigh,
          onSurface: Colors.white,
          onSurfaceVariant: const Color(0xFFB3B3B3),
        );

  final baseTextTheme = GoogleFonts.poppinsTextTheme(base.textTheme);

  return ThemeData(
    scaffoldBackgroundColor: bgColor,
    colorScheme: effectiveColorScheme,
    cardColor: cardBgColor,
    textTheme: isLight
        ? baseTextTheme
        : baseTextTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
    cardTheme: base.cardTheme.copyWith(
      elevation: 0,
      color: cardBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: bgColor,
      foregroundColor: isLight ? effectiveColorScheme.primary : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: isLight ? effectiveColorScheme.primary : Colors.white,
        letterSpacing: -0.5,
      ),
      toolbarHeight: 64,
      iconTheme: IconThemeData(
        color: isLight ? effectiveColorScheme.onSurfaceVariant : Colors.white,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: isLight ? effectiveColorScheme.onSurfaceVariant : Colors.white,
        size: 24,
      ),
    ),
    listTileTheme: base.listTileTheme.copyWith(
      textColor: isLight ? effectiveColorScheme.primary : Colors.white,
      iconColor: effectiveColorScheme.primary,
    ),
    sliderTheme: base.sliderTheme.copyWith(
      year2023: false,
      trackHeight: 4,
      activeTrackColor: effectiveColorScheme.primary,
      thumbColor: Colors.white,
      thumbSize: WidgetStateProperty.all(const Size(6, 30)),
    ),
    bottomSheetTheme: base.bottomSheetTheme.copyWith(
      backgroundColor: isLight
          ? colorScheme.surfaceContainerLow
          : (isPureBlack ? pureBlackElevated : spotifyElevated),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      isDense: true,
      fillColor: isLight
          ? colorScheme.surfaceContainerHighest
          : (isPureBlack ? pureBlackContainerHigh : spotifyContainerHigh),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: isLight ? null : const Color(0xFFB3B3B3),
      ),
      contentPadding: const EdgeInsets.fromLTRB(18, 14, 20, 14),
    ),
    dialogTheme: base.dialogTheme.copyWith(
      backgroundColor: isLight
          ? colorScheme.surfaceContainerLow
          : (isPureBlack ? pureBlackContainer : spotifyElevated),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      backgroundColor: bgColor,
      elevation: 0,
      height: 70,
      indicatorColor: effectiveColorScheme.primary.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: effectiveColorScheme.primary, size: 24);
        }
        return IconThemeData(
          color: isLight ? effectiveColorScheme.onSurfaceVariant : Colors.grey,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: isLight ? effectiveColorScheme.onSurface : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(
          color: isLight ? effectiveColorScheme.onSurfaceVariant : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
    ),
    navigationRailTheme: base.navigationRailTheme.copyWith(
      backgroundColor: bgColor,
      elevation: 0,
      indicatorColor: effectiveColorScheme.primary.withValues(alpha: 0.15),
      selectedIconTheme: IconThemeData(
        color: effectiveColorScheme.primary,
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: isLight ? effectiveColorScheme.onSurfaceVariant : Colors.grey,
        size: 24,
      ),
      selectedLabelTextStyle: TextStyle(
        color: isLight ? effectiveColorScheme.onSurface : Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: isLight ? effectiveColorScheme.onSurfaceVariant : Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    popupMenuTheme: base.popupMenuTheme.copyWith(
      color: isLight
          ? colorScheme.surfaceContainerLow
          : (isPureBlack ? pureBlackContainer : spotifyElevated),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: base.dividerTheme.copyWith(
      color: effectiveColorScheme.outlineVariant,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: effectiveColorScheme.secondaryContainer,
      contentTextStyle: TextStyle(
        color: effectiveColorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      actionTextColor: effectiveColorScheme.secondary,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: transitionsBuilder,
      },
    ),
  );
}

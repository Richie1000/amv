import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  RouteFlow Design Tokens
// ─────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Core backgrounds
  static const Color bgBase = Color(0xFF0D1117); // deep void
  static const Color bgSurface = Color(0xFF161B22); // card / sheet
  static const Color bgElevated = Color(0xFF1C2333); // modals, drawers
  static const Color bgSubtle = Color(0xFF21262D); // input fields, chips

  // Border / divider
  static const Color border = Color(0xFF30363D);
  static const Color borderFocus = Color(0xFF58A6FF);

  // Brand — amber signal
  static const Color primary = Color(0xFFE8A020); // main amber
  static const Color primaryLight = Color(0xFFF5C842); // hover / highlight
  static const Color primaryDark = Color(0xFFB07A10); // pressed
  static const Color primaryMuted = Color(0x1FE8A020); // tinted background

  // Status colours
  static const Color statusPending = Color(0xFFE8A020); // amber
  static const Color statusSearching = Color(0xFF58A6FF); // blue
  static const Color statusFound = Color(0xFF7EE787); // green
  static const Color statusSent = Color(0xFFD2A8FF); // purple
  static const Color statusConfirmed = Color(0xFF3FB950); // strong green
  static const Color statusNoTraffic = Color(0xFFF85149); // red
  static const Color statusClosed = Color(0xFF8B949E); // grey

  // Priority
  static const Color priorityHigh = Color(0xFFF85149);
  static const Color priorityMedium = Color(0xFFE8A020);
  static const Color priorityLow = Color(0xFF7EE787);

  // Text hierarchy
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF484F58);
  static const Color textOnPrimary = Color(0xFF0D1117);

  // Semantic
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFE8A020);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);
}

// ─────────────────────────────────────────────
//  Typography
// ─────────────────────────────────────────────
//  IBM Plex Mono — numerics, codes, rates (monospaced precision)
//  IBM Plex Sans — UI labels, body
//  Add to pubspec.yaml:
//    google_fonts: ^6.x
//  Usage: GoogleFonts.ibmPlexSansTextTheme() / GoogleFonts.ibmPlexMono()

class AppTextStyles {
  AppTextStyles._();

  // Display — large dashboard numbers
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  // Headings
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'IBMPlexSans',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.textMuted,
  );

  // Mono — rates, IDs, codes
  static const TextStyle mono = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryLight,
  );

  static const TextStyle monoLarge = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryLight,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}

// ─────────────────────────────────────────────
//  Spacing & Sizing
// ─────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double x3l = 32.0;
  static const double x4l = 40.0;
  static const double x5l = 48.0;
}

class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double full = 999.0;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(sm),
  );
  static const BorderRadius chipRadius = BorderRadius.all(
    Radius.circular(full),
  );
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

// ─────────────────────────────────────────────
//  Shadows & Elevation
// ─────────────────────────────────────────────

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x40E8A020),
      blurRadius: 12,
      spreadRadius: -2,
      offset: Offset(0, 2),
    ),
  ];
}

// ─────────────────────────────────────────────
//  Main Theme
// ─────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryMuted,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.info,
      onSecondary: AppColors.textOnPrimary,
      secondaryContainer: Color(0x1F58A6FF),
      onSecondaryContainer: AppColors.info,
      tertiary: AppColors.success,
      onTertiary: AppColors.textOnPrimary,
      tertiaryContainer: Color(0x1F3FB950),
      onTertiaryContainer: AppColors.success,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      errorContainer: Color(0x1FF85149),
      onErrorContainer: AppColors.error,
      surface: AppColors.bgSurface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.bgSubtle,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: AppColors.bgBase,
      inversePrimary: AppColors.primaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgBase,
      canvasColor: AppColors.bgSurface,
      cardColor: AppColors.bgSurface,
      dividerColor: AppColors.border,
      splashColor: AppColors.primaryMuted,
      highlightColor: Colors.transparent,
      focusColor: AppColors.primaryMuted,

      // ── System UI ──────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgSurface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineMedium,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.bgBase,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary, size: 22),
      ),

      // ── Navigation ─────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgSurface,
        indicatorColor: AppColors.primaryMuted,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        elevation: 4,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 22);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMedium.copyWith(color: AppColors.primary);
          }
          return AppTextStyles.labelMedium;
        }),
      ),

      navigationDrawerTheme: const NavigationDrawerThemeData(
        backgroundColor: AppColors.bgElevated,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryMuted,
      ),

      // ── Cards ──────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // ── Buttons ────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.bgSubtle,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(0, 44),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: AppColors.textMuted,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              minimumSize: const Size(0, 44),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.buttonRadius,
              ),
              textStyle: AppTextStyles.labelLarge,
            ).copyWith(
              side: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.focused) ||
                    states.contains(WidgetState.pressed)) {
                  return const BorderSide(color: AppColors.primary);
                }
                return const BorderSide(color: AppColors.border);
              }),
            ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textMuted,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(0, 36),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.bgSubtle,
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          highlightColor: AppColors.primaryMuted,
          minimumSize: const Size(40, 40),
        ),
      ),

      // ── FAB ────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        extendedTextStyle: AppTextStyles.labelLarge,
      ),

      // ── Inputs ─────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSubtle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTextStyles.bodyMedium,
        labelStyle: AppTextStyles.titleSmall,
        floatingLabelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.bgSubtle),
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),

      // ── Chips ──────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgSubtle,
        selectedColor: AppColors.primaryMuted,
        disabledColor: AppColors.bgSubtle,
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle: AppTextStyles.labelMedium,
        side: const BorderSide(color: AppColors.border),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.chipRadius),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 16,
        ),
      ),

      // ── Dialogs & Bottom Sheets ─────────────────
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.bgElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        titleTextStyle: AppTextStyles.headlineSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bgElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        modalElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
        dragHandleColor: AppColors.border,
        dragHandleSize: Size(40, 4),
        showDragHandle: true,
      ),

      // ── Lists & Dividers ───────────────────────
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primaryMuted,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.titleMedium,
        subtitleTextStyle: AppTextStyles.bodyMedium,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        minVerticalPadding: AppSpacing.sm,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        dense: false,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ── Tabs ───────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
        overlayColor: WidgetStateProperty.all(AppColors.primaryMuted),
      ),

      // ── Snackbar ───────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgElevated,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        actionTextColor: AppColors.primary,
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Progress & Sliders ─────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.bgSubtle,
        circularTrackColor: AppColors.bgSubtle,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.bgSubtle,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primaryMuted,
        valueIndicatorColor: AppColors.bgElevated,
        valueIndicatorTextStyle: AppTextStyles.labelMedium,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),

      // ── Switch & Checkbox ──────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return AppColors.textOnPrimary;
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.bgSubtle;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return AppColors.border;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.border;
        }),
      ),

      // ── Popups & Menus ─────────────────────────
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.bgElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        textStyle: AppTextStyles.titleMedium,
        position: PopupMenuPosition.under,
      ),

      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: AppTextStyles.bodyLarge,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.bgElevated),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(8),
          shadowColor: WidgetStatePropertyAll(Colors.black),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bgSubtle,
        ),
      ),

      // ── Tooltip ────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.border),
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        waitDuration: const Duration(milliseconds: 600),
      ),

      // ── Badges ─────────────────────────────────
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.error,
        textColor: AppColors.textPrimary,
        smallSize: 8,
        largeSize: 18,
        textStyle: AppTextStyles.labelSmall,
        padding: EdgeInsets.symmetric(horizontal: 5),
      ),

      // ── Text ───────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // ── Icon ───────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
      primaryIconTheme: const IconThemeData(color: AppColors.primary, size: 20),

      // ── Misc ───────────────────────────────────
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}

// ─────────────────────────────────────────────
//  Status Helpers
// ─────────────────────────────────────────────

class StatusStyle {
  const StatusStyle({
    required this.color,
    required this.label,
    required this.icon,
  });

  final Color color;
  final String label;
  final IconData icon;
}

class AppStatusStyles {
  AppStatusStyles._();

  static const Map<String, StatusStyle> requestStatus = {
    'pending': StatusStyle(
      color: AppColors.statusPending,
      label: 'Pending',
      icon: Icons.schedule_outlined,
    ),
    'searchingSupplier': StatusStyle(
      color: AppColors.statusSearching,
      label: 'Searching Supplier',
      icon: Icons.search_outlined,
    ),
    'supplierFound': StatusStyle(
      color: AppColors.statusFound,
      label: 'Supplier Found',
      icon: Icons.check_circle_outline,
    ),
    'sentToCustomer': StatusStyle(
      color: AppColors.statusSent,
      label: 'Sent to Customer',
      icon: Icons.send_outlined,
    ),
    'trafficConfirmed': StatusStyle(
      color: AppColors.statusConfirmed,
      label: 'Traffic Confirmed',
      icon: Icons.traffic_outlined,
    ),
    'noTraffic': StatusStyle(
      color: AppColors.statusNoTraffic,
      label: 'No Traffic',
      icon: Icons.block_outlined,
    ),
    'closed': StatusStyle(
      color: AppColors.statusClosed,
      label: 'Closed',
      icon: Icons.archive_outlined,
    ),
  };

  static const Map<String, StatusStyle> trafficStatus = {
    'testing': StatusStyle(
      color: AppColors.info,
      label: 'Testing',
      icon: Icons.science_outlined,
    ),
    'lowTraffic': StatusStyle(
      color: AppColors.warning,
      label: 'Low Traffic',
      icon: Icons.signal_cellular_0_bar_outlined,
    ),
    'stableTraffic': StatusStyle(
      color: AppColors.success,
      label: 'Stable Traffic',
      icon: Icons.signal_cellular_4_bar,
    ),
    'highTraffic': StatusStyle(
      color: AppColors.statusConfirmed,
      label: 'High Traffic',
      icon: Icons.trending_up,
    ),
    'noTraffic': StatusStyle(
      color: AppColors.error,
      label: 'No Traffic',
      icon: Icons.signal_cellular_off_outlined,
    ),
  };

  static const Map<String, StatusStyle> priority = {
    'high': StatusStyle(
      color: AppColors.priorityHigh,
      label: 'High',
      icon: Icons.priority_high,
    ),
    'medium': StatusStyle(
      color: AppColors.priorityMedium,
      label: 'Medium',
      icon: Icons.remove,
    ),
    'low': StatusStyle(
      color: AppColors.priorityLow,
      label: 'Low',
      icon: Icons.arrow_downward,
    ),
  };
}

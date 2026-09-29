part of fixmate_app;

class ServiceBookingApp extends StatelessWidget {
  const ServiceBookingApp({super.key, required this.configured});

  final bool configured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FixMate',
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: _primaryColor,
          secondary: _accentColor,
          surface: _surfaceColor,
          outline: _lineColor,
          surfaceContainerHighest: const Color(0xFFF0F0FA),
        ),
        scaffoldBackgroundColor: _backgroundColor,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        }),
        appBarTheme: const AppBarTheme(
          backgroundColor: _navyColor,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
          toolbarHeight: 70,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE4EAF0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _primaryColor, width: 1.6),
          ),
          filled: true,
          fillColor: const Color(0xCCFFFFFF),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          labelStyle: const TextStyle(color: _mutedColor),
          prefixIconColor: _primaryColor,
        ),
        cardTheme: CardThemeData(
          elevation: 5,
          shadowColor: const Color(0x185B5CE2),
          color: const Color(0xEFFFFFFF),
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xCCFFFFFF)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFD9D9E8),
            elevation: 7,
            shadowColor: const Color(0x505B5CE2),
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _primaryColor,
            backgroundColor: const Color(0xA6FFFFFF),
            side: const BorderSide(color: Color(0xFFCFCFF4)),
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFEAF5F4),
          selectedColor: const Color(0xFFD6EFED),
          labelStyle: const TextStyle(
            color: _inkColor,
            fontWeight: FontWeight.w700,
          ),
          secondaryLabelStyle: const TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.w800,
          ),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFFE8E8FF),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? _primaryColor
                  : _mutedColor,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: _inkColor,
            fontWeight: FontWeight.w900,
          ),
          titleLarge: TextStyle(
            color: _inkColor,
            fontWeight: FontWeight.w900,
          ),
          titleMedium: TextStyle(
            color: _inkColor,
            fontWeight: FontWeight.w800,
          ),
          bodyMedium: TextStyle(color: _mutedColor),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _navyColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFFF9F9FF),
          surfaceTintColor: Colors.transparent,
          modalBarrierColor: Color(0x6624264F),
          showDragHandle: true,
          dragHandleColor: Color(0xFFCBCBE0),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFFF9F9FF),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : const Color(0xFFAAAABD),
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? _providerColor
                : const Color(0xFFE2E2EC),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: _primaryColor,
          linearTrackColor: Color(0xFFE8E8F7),
        ),
        dividerTheme: const DividerThemeData(
          color: _lineColor,
          thickness: 1,
        ),
        useMaterial3: true,
      ),
      home: AuthGate(configured: configured),
    );
  }
}

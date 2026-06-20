part of fixmate_app;

class ServiceBookingApp extends StatelessWidget {
  const ServiceBookingApp({super.key, required this.configured});

  final bool configured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FixSeva',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: _primaryColor,
          secondary: _accentColor,
          surface: _surfaceColor,
        ),
        scaffoldBackgroundColor: _backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE4EAF0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _primaryColor, width: 1.6),
          ),
          filled: true,
          fillColor: _surfaceColor,
          labelStyle: const TextStyle(color: _mutedColor),
          prefixIconColor: _primaryColor,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: _surfaceColor,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE8EEF2)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _primaryColor,
            side: const BorderSide(color: Color(0xFFB7D8D7)),
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
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surfaceColor,
          indicatorColor: const Color(0xFFD6EFED),
          labelTextStyle: MaterialStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(MaterialState.selected)
                  ? _primaryColor
                  : _mutedColor,
              fontWeight: states.contains(MaterialState.selected)
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
        useMaterial3: true,
      ),
      home: AuthGate(configured: configured),
    );
  }
}


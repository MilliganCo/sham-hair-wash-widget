import 'package:flutter/material.dart';

import '../features/hair_wash/presentation/hair_wash_home_page.dart';

class ShamApp extends StatelessWidget {
  const ShamApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF020702);
    const surface = Color(0xFF081108);
    const primary = Color(0xFF7DFF9B);
    const secondary = Color(0xFF4ADE80);
    const onSurface = Color(0xFFD7FFE1);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SHAM // CLI',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'monospace',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: primary,
          secondary: secondary,
          surface: surface,
          onSurface: onSurface,
        ),
        scaffoldBackgroundColor: background,
        textTheme:
            ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'monospace',
            ).textTheme.apply(
              bodyColor: onSurface,
              displayColor: onSurface,
              fontFamily: 'monospace',
            ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0B140B),
          labelStyle: const TextStyle(color: Color(0xFF9DFFB4)),
          helperStyle: const TextStyle(color: Color(0xFF79C989)),
          prefixStyle: const TextStyle(color: Color(0xFF7DFF9B)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: Color(0xFF276636)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: Color(0xFF276636)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: Color(0xFF7DFF9B)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: background,
            shape: const RoundedRectangleBorder(),
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: Color(0xFF3EC76A)),
            shape: const RoundedRectangleBorder(),
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF0B140B),
          contentTextStyle: TextStyle(
            color: Color(0xFFD7FFE1),
            fontFamily: 'monospace',
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: primary,
          inactiveTrackColor: Color(0xFF15361C),
          thumbColor: primary,
          overlayColor: Color(0x337DFF9B),
          valueIndicatorColor: Color(0xFF103B18),
          valueIndicatorTextStyle: TextStyle(
            color: Color(0xFFD7FFE1),
            fontFamily: 'monospace',
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primary,
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          headerBackgroundColor: const Color(0xFF0D1A0D),
          headerForegroundColor: onSurface,
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return background;
            }
            return onSurface;
          }),
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primary;
            }
            return null;
          }),
          todayForegroundColor: const WidgetStatePropertyAll(primary),
          todayBorder: const BorderSide(color: primary),
          shape: const RoundedRectangleBorder(),
        ),
        dividerColor: const Color(0xFF1A3A21),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: primary,
          selectionColor: Color(0x337DFF9B),
          selectionHandleColor: primary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: onSurface,
          surfaceTintColor: Colors.transparent,
        ),
        splashColor: const Color(0x227DFF9B),
        highlightColor: Colors.transparent,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ),
      home: const HairWashHomePage(),
    );
  }
}

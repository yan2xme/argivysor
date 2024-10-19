// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'consts.dart'; // Ensure GEMINI_API_KEY is defined here
import 'main_menu.dart'; // Adjust the path if main_menu.dart is in a different directory
import 'splash_screen.dart';

void main() {
  // Initialize Gemini with the API key
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriVysor',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/', // Default route is the splash screen
      routes: {
        '/': (context) => const SplashScreen(),
        '/main_menu': (context) => const MainMenu(),
      },
    );
  }

  // Separate method to build the theme for better readability
  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
      fontFamily: 'SFProDisplay', // Ensure this font is added in pubspec.yaml
      textTheme: _buildTextTheme(),
    );
  }

  // Separate method to build the text theme
  TextTheme _buildTextTheme() {
    return const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'SFProDisplay'),
      bodyMedium: TextStyle(fontFamily: 'SFProDisplay'),
      displayLarge: TextStyle(
        fontFamily: 'SFProDisplay',
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        fontFamily: 'SFProDisplay',
        fontWeight: FontWeight.w700,
      ),
      displaySmall: TextStyle(
        fontFamily: 'SFProDisplay',
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'SFProDisplay',
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'SFProDisplay',
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'SFProDisplay',
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontFamily: 'SFProDisplay',
        fontStyle: FontStyle.italic,
      ),
      titleSmall: TextStyle(
        fontFamily: 'SFProDisplay',
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

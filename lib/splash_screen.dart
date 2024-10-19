import 'dart:async';
import 'package:flutter/material.dart';
import 'main_menu.dart'; // Import your main menu file

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController for the fade effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Use a CurvedAnimation to provide a smooth fade-in effect
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start the animation
    _controller.forward();

    // Set a timer to transition from the splash screen to the main menu
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const MainMenu()), // Navigate to Main Menu
      );
    });
  }

  @override
  void dispose() {
    // Dispose of the animation controller when done
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green, // Green background for splash screen
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Your logo/image in assets folder
                height: 150, // Height of the image
                width: 150, // Width of the image
              ),
              const SizedBox(height: 20),
              const Text(
                'AgriVysor', // App name
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// main_menu.dart
import 'package:flutter/material.dart';
import 'plant_library.dart';
import 'detect_tab.dart'; // Ensure DetectTab is correctly implemented

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const DetectTab(), // Correct usage of DetectTab widget
    const PlantLibrary(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed AppBar for a cleaner look
      body: SafeArea(
        child: Column(
          children: [
            // Logo at the center above the text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  child: Image.asset(
                    'assets/logo.png',
                    height: 100, // Adjust size as needed
                    width: 100, // Adjust size as needed
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Centered and italicized Welcome Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Good Day! Let\'s detect the disease now!',
                style: TextStyle(
                  fontSize: 20, // Larger font size
                  fontStyle: FontStyle.italic, // Italicized
                  fontWeight: FontWeight.bold, // Bold for emphasis
                  color: Colors.green[700], // Match your app's theme
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Expanded selected widget
            Expanded(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, size: 30), // Increased icon size
            label: 'Detect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books, size: 30), // Increased icon size
            label: 'Library',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        iconSize: 30, // Adjust as needed
        selectedFontSize: 16, // Increased font size
        unselectedFontSize: 14,
        type: BottomNavigationBarType.fixed, // Prevent shifting
      ),
    );
  }
}

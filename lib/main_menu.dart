import 'package:flutter/material.dart';
import 'detect_tab.dart'; // Import DetectTab
import 'plant_library.dart'; // Import PlantLibrary
import 'pages/home_page.dart'; // Import HomePage (GeminiChatbot)
import 'history.dart'; // Import HistoryPage (new)
import 'generated/l10n.dart'; // Import localization

class MainMenu extends StatefulWidget {
  final Function(Locale) setLocale;
  const MainMenu({super.key, required this.setLocale});

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isRailVisible = false; // State to manage NavigationRail visibility

  // Animation controller for smooth transitions
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  // Updated _widgetOptions list with HomePage included
  late final List<Widget> _widgetOptions = <Widget>[
    const DetectTab(), // Index 0
    const PlantLibrary(), // Index 1
    const HomePage(shouldSendPrompt: false), // Index 2 (Chatbot) with no prompt
    const HistoryPage(), // Index 3 (HistoryPage) without inferenceHistory parameter
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Define the slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start off-screen to the left
      end: Offset.zero, // End at original position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic, // Use a smoother curve for transitions
    ));
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // No need to hide the NavigationRail after selection
    });
  }

  void _toggleRail() {
    setState(() {
      _isRailVisible = !_isRailVisible;
      if (_isRailVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildNavigationRail() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 220, // Increased width for larger buttons and labels
        color: Colors.green[50], // Light green background
        child: Column(
          children: [
            // Optional: Add a header or logo inside the NavigationRail
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Rounded corners
                child: Image.asset(
                  'assets/logo.png',
                  height: 80, // Adjust size as needed
                  width: 80, // Adjust size as needed
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 80, color: Colors.red);
                  },
                ),
              ),
            ),
            // NavigationRail-like destinations
            Expanded(
              child: ListView(
                children: [
                  NavigationItem(
                    icon: Icons.camera_alt,
                    label: S.of(context).detect,
                    isSelected: _selectedIndex == 0,
                    onTap: () => _onItemTapped(0),
                  ),
                  NavigationItem(
                    icon: Icons.library_books,
                    label: S.of(context).library,
                    isSelected: _selectedIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                  NavigationItem(
                    icon: Icons.chat_bubble_outline,
                    label: S.of(context).chatbot,
                    isSelected: _selectedIndex == 2,
                    onTap: () => _onItemTapped(2),
                  ),
                  NavigationItem(
                    icon: Icons.history, // New History icon
                    label: S.of(context).history,
                    isSelected: _selectedIndex == 3,
                    onTap: () => _onItemTapped(3),
                  ),
                  NavigationItem(
                    icon: Icons.language,
                    label: S.of(context).selectLanguage,
                    isSelected: false,
                    onTap: () => _showLanguageSelectionDialog(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  widget.setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Tagalog'),
                onTap: () {
                  widget.setLocale(const Locale('tl'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Row(
              children: [
                // Main content area
                Expanded(
                  child: Column(
                    children: [
                      // Custom Top Bar with only the menu button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isRailVisible ? Icons.close : Icons.menu,
                                color: Colors.green,
                                size:
                                    30, // Increased size for better visibility
                              ),
                              onPressed: _toggleRail,
                              tooltip: _isRailVisible
                                  ? S.of(context).closeMenu
                                  : S.of(context).openMenu,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              S.of(context).appName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontFamily: 'SFProDisplay',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Logo at the center above the text, only on DetectTab
                      if (_selectedIndex == 0) ...[
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/logo.png',
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error,
                                      size: 120, color: Colors.red);
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Text(
                                S.of(context).goodDay,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                  fontFamily: 'SFProDisplay',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                S.of(context).detectDisease,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.green[700],
                                  fontFamily: 'SFProDisplay',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      // Expanded selected widget with conditional padding
                      Expanded(
                        child: Padding(
                          padding: _selectedIndex == 2
                              ? EdgeInsets.zero // Remove padding for HomePage
                              : const EdgeInsets.all(
                                  16.0), // Padding for others
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeInOutCubic,
                            switchOutCurve: Curves.easeInOutCubic,
                            child: _widgetOptions.elementAt(_selectedIndex),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Faded Overlay
          if (_isRailVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleRail,
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Semi-transparent
                ),
              ),
            ),
          // Navigation Rail Overlay
          if (_isRailVisible)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildNavigationRail(),
            ),
        ],
      ),
    );
  }
}

class NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 36,
        color: isSelected ? Colors.green : Colors.grey,
        semanticLabel: label,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.green : Colors.grey,
          fontFamily: 'SFProDisplay',
        ),
      ),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      selected: isSelected,
      selectedTileColor: Colors.green[100],
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.green) : null,
    );
  }
}
